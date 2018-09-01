function [ surrogateOpt ] = getsurrogateOpt
%GETSURROGATEOPT Summary of this function goes here
%   Detailed explanation goes here

surrogateOpt=struct(...
    ... %fitness approximation management parameters
    'miu',50,...
    'lamda',100,...
    ...% detemine which objective and constraint need surrogate model; 
    'consSurrogateIndex',[1],...
    ...%surrogate method
    'model',{{'rbf','gaussian',5,'linear','euclidean','kmeans'}},...% which model is used and what's the parameter,e.g. rbf network needs an activation function and hidden neural number.
    'sigma',1,...
    ...% surrogate data
    'numVar',[],...% number of variables;
    'numObj',[],...;% number of output in surrogate model;
    ...
    'perfFun','spearman',...% performance function 
    'performance',0,...% performance value
    'traindataAll',[],... % train data X
    'truefitnessAll',[],...% train data Y - fitness
    'trueconstraintAll',[]); % train data Y - constraints



end

