function opt = callOutputfuns(opt, state, pop, type)
% Function: opt = callOutputfuns(opt, state, pop, type)
% Description: Call output function(if exist).
% Parameters: 
%   type : output type.  
%       -1 = the last call (close file for instance)
%       other values(or no exist) = normal output
%
%    Author: Yangyang Fu
%    Date: 07/03/2017
%*************************************************************************


if(nargin <= 3)
    type = 0;   % normal output
end


if( ~isempty(opt.outputfuns) )
    fun = opt.outputfuns{1};
    opt = fun(opt, state, pop, type, opt.outputfuns{2:end});
end


