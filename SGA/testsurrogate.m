function [ testY,surrogateOpt] = testsurrogate( net,X,Y,surrogateOpt )
%TESTSURROGATE Summary of this function goes here
%   Detailed explanation goes here

% MODEL
surrmodel=surrogateOpt.model{1,1};

switch surrmodel  
   % case 'rbf'
   %     testY = rbffwd(net, X);
   %   
    case 'svm'
        
        if isfield(net,'performance')
            net=rmfield(net,'performance');
        end
        
        testY=svrpredict(net,X,Y);
    case 'bpann'
        testY=bpannpredict(net,X);
    otherwise
        error('Surrogate model does not exist!')
end


end

