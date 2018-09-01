function var = varlimit(var, lb, ub)
% Function: var = varlimit(var, lb, ub)
% Description: Limit the variables in [lb, ub].
%
%    Author: Yangyang Fu
%    Date: 07/03/2017
%*************************************************************************

numVar = length(var);
for i = 1:numVar
    var(i)=min(max(var(i),lb(i)),ub(i));
end

