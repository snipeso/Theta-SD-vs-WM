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
clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

ROI = 'preROI';

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
AllTasks = {'Match2Sample', 'LAT', 'PVT', 'SpFT', 'Game', 'Music'};
TaskLabels = {'STM', 'LAT', 'PVT', 'Speech', 'Game', 'Music'};
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
Channels = P.Channels;
StatsP = P.StatsP;

PeakRange = [3 15];

WelchWindow = 8;
TitleTag = strjoin({'Task', 'ANOVA', num2str(WelchWindow), 'zScored'}, '_');

Results = fullfile(Paths.Results, 'Task_ANOVA');
if ~exist(Results, 'dir')
    mkdir(Results)
end


ChLabels = fieldnames(Channels.(ROI));
BandLabels = fieldnames(Bands);
FactorLabels = {'Session', 'Task'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(P.Paths.Data, 'EEG', ['Unlocked_' num2str(WelchWindow)]);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);

% z-score it
zData = zScoreData(AllData, 'last');

% average channel data into 2 spots
chData = meanChData(zData, Chanlocs, Channels.(ROI), 4);

% average frequencies into bands
bData = bandData(chData, Freqs, Bands, 'last');

% somehow, data is not NaNed for p19 PVT, so something went wrong

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot & analyze data


%% plot map of channels

PlotChannelMap(Chanlocs, Channels.(ROI), Format.Colors.AllTasks, Format)
saveFig(strjoin({TitleTag, 'Channel', 'Map'}, '_'), Results, Format)


%%

for Indx_Ch = 1:numel(ChLabels)
    for Indx_B = 1:numel(BandLabels)
        
        Data = squeeze(bData(:, :, :, Indx_Ch, Indx_B));
        
        % plot spaghetti-o plot of tasks x sessions for each ch and each band
        
        
        
        % plot scatterbox plot of raw and z-scored data to show amplitudes
        
        
        % 2 way repeated measures anova with factors Session and Task
        Stats = anova2way(Data, FactorLabels, Sessions.Labels, TaskLabels, StatsP);
        
        % eta2 comparison for task and session to determine which has larger impact
        Title = strjoin({BandLabels{Indx_B}, ChLabels{Indx_Ch}, '2 way RANOVA Effect Sizes'}, ' ');
        
        figure('units','normalized','outerposition',[0 0 .2 .3])
        plotANOVA2way(Stats, FactorLabels, StatsP, Format)
        title(Title)
%         saveFig(strjoin({TitleTag, 'eta2', BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_'), Results, Format)
        
        % if interaction:
        
        % cohen's d and CI comparison between SD and BL for each task
        
        % and pairwise amplitude comparisons (nodePlot) at BL and SD across tasks
        
    end
end