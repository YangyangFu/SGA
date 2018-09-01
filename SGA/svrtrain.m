function model=svrtrain(trainX,trainY,options)
%Function SVRTRAIN trains support vector regression model.
%
% Author: Yangyang Fu
% Email: yangyang.fu@colorado.edu
% History:
%  August 2017, First implementation by Yangyang Fu
% --------------------------------------------------------------------

%% options
if nargin < 3
    options.optimizer = 'gs';
    options.scale = 1; 
end


% options.scale = 0 or 1
if options.scale == 1
    [YScaled,XScaled,model] = scale(trainY,trainX,0,1);
else
    YScaled=trainY;
    XScaled=trainX;
    model.ps.y=[];
    model.ps.x=[];
end

%% optimzer
%OPTIMIZER FOR SVR Parameter c and g. The optimizer only support grid search now.
optimizer=options.optimizer;
switch optimizer
    case 'gs'
        [bestCVmse,bestc,bestg] = SVMcgForRegress(YScaled,XScaled,-8,8,-8,8,5,0.4,0.4);
        cmd = ['-c ',num2str(bestc),' -g ',num2str(bestg),' -s 3 -p 0.01'];
    otherwise
        error('user-provided optimizer in svr do not exist!')
end

%% Train the SVR Model
% svmtrain is from libsvm pacakge
model.svm = svmtrain(YScaled,XScaled,cmd);

end


