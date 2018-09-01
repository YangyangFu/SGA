function [ output_args ] = plotga( result,ngen,axe1,axe2)
%PLOTGA
%   Simple plot for GA
% 
%
%-----------------------------------------------------

% plot best fitness
maxGen=result.opt.maxGen;
curGen=ngen;
for i=1:curGen
fitness(i,:)=result.states(i).fitness;
bestfitness(i,:)=result.states(i).bestfitness;
end

plot(axe1,1:curGen,bestfitness,'-k*',...
    'LineWidth',1,...
    'MarkerSize',4,...
    'MarkerFaceColor',[0.5,0.5,0.5]);
title(axe1,'Best Fitness');
xlabel(axe1,'Generation');
xlim(axe1,[0,maxGen]);
ylabel(axe1,'Best Fitness');


boxplot(axe2,fitness');
xlim(axe2,[0,maxGen]);
xticks([0:10:curGen]);
xticklabels([0:10:curGen]);
title(axe2,'Range');
xlabel(axe2,'Generation');
ylabel(axe2,'Range');

end

