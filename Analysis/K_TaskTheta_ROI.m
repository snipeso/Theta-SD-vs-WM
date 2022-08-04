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
Bands = P.Bands;
Sessions = P.Sessions;
Channels = P.Channels;
StatsP = P.StatsP;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Labels = P.Labels;

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
PlotProps.Figure.Padding = 20;
PlotProps.Axes.yPadding = 20;
PlotProps.Axes.xPadding = 20;

Indx_B = 2; % theta
Grid = [2, 5];
YLim = [-.75 1.9];
Indx_BL = 1; % the reference for SpaghettiO plots

figure('units','centimeters','position',[0 0 PlotProps.Figure.W3 PlotProps.Figure.Height*.4])
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
    
     set(legend, 'ItemTokenSize', [5 5])

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

 set(legend, 'ItemTokenSize', [5 5], 'location', 'northeast')
title('Front Effect Sizes', 'FontSize', PlotProps.Text.TitleSize)

% save
saveFig(strjoin({TitleTag, 'Means'}, '_'), Paths.Paper, PlotProps)



%% Plot participants by order

Coordinates = [1 1; 1 2; 1 3; 2 1; 2 2; 2 3]; % stupd way of dealing with grid indexing
Indx_Ch = 1;
Indx_B = 2;
Grid = [2 3];
PlotProps = P.Manuscript;

Colors = repmat(getColors(1, '', 'yellow'), numel(P.Participants), 1);
Colors([1 5 12 end], :) = repmat(getColors(1, '', 'blue'), 4, 1);
% YLim = [-1.1 3.8];
YLim = [];


figure('units','centimeters','position',[0 0 PlotProps.Figure.W3 PlotProps.Figure.Height*.5])
for Indx_T = 1:numel(AllTasks)

  Data = squeeze(bData(:, :, Indx_T, Indx_Ch, Indx_B));
    
    subfigure([], Grid, Coordinates(Indx_T, :), [], true, '', PlotProps);
Stats = groupDiff(Data, Sessions.Labels, [], YLim, Colors, [], PlotProps);
  title(TaskLabels{Indx_T}, 'FontSize', PlotProps.Text.TitleSize)

axis tight
xlim([.5 numel(Sessions.Labels)+.5])
if Indx_T == 1

    legend({ 'SD First', 'BL First'}, 'location', 'northwest')
     set(legend, 'ItemTokenSize', [7 7])

end
if Indx_T < 4
         set(gca, 'XTickLabel', [])
end

end

saveFig(strjoin({TitleTag, 'OrderEffect'}, '_'), Paths.Paper, PlotProps)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

