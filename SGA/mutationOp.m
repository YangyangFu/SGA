function pop = mutationOp(opt, pop, state)
% Function: pop = mutationOp(opt, pop, state)
% Description: Mutation Operator. All of the individuals would do mutation, but
%   only "mutationFraction" of design variables of an individual would changed.
%
%    Author: Yangyang Fu
%    Date: 07/03/2017
%*************************************************************************

%*************************************************************************
% 1. Check for the parameters
%*************************************************************************
% mutation method
strfun = lower(opt.mutation{1});
numOptions = length(opt.mutation) - 1;
[mutationopt{1:numOptions}] = opt.mutation{2:end};

switch (strfun)
    case 'gaussian'
        fun = @mutationGaussian;
    case 'polynominal'
        fun = @mutationPolynominal;
    case 'power'
        fun = @mutationPower;
    otherwise
        error('GA:MutationOpError', 'No support mutation operator!');
end

nVar = opt.numVar;

% "auto" mutation fraction
if( ischar(opt.mutationFraction) )
    if( strcmpi(opt.mutationFraction, 'auto') )
        fraction = 2.0 / nVar;
    else
        error('GA:MutationOpError', 'The "mutationsFraction" parameter should be scalar or "auto" string.');
    end
else
    fraction = opt.mutationFraction;
end


% All of the individual would be modified, but only 'mutationFraction' of design
% variables for an individual would be changed.
for ind = 1:length(pop)
        child = fun( pop(ind), opt, state, fraction, mutationopt);

        child.var = varlimit(child.var, opt.lb, opt.ub);
        
        pop(ind) = child;
end

end

function child = mutationGaussian( parent, opt, state, fraction, options)
% Function: child = mutationGaussian( parent, opt, state, fraction, options)
% Description: Gaussian mutation operator. Reference Matlab's help :
%   Genetic Algorithm Options :: Options Reference (Global Optimization Toolbox)
% Parameters: 
%   fraction : mutation fraction of variables of an individual
%   options{1} : scale. This paramter should be large enough for interger variables
%     to change from one to another.
%   options{2} : shrink
% Return: 
%*************************************************************************


%*************************************************************************
% 1. Verify the parameters.
%*************************************************************************
if( length(options)~=2)
    error('GA:MutationOpError', 'Mutation operator parameter error!');
end


%*************************************************************************
% 2. Calc the "scale" and "shrink" parameter.
%*************************************************************************
scale = options{1};
shrink = options{2};
scale = scale - shrink * scale * state.currentGen / opt.maxGen;

lb = opt.lb;
ub = opt.ub;
scale = scale * (ub - lb);


%*************************************************************************
% 3. Do the mutation.
%*************************************************************************
child = parent;
numVar = length(child.var);
for i = 1:numVar
    if(rand() < fraction)
        child.var(i) = parent.var(i) + scale(i) * randn();
    end
end
end

function child = mutationPolynominal(parent,opt,state,probobility,options)
% Description
% 1. Input is the crossovered child of size (1,V) in the vector 'y' from 'genetic_operator.m'.
% 2. Output is in the vector 'mutated_child' of size (1,V)
%
% Author; Yangyang Fu
% Email: yangyang.fu@colorado.edu
% History:
%   June 2017, First implementation
%---------------------------------------------------------------------------
% Polynomial mutation including boundary constraint

child=parent;

nVar=length(parent);

lb=opt.lb;
ub=opt.ub;
etam=options{1};
del=min((parent.var-lb),(ub-parent.var))./(ub-lb);
t=rand(1,nVar);
mutationlocation=t<probobility;        
u=rand(1,nVar);
delq=(u<=0.5).*((((2*u)+((1-2*u).*((1-del).^(etam+1)))).^(1/(etam+1)))-1)+(u>0.5).*(1-((2*(1-u))+(2*(u-0.5).*((1-del).^(etam+1)))).^(1/(etam+1)));
child.var=parent.var+delq.*mutationlocation.*(ub-lb);

end

function child = mutationPower(parent,opt,state,probobility,options)
%MUTATIONPOWER
%   Power mutation operator
%
% Author; Yangyang Fu
% Email: yangyang.fu@colorado.edu
% History:
%   June 2017, First implementation
%---------------------------------------------------------------------------
p_real=options{1}; %10 
p_integer=options{2};%4

child=parent;
nVar=length(parent.var);

lb = opt.lb;
ub = opt.ub;

% power index
type=opt.vartype;
p = (type==1)*p_real + (type==2)*p_integer;


s1=rand(1,nVar);
r=rand(1,nVar);
s=s1.^p;

t=(parent.var-lb)./(ub-parent.var);

mutationlocation=rand(1,nVar)<probobility; %prob=0.005

child.var= (t<r).*(parent.var-mutationlocation.*s.*(parent.var-lb))+ ...
    (t>=r).*(parent.var+mutationlocation.*s.*(ub-parent.var));

end



