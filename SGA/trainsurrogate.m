function [ net,surrogateOpt] = trainsurrogate( trainX,trainY,surrogateOpt,opt)
%TRAINSURROGATE
%   Train surrogate model using X and y. Three surrogate models are provided: RBF network, SVM, 
%	and backprogation nueral network.
%
% Author: Yangyang Fu
% Email: yangyang.fu@colorado.edu
% History:
%  August 2017, First implementation by Yangyang Fu
% --------------------------------------------------------------------

% get model index
model=surrogateOpt.model{1,1};

% vartype=opt.vartype;

% structure parameters
% numVar=surrogateOpt.numVar;
% numObj=surrogateOpt.numObj;


switch model
    % The following codes need updates.
    %case 'rbf' % Probably doesnt work now.
    %    activationFun=surrogateOpt.model{1,2};
    %    nhidden=surrogateOpt.model{1,3};
    %    distFun=surrogateOpt.model{1,5};
    %    outFun=surrogateOpt.model{1,4};
    %    centermodel=surrogateOpt.model{1,6};
    %    % Create and initialize network weight and parameter vectors.
    %    net = rbf(numVar, nhidden, numObj, activationFun,outFun,distFun,centermodel,vartype);
    %    % Use fast training method
    %    options = foptions;
    %    options(1) = 1;		% Display EM training
    %    options(14) = 10;	% number of iterations of EM
    %    net = rbftrain(net, options, trainX,trainY);
		
    case 'svm'
        optimizer=surrogateOpt.model{1,2};
        if ~ischar(optimizer)
            warning ('Optimizer for SVM has not been pre-defined.')
            warning ('Default optimizer grid search is used!')
            optimizer='gs';
        end
        options.optimizer=optimizer;
        options.scale=1;
        net=svrtrain(trainX,trainY,options);
    case 'bpann' % The parameters need to be progated to parameter settings. - to-do-list
        net=bpanntrain(trainX,trainY);
    
	otherwise
        error('surrogate model do not exist!')
end

end

