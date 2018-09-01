function [pop, state] = evaluate(opt, pop, state)
% Function: [pop, state] = evaluate(opt, pop, state, varargin)
% Description: Evaluate the objective functions of each individual in the
%   population.
%
%    Author: Yangyang Fu
%    Date: 07/03/2017
%    Revisions:
%       2017-08-24: Add codes to avoid repeatedly evaluate the same
%                   individual in different generations.
%*************************************************************************

N = length(pop);
allTime = zeros(N, 1);  % allTime : use to calculate average evaluation times
conf=opt.configuration;
%*************************************************************************
% Evaluate objective function in parallel
%*************************************************************************

if( strcmpi(opt.useParallel, 'yes') == 1 )
    %curPoolsize = matlabpool('size');
    %matlabpool close
    curPool=gcp('nocreate');
    if isempty(curPool)
        curPoolsize=0;
    else
        curPoolsize =curPool.NumWorkers;
    end
    % There isn't opened worker process
    if(curPoolsize == 0)
        if(opt.poolsize == 0)
            parpool open local
        else
            parpool(opt.poolsize)
        end
    % Close and recreate worker process
    else
        if(opt.poolsize ~= curPoolsize)
            parpool close
            parpool(opt.poolsize)
        end
    end
    
    % add attached objective files to the pool
    p=gcp;
    objectivefun=func2str(opt.objfun);
    addAttachedFiles(p,{objectivefun});
   
    
    parfor i = 1:N
        fprintf('\nEvaluating the objective function... Generation: %d / %d , Individual: %d / %d \n', state.currentGen, opt.maxGen, i, N);
        [pop(i), allTime(i)] = evalIndividual(pop(i), opt.objfun,i,conf);
    end

%*************************************************************************
% Evaluate objective function in serial
%*************************************************************************
else
    for i = 1:N
        fprintf('\nEvaluating the objective function... Generation: %d / %d , Individual: %d / %d \n', state.currentGen, opt.maxGen, i, N);
        [pop(i), allTime(i)] = evalIndividual(pop(i), opt.objfun,i,conf);
    end
end

%*************************************************************************
% Statistics
%*************************************************************************
state.avgEvalTime   = sum(allTime) / length(allTime);
state.evaluateCount = state.evaluateCount + length(pop);




function [indi, evalTime,state] = evalIndividual(indi, objfun,index,conf,state)
% Function: [indi, evalTime] = evalIndividual(indi, objfun, varargin)
% Description: Evaluate one objective function.
%*************************************************************************

if indi.expensive==0
    % copy files to new tempory folder to avoid conflicts in parallel computing
    if ~isempty(conf)
        folderName=copyFiles(index,conf);
        
        % change working directory to temp folder
        cwd=pwd;
        cd ([cwd,'/',folderName]);
    end
    tStart = tic;
    [y, cons] = objfun( indi.var);
    indi.cons=cons;
    evalTime = toc(tStart);
    
    % Save the objective values and constraint violations
    indi.obj = y;
    if( ~isempty(indi.cons) )
        idx = find( cons>0 );
        if( ~isempty(idx) )
            indi.nViol = length(idx);
            indi.violSum = sum( abs(cons(idx)) );
        else
            indi.nViol = 0;
            indi.violSum = 0;
        end
    end
    
    if ~isempty(conf)
        cd ../
        % delete the temp folder
        rmdir(folderName,'s');
    end
    % change the flag to true
    indi.expensive=1;
else
    evalTime=0;
    % the flag keep to be true although it's not evaluated in current
    % generation
end

function folderName=copyFiles(folderIndex,conf)
% conf: configuration files that specify the input files, a cell.
% 
%
% Author; Yangyang Fu
% Email: yangyang.fu@colorado.edu
% History:
%	July 2018, First implementation by Yangyang Fu	
%------------------------------------------------------------------
    % create tempory folder
    % folder name:
    folderName=sprintf('temp-%d',folderIndex);
    mkdir(folderName);
    % copy specifed files
    for i=1:length(conf)
        copyfile(conf{i}, [folderName,'/',conf{i}]);
    end
    
    


