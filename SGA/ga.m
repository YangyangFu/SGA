function [result,surrogateOpt] = ga(opt,surrogateOpt,varargin)
%This is a real coded GA for mixed integer constrained optimization
%problem.
%
% Author: Yangyang Fu
% Email: yangyang.fu@colorado.edu
% History:
%  August 2017, First implementation by Yangyang Fu
% ----------------------------------------------------------------

% timer
tStart = tic();

% verify the optimization model
opt = verifyOpt(opt);

% variables initialization
nVar    = opt.numVar;
nObj    = opt.numObj;
nCons   = opt.numCons;
popsize = opt.popsize;
maxExpEva = opt.maxExpEva;

% pop : current population
pop = repmat( struct(...
    'var', zeros(1,nVar), ...
    'obj', zeros(1,nObj), ...
    'cons', zeros(1,nCons),...
    'surrfitness',zeros(1,nObj),...
    'surrcons',zeros(1,nCons),...
    'rank', 0,...
    'distance', 0,...			% Distance used in R-NSGA-II. Not for single objective GA.
    'prefDistance', 0,...       % preference distance used in R-NSGA-II. Not for single objective GA.
    'nViol', 0,...
    'violSum', 0,...
    'nViolSurr',0,...
    'violSumSurr',0,...
    'fitness',0,...
    'expensive',0),... % flag for exensive evaluation: 0-false, 1-true
    [1,popsize]);

% state: optimization state of one generation
state = struct(...
    'currentGen', 1,...         % current generation number
    'evaluateCount', 0,...      % number of objective function evaluation
    'totalTime', 0,...          % total time from the beginning
    'firstFrontCount', 0,...    % individual number of first front
    'frontCount', 0,...         % number of front
    'avgEvalTime', 0, ...       % average evaluation time of objective function (current generation)
    'worstFeas',0, ...          % worst feasible solution in current generation, =0 if all solutions are infeasible or nObj>1
    'bestfitness',0,...         % best fitness for single-objective optimization
    'minfitness',0,...          % minimum fitness for single-objective optimization
    'maxfitness',0,...          % maximum fitness for single-objective optimization
    'bestindividual',0,...      % best individual for single-objective optimziation
    'averagefitness',0,...      % average fitness for single-objective optimization
    'maxconstraint',0,...         % maximum constraint for single-objective optimziation
    'fitness',[]);
result.pops     = repmat(pop, [opt.maxGen, 1]);     % each row is the population of one generation
result.states   = repmat(state, [opt.maxGen, 1]);   % each row is the optimizaiton state of one generation
result.opt      = opt;                              % use for output
result.surrogatemodel = cell(opt.maxGen,nObj+nCons);
% global variables


% plot set


%Initialization at generation=0
%======================================================================
ngen = 1;
pop = opt.initfun{1}(opt, pop, opt.initfun{2:end});

% expensively evaluate the individuals
[pop, state] = evaluate(opt, pop, state);

numExpEva=length(pop);
% save expensive evaluations
surrogateOpt.expensivePop=pop;

% now we need rank the solutions in current generation
% calculate the fitness value for single obejctive
[opt, pop, state] = fitnessValue(opt, pop, state);

% if surrogate model is set to use, then train surrogate models for each
% objective and constraints, if neccessary.
if opt.surrogate.use
    
    %surrogateperf=zeros(opt.maxGen,nObj+nCons);
    for i=1:length(pop)
        surrogateOpt.traindataAll(i,:)=pop(i).var;
        surrogateOpt.truefitnessAll(i,:)=pop(i).obj;
        if nCons==0
           surrogateOpt.trueconstraintAll=[];
        else
           surrogateOpt.trueconstraintAll(i,:)=pop(i).cons;
        end
    end
    
    % train surrogate model for objective functions
    for j=1:nObj
        
        [net.net,surrogateOpt]=trainsurrogate(surrogateOpt.traindataAll,surrogateOpt.truefitnessAll(:,j),...
            surrogateOpt,opt);
        result.surrogatemodel{ngen,j}=net;
        %surrogateperf(ngen,j)=surrogateOpt.performance;
    end
    
    % train surrogate model for constraint functions. since, in this case,
    % constraints computation is simple,only some of them need to be
    % fitted.
    consSurrogateIndex=surrogateOpt.consSurrogateIndex;
    if ~isempty(consSurrogateIndex)
        for j=1:length(consSurrogateIndex)
            [net.net,surrogateOpt]=trainsurrogate(surrogateOpt.traindataAll,...
                surrogateOpt.trueconstraintAll(:,consSurrogateIndex(j)),...
                surrogateOpt,opt);
            result.surrogatemodel{ngen,consSurrogateIndex(j)+nObj}=net;
        end
    end
    
    for i=1:length(pop)
    
    pop(i).surrcons=pop(i).cons;
    pop(i).nViolSurr=pop(i).nViol;
    pop(i).violSumSurr=pop(i).violSum;
    end
    
    result.surrogatemodel(ngen+1,:)=result.surrogatemodel(ngen,:);
    
end
% state
state.currentGen = ngen;
state.totalTime = toc(tStart);
state = statpop(opt,pop, state);

result.pops(1, :) = pop;
result.states(1)  = state;
result.numExpEva(1) = numExpEva;
% plot
figure;
hold on;
axe1=subplot(2,1,1);
axe2=subplot(2,1,2);
plotga(result,ngen,axe1,axe2);

%======================================================================
%                   Main Loop
%======================================================================
while( ngen < opt.maxGen && numExpEva < maxExpEva)

    % 0. Display information
    ngen = ngen+1;
    state.currentGen = ngen;
    
    fprintf('\n\n************************************************************\n');
    fprintf('*      Current generation %d / %d\n', ngen, opt.maxGen);
    fprintf('************************************************************\n');
    
 if (~opt.surrogate.use) % don't use surrogate    
    % Generate new population through selection, crossover, and mutation
    % operators
%------check expensively evaluated individuals
%------the flag at this mooment is 1 no surrogate is used
    expensivePop=surrogateOpt.expensivePop;
    expensivePop_indi=vertcat(expensivePop.var);    
    % 1. Create new pop
    %****************************************
     % selection operator
    newpop = selectOp(opt, pop);
     
     % crossover operator
    newpop = crossoverOp(opt, newpop,state);    
     % mutation operator
    newpop = mutationOp(opt, newpop, state);
     % integer variable handling. Deesigned for mixed integer programming.
    newpop = integerOp(opt, newpop);
    %set flags for newly-generated individuals and newly-generated
    %individuals need expensive evaluations
    j=0;
    for i=1:length(newpop)
        if ~ismember(newpop(i).var,expensivePop_indi,'rows')
            newpop(i).expensive=0;
            j=j+1;
        end
    end
    numExpEva=numExpEva + j;
     % change the evaluation flags for newly-borned individual from 1 to 0 before expensive evaluation    
     % evaluate new pop
    [newpop, state] = evaluate(opt, newpop, state);
     
    % 2. Combine the new population and old population : combinepop = pop + newpop
    combinepop = [pop, newpop];
    
    % 3. Extact n new population from 2n
    % calculate the fitness value for single obejctive
    [opt, combinepop, state] = fitnessValue(opt, combinepop, state);       
    pop = extractPopFit(opt, combinepop);
    
 else % use sorrogate 
   [opt,pop,state,result.surrogatemodel,surrogateOpt]=surrogate...
            (opt,pop,state, result.surrogatemodel,surrogateOpt);  
   numExpEva =length(surrogateOpt.expensivePop);
 end
 
% 5. Save current generation results
state.totalTime = toc(tStart);
state = statpop(opt,pop, state);

result.pops(ngen, :) = pop;
result.states(ngen)  = state;
result.numExpEva(ngen) = numExpEva;

 % 6. plot current population and output
if( mod(ngen, opt.plotInterval)==0 )
    plotga(result,ngen,axe1,axe2);
end

end

% call output function for closing file
opt = callOutputfuns(opt, state, pop, -1);

% close worker processes
if( strcmpi(opt.useParallel, 'yes'))
    %parpool close
    delete(gcp('nocreate'))
end

toc(tStart); 
end