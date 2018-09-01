function [popfeasible,popinfeasible]=split(pop)
% Function SPLIT decompose the given pop into two subsets: feasible set and
% infeasible set. This function is used when DIS is used.
%
%
%**************************************************************************
%if strcmp(opt.sortingFun{1,1},'dis')==0
%    error('There is no need to use function "split" without DIS sorting !')
%end

% 1. Initialize variables
%
%******************************************************************
N=length(pop);


% 2. Split the pop into feasible and infeasible subsets.
%
%*****************************************************************

nViol   = zeros(N, 1);

popfeasible=[];
popinfeasible=[];

for i = 1:N
    nViol(i)    = pop(i).nViol;
    if nViol(i)==0
        popfeasible=[popfeasible,pop(i)];
    else
        popinfeasible=[popinfeasible,pop(i)];
    end
end

