
function [performance,surrogateOpt]=surrogateperf(target,predTarget,surrogateOpt)
%Performance function:
%	calculate the surrogate model performance. The metric can be chosen from spearman 
%	correlation coefficient, or product moment. Users can define their own performance
%	metrics.
%
% Author: Yangyang Fu
% Email: yangyang.fu@colorado.edu
%History:
%  August 2017, First implementation by Yangyang Fu
% -------------------------------------------------------------------------------

if nargin<3
    performanceFun='spearman';
else
    
    performanceFun=surrogateOpt.perfFun;
end

r=corrcoefficient(target,predTarget,performanceFun);

performance=r;

end
