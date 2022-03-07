% This script hosts the main analyses for the paper regarding the task
% comparison. % It runs a 2 way anova between task and session to determine
% if there's an interaction. If not, will plot eta-squared for Task and Session to
% determine which had a larger effect. If yes, will plot cohen's d for each
% task SD-BL to show which has the largest effects. Does this seperately
% for generic frontspot and generic backspot. Does this also for all bands,
% but the only one we care about is theta, so no need for pairwise
% correction.
% will plot spaghetti-o plots for tasks and SD.
% Plots the scatter+whisker plot for individuals raw and z-scored to show
% magnitude of theta.
clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

ROI = 'preROI';

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
Bands = P.Bands;
Sessions = P.Sessions;
Channels = P.Channels;
StatsP = P.StatsP;
PlotProps = P.Manuscript;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Labels = P.Labels;

TASKTYPE = 'Main';

ChLabels = fieldnames(Channels.(ROI));
BandLabels = fieldnames(Bands);
FactorLabels = {'Session', 'Task'};

Duration = 4;
WelchWindow = 8;

Tag = ['window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = 'F_TaskTheta_ROI';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);

% z-score it
zData = zScoreData(AllData, 'last');

% average channel data into 2 spots
chData = meanChData(zData, Chanlocs, Channels.(ROI), 4);

% average frequencies into bands
bData = bandData(chData, Freqs, Bands, 'last');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure

%% Figure MAGZ Theta changes for ROIs
PlotProps = P.Manuscript;
PlotProps.Figure.Padding = 50;
PlotProps.Axes.yPadding = 40;
PlotProps.Axes.xPadding = 40;

Indx_B = 2; % theta
Grid = [2, 5];
YLim = [-.75 1.9];
Indx_BL = 1; % the reference for SpaghettiO plots

figure('units','centimeters','position',[0 0 PlotProps.Figure.Width PlotProps.Figure.Height*.4])
Indx = 1; % tally of axes

%%% change in means
for Indx_Ch = 1:numel(ChLabels)
    
    subfigure([], Grid, [2, Indx_Ch], [2, 1], true, PlotProps.Indexes.Letters{Indx}, PlotProps);
    Indx = Indx+1;
    
    Data = squeeze(bData(:, :, :, Indx_Ch, Indx_B));
    
    % plot spaghetti-o plot of tasks x sessions for each ch and each band
    data3D(Data, Indx_BL, Sessions.Labels, TaskLabels, ...
        PlotProps.Color.AllTasks, StatsP, PlotProps);
    ylim(YLim)
    
    % plot labels only in specific plots
    if Indx_Ch == 1
        ylabel(Labels.zPower)
        legend off
    elseif Indx_Ch ~= 2
        legend off
    end
    
    title(ChLabels{Indx_Ch}, 'FontSize', PlotProps.Text.TitleSize)
    
    % 2 way repeated measures anova with factors Session and Task
    Stats = anova2way(Data, FactorLabels, Sessions.Labels, TaskLabels, StatsP);
    TitleStats = strjoin({TitleTag, ChLabels{Indx_Ch}, 'rmANOVA'}, '_');
    saveStats(Stats, 'rmANOVA', Paths.PaperStats, TitleStats, StatsP)
end


%%% difference at baseline
Data = squeeze(bData(:, 1, :, 1, Indx_B));
MEANS = nanmean(Data);
[~, Order] = sort(MEANS, 'descend');

subfigure([], Grid, [1, Indx_Ch+1], [1, Grid(2)-Indx_Ch], true, PlotProps.Indexes.Letters{Indx}, PlotProps);
Indx = Indx+1;
data2D('box', Data(:, Order), TaskLabels(Order), [], [], ...
    PlotProps.Color.AllTasks(Order, :), StatsP, PlotProps);
ylabel(Labels.zPower)
title('BL Front Means', 'FontSize', PlotProps.Text.TitleSize)


% effect sizes
subfigure([], Grid, [2, Indx_Ch+1], [1, Grid(2)-Indx_Ch], true, PlotProps.Indexes.Letters{Indx}, PlotProps);

Data = squeeze(bData(:, :, :, 1, Indx_B)); % for front
Stats = plotES(Data, 'horizontal', true, PlotProps.Color.AllTasks, TaskLabels, ...
    {'SR vs BL', 'SD vs BL'}, PlotProps, StatsP, Labels);

title('Front Effect Sizes', 'FontSize', PlotProps.Text.TitleSize)

% save
saveFig(strjoin({TitleTag, 'Means'}, '_'), Paths.Paper, PlotProps)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

