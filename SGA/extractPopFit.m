function nextpop = extractPopFit( opt,pop)
%EXTRACTPOPFIT Extract new poppulation by comparing fitness value. Use only
%for single-objective optimization
%   The best several indiviudals are selected for next population
%
%   Author: Yangyang Fu
%   First Implementation: Aug 04, 2017
%   Revisions: Aug 16, 2017
%              Yangyang Fu
%              Add DIS comparing for infeasible solutions in surrogate
%              model.
%
%=========================================================================
% determine the popsize of extracted population
if opt.surrogate.use==1
    popsize=opt.surrogate.miu;
else
    
    popsize = opt.popsize;
end

% add etilism to avoid inaccurate approximation
    % ratio beta, the best beta individuals will go to next population
    % directly
    oldpop=pop(end-popsize+1:end);
    beta=opt.etilism;
    etiNum=round(beta*popsize);
    if length(oldpop)>=etiNum %top (1-alpha)*popsize feasible data are selected.
        [~,ind1]=sort(vertcat(oldpop.fitness)); 
        etiSet=oldpop(ind1(1:etiNum)); % the first feasNum minimum values       
    else
        etiSet=oldpop;      
    end 


if ~opt.surrogate.use %No surrogate model
    fitnessValue = vertcat(pop.fitness);
    [~,index] = sort(fitnessValue);    
    nextpop=pop(index(1:popsize));
    if etiNum>0
        nextpop(end-etiNum+1:end) = etiSet; 
    end
else % Surrogate model is used
% extract the best f indiviudals from feasible individuals, 
% and extract the worst (n-f) indiviudals from infeasible individuals.

% 1. distinguish feasible and infeasible sulotions
    [feaspop,infeaspop]=split(pop);
% 2. determined alpha required in DIS
    alpha=opt.sortingfun{1,2};

    if alpha>1
        warning ('alpha in DIS is larger than 1, which should be in [0 1].')
        alpha=min(1,alpha);
%     elseif alpha==0
%         error ('alpha in DIS must be larger than 0, which should be in [0 1].')
    end

    infeasNum=round(alpha*popsize);
    feasNum=popsize-infeasNum;
    
% 3. extract (1-alpha)N feasible solutions
     % sort infeasible solution based on objective values. Required by DIS
     % sorting
     if ~isempty (infeaspop)
         [~,ind2]=sort(vertcat(infeaspop.obj));
     else
         ind2=[];
     end
     if length(feaspop)>=feasNum %top (1-alpha)*popsize feasible data are selected.
        [~,ind1]=sort(vertcat(feaspop.fitness)); 
        feasSet=feaspop(ind1(1:feasNum)); % the first feasNum minimum values       
    else
        need=feasNum-length(feaspop);
        feasSet=[feaspop,infeaspop(ind2(infeasNum+1:infeasNum+need))];       
     end  
    
% 4. extract a*N infeasible solutions
    if length(infeaspop)>=infeasNum %top alpha*popsize infeasible data are selected.
        infeasSet=infeaspop(ind2(1:infeasNum)); % the first feasNum minimum values       
    else
        need=infeasNum-length(infeaspop);
        infeasSet=[infeaspop,feaspop(ind1(feasNum+1:feasNum+need))];       
    end  
%5. Add etilism    
    if etiNum>0
        feasSet(end-etiNum+1:end) = etiSet; 
    end
% 6. extract next pop
    
    nextpop=[feasSet,infeasSet];
end

end

