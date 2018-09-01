function [predY]=svrpredict(model,X,Y)
%Function SVRPREDICT calculate the predicted value of svr model.
%
% Author: Yangyang Fu
% Email: yangyang.fu@colorado.edu
% 
%****************************************************************


if isempty(Y)
    
    Y=ones(size(X,1),1);
end

if ~isempty(model.ps.y)
   YScaled=mapminmax('apply',Y',model.ps.y); 
   YScaled=YScaled';
else
   YScaled=Y; 
end
if ~isempty(model.ps.x)
   XScaled=mapminmax('apply',X',model.ps.x); 
   XScaled=XScaled';
else
   XScaled=X;
end
[predYScaled] = svmpredict(YScaled,XScaled, model.svm);

if ~isempty(model.ps.y)
   predY=mapminmax('reverse',predYScaled',model.ps.y);
   predY=predY';
else
   predY=predYScaled;
end
end