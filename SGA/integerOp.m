function pop=integerOp(opt, pop)
% Discription
% In order to ensure that, after crossover and mutation operations have
% been performed, the integer restrictions are satisfied, the following
% truncation procedure is applied
% 1. if x(i) is integer then x(i)=x(i),otherwise,
% 2. x(i) is equal to either [x(i)] or [x(i)]+1 each with probability 0.5, ([x(i)] is the integer part of x(i)).
% 
% Author; Yangyang Fu
% Email: yangyang.fu@colorado.edu
% History:
%   June 2017, First implementation
%
% Reference:
%   Kusum Deep, Krishna Pratap Singh, M.L. Kansal, C. Mohan, " A real coded
%   genetic algorithm for solving integer and mixed integer optimization problems",
%---------------------------------------------------------------------------

%% Integer Handling Method

popsize=length(pop);
nVar=opt.numVar;

if all(opt.vartype==1)
    return
end

for popIndex=1:popsize
    for v = 1:nVar
        if( opt.vartype(v) == 2)
            %child.var(v) = round( child.var(v) );
            if pop(popIndex).var(1,v)==fix(pop(popIndex).var(1,v))
                continue
            else
                RandIndex=rand(1,nVar);
                if RandIndex(v)>=0.5
                    pop(popIndex).var(1,v)= fix(pop(popIndex).var(1,v))+1;
                else
                    pop(popIndex).var(1,v)= fix(pop(popIndex).var(1,v));
                end
            end 
        end
    end
    % check the limit
    pop(popIndex).var = varlimit(pop(popIndex).var, opt.lb, opt.ub);
end

        
