function [opt,nextpop,state,surrogatemodel,surrogateOpt]=surrogate...
    (opt,pop,state, surrogatemodel,surrogateOpt)
% Function: surrogate
% Description: surrogate model enable the NSGA to approximate fitness and
% to speed up.
%
% Algorithm:
% 1. S=make new pop (P); creat surrogate pop S, where size S>P using selection,crossover and mutation;
% 2. Approximate objectives and constraints in S;
% 3. Ranking in S (fast non-dominated sorting for multi-objective,and fitness evaluation for single-objective);
% 4. Extract Q from S as pre-selection
% 5. Evaluate Q in expensive function evalution;
% 6. determine if the surrogate model should be updated.
% 7. repeat.
%
% Author: Yangyang Fu
% Email: yangyang.fu@colorado.edu
% History:
%  August 2017, First implementation by Yangyang Fu
% ************************************************************************

numObj=opt.numObj;
numCons=opt.numCons;
% 1. make new pop: S=new(P)
%------check expensively evaluated individuals
%------the flag at this mooment is 1 because they are evaluated at step 4
expensivePop=surrogateOpt.expensivePop;
expensivePop_indi=vertcat(expensivePop.var);

% 1.1. new population from operators
newpop=selectOp(opt,pop); % Select offsprings from parents and put them in mating pool
newpop=crossoverOp(opt,newpop,state);
newpop=mutationOp(opt,newpop,state);
newpop = integerOp(opt,newpop);
%------set flags for newly-generated individuals
for i=1:length(newpop)
    if ~ismember(newpop(i).var,expensivePop_indi,'rows')
        newpop(i).expensive=0;
    end
end

% 1.2. Evaluate the approximation value of both objectives and constraints
%    testing data

for i=1:length(newpop)
    testdata(i,:)=newpop(i).var;
end

ngen=state.currentGen;

%   1.2.1 evalutae approximate objectives. 
surrfitnessS=zeros(length(newpop),numObj);
for i=1:numObj
    net=surrogatemodel{ngen,i};
    [ predY,surrogateOpt] =testsurrogate( net.net,testdata,[],surrogateOpt );

    surrfitnessS(:,i)=predY;
end

%   1.2.2 evaluate approximate constraints.
%     (1) evaluate the expensive constraints
consSurrogateIndex=surrogateOpt.consSurrogateIndex;% Only specific constraints need to be approximated
surrconstraintS=zeros(length(newpop),numCons);
if ~isempty(consSurrogateIndex)
    
    for j=1:length(consSurrogateIndex)
        net=surrogatemodel{ngen,numObj+consSurrogateIndex(j)};
        [predY,surrogateOpt]=testsurrogate(net.net,testdata,[],surrogateOpt);
        surrconstraintS(:,consSurrogateIndex(j))=predY;
    end
end
%     (2) evaluate the inexpensive constraints using the original
%     constaints function.
consfun=opt.consfun;% the function handle of inexpensive constraints
inexpconsIndex=setdiff(1:numCons,consSurrogateIndex);
%inexpsurrogateconstraint=consfun(traindata);% evaluate the inexpensive constraints


% put all the constraints together
if ~isempty(inexpconsIndex)
    for i=1:length(newpop)
        % need revised because when evaluating the inexpensive cons, the
        % objective function is called in this case.
     [~,inexpSurrConstraint(i,:)]=consfun(testdata(i,:));% evaluate the inexpensive constraints
    end
    if size(inexpconsIndex,2)~=size(inexpSurrConstraint,2)
        error('inexpensive constraints number is not correct!')
    end
    for j=1:length(inexpconsIndex)
        surrconstraintS(:,inexpconsIndex(j))=inexpSurrConstraint(:,j);
    end
end

for j=1:length(newpop)
    
    newpop(j).surrcons=surrconstraintS(j,:);
    newpop(j).surrfitness=surrfitnessS(j,:);
    
    % Save the objective values and constraint violations for surrogate
    % model
    if( ~isempty(newpop(j).surrcons) )
        idx = find( newpop(j).surrcons>0);
        if( ~isempty(idx) )
            newpop(j).nViolSurr = length(idx);
            newpop(j).violSumSurr = sum( abs(newpop(j).surrcons(idx)) );
        else
            newpop(j).nViolSurr = 0;
            newpop(j).violSumSurr = 0;
        end
    end
    % save the objective values and constraints violation for ture
    % model. Mind that objetice value in both expensive eva and approximate
    % eva will be the same in this line.
    % Assume the surrogate can approximate the objective and constraints
    % very well.
    newpop(j).obj=newpop(j).surrfitness;
    newpop(j).cons=newpop(j).surrcons;
    
    newpop(j).nViol=newpop(j).nViolSurr;
    newpop(j).violSum=newpop(j).violSumSurr;
end

   % 1.3 elitism
   combinepop=[newpop,pop];


% For single-objective optimization only.
% Multiple-objective optimization using NSGA-II will be added later.
%2. Fitness value 
 [opt, out, state] = fitnessValue(opt, combinepop, state); 
%3. Extact Q from S: sorting function has to be "fit"
% This step should garantee that the best invididual should be kept in
% the next popoulation. This is so-called etilism.
 [opt,nextpop] = extract(opt, out);
 
%4. Evaluate Q by expensive calculation of the obj and cons
 [nextpop, state] = evaluate(opt, nextpop, state);
%5. Real fitness
[opt, nextpop, state] = fitnessValue(opt, nextpop, state);

for i=1:length(nextpop)
     if ~ismember(nextpop(i).var,expensivePop_indi,'rows')
         expensivePop=[expensivePop,nextpop(i)];
         expensivePop_indi=[expensivePop_indi;nextpop(i).var];
     end
 end
 surrogateOpt.expensivePop=expensivePop;

%6. Determine whether to update the surrogate model based on model
% preciseness.
	%6.1. calculate the prediction coefficient

truefitnessQ=vertcat(nextpop.obj);
truefitnessP=vertcat(pop.obj);
surrfitnessQ=vertcat(nextpop.surrfitness);
surrfitnessP=vertcat(pop.surrfitness);

	%check objective model first
for i=1:numObj
	% mdoel performance
    [performance,surrogateOpt]=surrogateperf(truefitnessQ(:,i),surrfitnessQ(:,i),surrogateOpt);
    surrogatemodel{state.currentGen,i}.performance=performance;
	
	% if performance is bad, update surrogate model
    if performance<=0.8 % update model
        %extract the training data
        ind=[];
        for j=1:length(nextpop)
            varPotential=nextpop(j).var;
            if ~ismember(varPotential,surrogateOpt.traindataAll,'rows')
               surrogateOpt.traindataAll=[surrogateOpt.traindataAll;varPotential];
               %index for new training data in current pop
               ind=[ind j];
            end
        end    
        truefitnessnew=truefitnessQ(ind);
        surrogateOpt.truefitnessAll=[surrogateOpt.truefitnessAll;truefitnessnew];
        % train surrogate
        [netnew.net,surrogateOpt]=trainsurrogate(surrogateOpt.traindataAll,...
            surrogateOpt.truefitnessAll(:,i),...
            surrogateOpt,opt);
        surrogatemodel{state.currentGen+1,i}=netnew;
        
    else% do not update the surrogate model
        surrogatemodel(state.currentGen+1,i)=surrogatemodel(state.currentGen,i);
        continue
    end
end

%  7.2 check constraint model is neccessary
if ~isempty(consSurrogateIndex)
    trueconstraintQ=vertcat(nextpop.cons);
    trueconstraintP=vertcat(pop.cons);
    surrconstraintQ=vertcat(nextpop.cons);
    
    for i= 1:length(consSurrogateIndex)
        % check model performance
        [performance,surrogateOpt]=surrogateperf(trueconstraintQ(:,consSurrogateIndex(i)),...
            surrconstraintQ(:,consSurrogateIndex(i)),surrogateOpt);
        surrogatemodel{state.currentGen,i}.performance=performance;
        
        if performance<=0.8 % update model
            %extract the training data, same as in the objective value
            trueconstraint=trueconstraintQ(ind);
            surrogateOpt.trueconstraintAll=[surrogateOpt.trueconstraintAll;trueconstraint];
            % train surrogate
            [netnew.net,surrogateOpt]=trainsurrogate(surrogateOpt.traindataAll,...
                surrogateOpt.trueconstraintAll(:,consSurrogateIndex(i)),surrogateOpt,opt);
            surrogatemodel{state.currentGen+1,consSurrogateIndex(i)+numObj}=netnew;
            
        else% do not update the surrogate model
            surrogatemodel(state.currentGen+1,consSurrogateIndex(i)+numObj)=surrogatemodel...
                (state.currentGen,consSurrogateIndex(i)+numObj);
            continue
        end
        
    end
end