% This script hosts the main analyses for the paper regarding the task
% comparison. % It runs a 2 way anova between task and session to determine
% if there's an interaction. If not, will plot eta-squared for T and S to
% determine which had a larger effect. If yes, will plot cohen's d for each
% task SD-BL to show which has the largest effects. Does this seperately
% for generic frontspot and generic backspot. Does this also for all bands,
% but the only one we care about is theta, so no need for pairwise
% correction.
% will plot spaghetti-o plots for tasks and SD. 
% Plots the scatter+whisker plot for individuals raw and z-scored to show
% magnitude of theta.


% Gather data


% z-score data


% average channel data into 2 spots


% average frequencies into bands


% plot map of channels


% plot spaghetti-o plot of tasks x sessions for each ch and each band



% plot scatterbox plot of raw and z-scored data to show amplitudes


% 2 way repeated measures anova with factors Session and Task


% if no interaction:

% eta2 comparison for task and session to determine which has larger impact




% if interaction:

% cohen's d and CI comparison between SD and BL for each task

% and pairwise amplitude comparisons (nodePlot) at BL and SD across tasks