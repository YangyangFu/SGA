function [mse,bestc,bestg] = SVMcgForRegress(train_label,train,cmin,cmax,gmin,gmax,v,cstep,gstep)
%SVMcg cross validation by faruto
%
% Author: Yangyang Fu
% Email: yangyang.fu@colorado.edu
% History:
%  August 2017, First implementation by Yangyang Fu
% 
% Reference:
%	Chih-Chung Chang and Chih-Jen Lin, LIBSVM : a library for
%	support vector machines, 2001. Software available at
%	http://www.csie.ntu.edu.tw/~cjlin/libsvm
% --------------------------------------------------------------------

%% about the parameters of SVMcg 
if nargin < 8
    cstep = 0.8;
    gstep = 0.8;
end
if nargin < 7
    v = 5;
end
if nargin < 5
    gmax = 8;
    gmin = -8;
end
if nargin < 3
    cmax = 8;
    cmin = -8;
end
%% X:c Y:g cg:acc
[X,Y] = meshgrid(cmin:cstep:cmax,gmin:gstep:gmax);
[m,n] = size(X);
cg = zeros(m,n);

eps = 10^(-4);

%% record acc with different c & g,and find the bestacc with the smallest c
bestc = 0;
bestg = 0;
mse = Inf;
basenum = 2;
for i = 1:m
    for j = 1:n
        cmd = ['-v ',num2str(v),' -c ',num2str( basenum^X(i,j) ),' -g ',num2str( basenum^Y(i,j) ),' -s 3 -p 0.01'];
        cg(i,j) = svmtrain(train_label, train, cmd);
        
        if cg(i,j) < mse
            mse = cg(i,j);
            bestc = basenum^X(i,j);
            bestg = basenum^Y(i,j);
        end
        
        if abs( cg(i,j)-mse )<=eps && bestc > basenum^X(i,j)
            mse = cg(i,j);
            bestc = basenum^X(i,j);
            bestg = basenum^Y(i,j);
        end
        
    end
end
%% to draw the acc with different c & g
[cg,ps] = mapminmax(cg,0,1);


figure;
meshc(X,Y,cg);
axis([cmin,cmax,gmin,gmax,0,1]);
xlabel('log2c','FontSize',8);
ylabel('log2g','FontSize',8);
zlabel('MSE','FontSize',8);
firstline = 'SVR-Grid Search'; 
secondline = ['Best c=',num2str(bestc),' g=',num2str(bestg), ...
    ' CVmse=',num2str(mse)];
title({firstline;secondline},'Fontsize',8);
