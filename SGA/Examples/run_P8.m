options = gaopt();                    % create default options structure
options.popsize = 120;                   % populaion size
options.maxGen  = 60;                  % max generation
options.maxExpEva = 8000;              % maximum expensive number

options.numObj = 1;                     % number of objectives
options.numVar = 7;                     % number of design variables
options.numCons = 9;                    % number of constraints
options.lb = [0,0,0,0,0,0,0];                  % lower bound of x
options.ub = [1.2,1.8,2.5,1,1,1,1];                  % upper bound of x
options.objfun = @P8;     % objective function handle
options.consfun = @P8;
options.plotInterval = 10;               % interval between two calls of "plotnsga". 

options.crossover={'laplace',0,0.15,0.35};
options.crossoverFraction=0.8;
options.mutation={'power',10,4};
options.mutationFraction=0.2;

options.sortingfun={'fit',0.05};

options.vartype=[1,1,1,2,2,2,2];
options.useParallel='no';
options.poolsize=2;
options.initpop=[];%[0.5 4;0.4 4];

options.surrogate.use=1;
miu=options.popsize;
lamda=3*miu;

options.surrogate.miu=miu;
options.surrogate.lamda=lamda;

surrogateOpt=getsurrogateOpt;

nhidden=round(miu/3); % this is for neural network model. Not for svm.
surrogateOpt.numVar=options.numVar;
surrogateOpt.numObj=options.numObj;
surrogateOpt.model{1,1}='svm'; % svm surrogate model
surrogateOpt.model{1,2}='gs'; % grid search to train svm model
surrogateOpt.model{1,3}=nhidden; % neurons in hidden layer of an ANN surrogate model
surrogateOpt.model{1,5}='euclidean'; % 
surrogateOpt.model{1,6}='kmedoids';
surrogateOpt.perfFun='spearman';

surrogateOpt.consSurrogateIndex=[];

%configuration path for calling in and out files by simulation software.
%Used when there are shared files between parallel computing.
options.configuration=[];

[result,surrogateOpt] = ga(options,surrogateOpt);                % begin the optimization!