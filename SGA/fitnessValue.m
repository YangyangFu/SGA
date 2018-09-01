function [ opt, pop , state ] = fitnessValue( opt, pop, state )
%FITNESSVALUE This function calculates the fitness value of the individual
%in current generation. The algorithm is a parameter free constraint
%handling scheme which can help filter out the infeasible soultions.
%   
%This implementation is only used in single-objective GA
%
%   Author: Yangyang Fu
%   First Implementation: Aug 04, 2017
%   
%   Reference: K. Deb, An efficient constraint handling method for genetic 
%              algorithms, Computer Methods in Applied Mechanics and 
%              Engineering, 186 (2000), pp. 311-338
%========================================================================
n=size(pop,2);

feas=vertcat(pop.nViol);
feasIndex=feas==0;
obj=vertcat(pop.obj);
violSum=vertcat(pop.violSum);
if ~isempty(feasIndex)
    state.worstFeas=max(obj(feasIndex)); % worst feasible solution at current pops
end
    
for i=1:n 
    if pop(i).nViol==0 % feasible solution;
       pop(i).fitness=obj(i);
    else % infeasible solution
       pop(i).fitness=state.worstFeas+violSum(i);
    end
end
        
% The following codes are discarded because it doesn't work in my computer.        
%pop(feasIndex).fitness=obj(feasIndex);
%pop(infeasIndex).fitness=state.worstFeas+ violSum(infeasIndex);

end

