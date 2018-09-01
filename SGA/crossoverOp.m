function pop = crossoverOp(opt, pop, state)
% Function: pop = crossoverOp(opt, pop, state)
% Description: Crossover operator. All of the individuals would do crossover, but
%   only "crossoverFraction" of design variables of an individual would changed.
%
%    Author: Yangyang Fu
%    Date: 07/03/2017
%*************************************************************************

%*************************************************************************
% 1. Check for the parameters
%*************************************************************************
% determine the crossover method
strfun = lower(opt.crossover{1});
numOptions = length(opt.crossover) - 1;
[crossoverOpt{1:numOptions}] = opt.crossover{2:end};

switch( strfun )
    case 'intermediate'
        fun = @crsIntermediate;
    case 'simulatedbinary'
        fun= @crsSimulatedbinary;
    case 'laplace'
        fun = @crsLaplace;
    otherwise
        error('GA:CrossoverOpError', 'No support crossover operator!');
end

nVar = opt.numVar;

% "auto" crossover fraction
if( ischar(opt.crossoverFraction) )
    if( strcmpi(opt.crossoverFraction, 'auto') )
        fraction = 2.0 / nVar;
    else
        error('GA:CrossoverOpError', 'The "crossoverFraction" parameter should be scalar or "auto" string.');
    end
else
    fraction = opt.crossoverFraction;
end


for ind = 1:2:length(pop)    % Popsize should be even number
    % Create children
    [child1, child2] = fun( pop(ind), pop(ind+1), fraction, crossoverOpt,opt );
    
    
    % Bounding limit
    child1.var = varlimit(child1.var, opt.lb, opt.ub);
    child2.var = varlimit(child2.var, opt.lb, opt.ub);
    
    pop(ind)     = child1;
    pop(ind+1)   = child2;
    
end

end

function [child1, child2] = crsIntermediate(parent1, parent2, fraction, options,opt)
% Function: [child1, child2] = crsIntermediate(parent1, parent2, fraction, options)
% Description: (For real coding) Intermediate crossover. (Same as Matlab's crossover
%   operator)
%       child = parent1 + rand * Ratio * ( parent2 - parent1)
% Parameters:
%   fraction : crossover fraction of variables of an individual
%   options = ratio
%
%*************************************************************************


if( length(options)~=1 || ~isnumeric(options{1}))
    error('GA:CrossoverOpError', 'Crossover operator parameter error!');
end

ratio = options{1};

child1 = parent1;
child2 = parent2;

nVar = length(parent1.var);
crsFlag = rand(1, nVar) < fraction;

randNum = rand(1,nVar);     % uniformly distribution

child1.var = parent1.var + crsFlag .* randNum .* ratio .* (parent2.var - parent1.var);
child2.var = parent2.var - crsFlag .* randNum .* ratio .* (parent2.var - parent1.var);

end

function [child1, child2] = crsSimulatedbinary(parent1, parent2,fraction,options,opt)
% Function:
% Discription:
%   Simulated binary crossover operator
%***********************************************************************

% SBX crossover operator incororating boundary constraints
if( length(options)~=1 || ~isnumeric(options{1}))
    error('GA:CrossoverOpError', 'Crossover operator parameter error!');
end

nVar = length(parent1.var);
lb=opt.lb;
ub=opt.ub;

etac=options{1};

epsilon=1e-12;

crsFlag = rand(1, nVar) < fraction;

child1 = parent1;
child2 = parent2;

if (isequal(parent1,parent2))==1 && rand(1)>0.5
    child1=parent1;
    child2=parent2;
else
    
    for i=1:nVar
        u=rand(1);
        if (u>=0.5) & (crsFlag~=0)
            y1=min(parent1.var(i),parent2.var(i));
            y2=max(parent1.var(i),parent2.var(i));
            
            if (y2-y1)>epsilon
                beta=1+2./(y2-y1).*min(y1-lb(i),ub(i)-y2);
                alpha=2-beta.^-(etac+1);
                z=rand(1);
                betaq=(z<=(1./alpha)).*(z.*alpha).^(1/(etac+1))+(z>(1./alpha)).*(1./(2 - z.*alpha)).^(1/(etac+1));
            else
                betaq=1;
            end
            child1.var(i)=0.5*((y1+y2)-betaq*(y2-y1));
            child2.var(i)=0.5*((y1+y2)+betaq*(y2-y1));
        else
            child1.var(i)=parent1.var(i);
            child2.var(i)=parent2.var(i);
        end
    end
    
    
end  
    
end

function [child1, child2] = crsLaplace(parent1, parent2,fraction,options,opt)
%CRSLAPLACE
%   Lapalace crossover oeprator
%
% Author; Yangyang Fu
% Email: yangyang.fu@colorado.edu
% History:
%   June 2017, First implementation
%%---------------------------------------------------------------------------
nVar = length(parent1.var);
a=options{1};
b_real=options{2};
b_integer=options{3};


%crossover fraction
crsFlag = rand(1, nVar) < fraction;

%create children
child1 = parent1;
child2 = parent2;

beta=zeros(1,nVar);
b=b_real*(opt.vartype==1)+b_integer*(opt.vartype==2);

if (isequal(parent1,parent2))==1 && rand(1)>0.5
    child1=parent1;
    child2=parent2;
else
    u=rand(1,nVar);
    r=rand(1,nVar);
    for i=1:nVar
       if r(i)<=1/2
           beta(i)=a-b(i)*log10(u(i));
       else
           beta(i)=a+b(i)*log10(u(i));
       end
       
    end
    child1.var=parent1.var + crsFlag .* beta .* abs(parent1.var-parent2.var); 
    child2.var=parent2.var + crsFlag .* beta .* abs(parent1.var-parent2.var);
    
end  



end
