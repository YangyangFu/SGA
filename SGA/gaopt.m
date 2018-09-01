function defaultopt = gaopt()
% Function: defaultopt = nsgaopt()
% Description: Create NSGA-II default options structure.
% Syntax:  opt = nsgaopt()
%    Author: Yangyang Fu
%    Date: 07/03/2017
%*************************************************************************


defaultopt = struct(...
    ... % Algorithm
    'algorithm','rga',...
    ... % Optimization model
    'popsize', 50,...           % population size
    'maxGen', 100,...           % maximum generation
    'numVar', 0,...             % number of design variables
    'numObj', 0,...             % number of objectives
    'numCons', 0,...            % number of constraints
    'lb', [],...                % lower bound of design variables [1:numVar]
    'ub', [],...                % upper bound of design variables [1:numVar]
    'vartype', [],...           % variable data type [1:numVar]??1=real, 2=integer
    'objfun', @objfun,...       % objective function
    'consfun',@constrainfun,... % constraint function
    ... % Optimization model components' name
    'nameObj',{{}},...
    'nameVar',{{}},...
    'nameCons',{{}},...
    'etilism',0.02,... % ratio of etilism from last generation
    ... % Initialization and output
    'initfun', {{@initpop}},...         % population initialization function (use random number as default)
    'initpop',[],...                    % initial individuals provided by the user
    'outputfuns',{{@output2file}},...   % output function
    'outputfile', 'populations.txt',... % output file name
    'outputInterval', 1,...             % interval of output
    'plotInterval', 10,...               % interval between two call of "plotnsga".
    ... % Genetic algorithm operators
    'crossover', {{'intermediate', 1.2}},...         % crossover operator (Ratio=1.2)
    'mutation', {{'gaussian',0.1, 0.5}},...          % mutation operator (scale=0.1, shrink=0.5)
    'crossoverFraction', 'auto', ...                 % crossover fraction of variables of an individual
    'mutationFraction', 'auto',...                   % mutation fraction of variables of an individual
    ...% Sorting function
    'sortingfun',{{'nds',0}},...                      % default sorting function is non-dominated sorting;options include 'dis', 'nds'.
    ... % Algorithm parameters
    'useParallel', 'no',...                          % compute objective function of a population in parallel. {'yes','no'}
    'poolsize', 0,...                                % number of workers use by parallel computation, 0 = auto select.
    ... % R-NSGA-II parameters
    'refPoints', [],...                              % Reference point(s) used to specify preference. Each row is a reference point.
    'refWeight', [],...                              % weight factor used in the calculation of Euclidean distance
    'refUseNormDistance', 'front',...                % use normalized Euclidean distance by maximum and minumum objectives possiable. {'front','ever','no'}
    'refEpsilon', 0.001, ...    % parameter used in epsilon-based selection strategy
    ...% Surrogate parameters
    'surrogate',struct(...
    ...% surrogate strategy parameter
    'use',0,...% Whether surrogate is used in operation,0-no;1-yes
    'miu',50,...% when use a surrogate model, lamda=2*miu is set as default,otherwise, lamda=miu;
    'lamda',100),...
    'configuration',[],... % configuration files path for reading input for expensive simulation
    'maxExpEva',6000 ... % Maximum expensive evaluation 
    );



