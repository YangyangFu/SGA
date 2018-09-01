function [y,cons] = P8(x)
% Test function 8: a real constrained optimization problem. This is the 8th
% test problem in the reference.
% Description:
%   x1~x3: Real
%   x4~x7: Integer, 0 or 1
% The global solution is (0.2,1.280624,1.954483,1,0,0,1) and y=3.557463
% Reference: 
%   Deep, Kusum, et al. "A real coded genetic algorithm for solving integer
%         and mixed integer optimization problems." Applied Mathematics 
%         and Computation 212.2 (2009): 505-518.
% ----------------------------------------------------------------------
% Objective 
y = (x(1)-1)^2+(x(2)-2)^2+(x(3)-3)^2+sum((x(4:6)-1).^2)-log(x(7)+1);

% constraints
cons=zeros(1,9);
cons(1)=sum(x(1:6))-5;
cons(2)=x(1)^2+x(2)^2+x(3)^2+x(6)^2-5.5;
cons(3)=x(4)+x(1)-1.2;
cons(4)=x(5)+x(2)-1.8;
cons(5)=x(6)+x(3)-2.5;
cons(6)=x(7)+x(1)-1.2;
cons(7)=x(5)^2+x(2)^2-1.64;
cons(8)=x(6)^2+x(3)^2-4.25;
cons(9)=x(5)^2+x(3)^2-4.64;


