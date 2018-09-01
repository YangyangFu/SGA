function state = statpop(opt,pop, state)
% Function: state = statpop(pop, state)
% Description: Statistic Population.
%
%    Author: Yangyang Fu
%    Date: 07/03/2017
%*************************************************************************


N = length(pop);
rankVec = vertcat(pop.rank);
rankVec = sort(rankVec);

state.frontCount = rankVec(N);
state.firstFrontCount = length( find(rankVec==1) );

% worst feasible solution when nObj==1

feas=zeros(N);
if length(pop(1).obj) == 1
    for i = 1:N
      if pop(i).nViol==0 
      feas(i) = pop(i).obj;
      end
    end
   state.worstFeas = max(feas); 
end

% statistics for single-objective optimization
% individual current best

if opt.numObj==1
    fitness=vertcat(pop.fitness);
    cons=vertcat(pop.violSum);
    
    for i=1:N
    individual(i,:)=pop(i).var;
    end
    % best fitness in current generation
    [state.bestfitness,ind]=min(fitness);
    % best individual in current generation
    state.bestindividual=individual(ind,:); 
    
    % range
    state.minfitness=state.bestfitness;
    state.maxfitness=max(fitness);
    state.averagefitness=mean(fitness);
    
    % max constraint: plot the maximum constraints
    state.maxconstraint=max(cons);
    
    % add fitness 
    state.fitness=fitness;
end

end



