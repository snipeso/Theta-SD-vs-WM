% this script plots the spectrums of EEG for specific channels and how the
% theta peak changes with conditions.

clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
Channels = P.Channels;

WelchWindow = 10;
TitleTag = strjoin({'Task', 'Spectrums', 'Welch', num2str(WelchWindow), 'zScored'}, '_');

Results = fullfile(Paths.Results, 'Task_Spectrums');
if ~exist(Results, 'dir')
    mkdir(Results)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

[AllData, Freqs, Chanlocs] = loadAllPower(P);

% z-score it
zData = zScoreData(AllData, 'last');

% average across channels
chData = meanChData(zData, Chanlocs, Channels.Peaks, 4);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

ChLabels = fieldnames(Channels.Peaks);

%% Plot spectrums as task x ch coloring all channels

Colors = [Format.Colors.Dark1; Format.Colors.Red; Format.Colors.Light1];

figure('units','normalized','outerposition',[0 0 1 1])
Indx = 1;
for Indx_Ch = 1:numel(ChLabels)
    for Indx_T = 1:numel(AllTasks)
        Data = squeeze(chData(:, :, Indx_T, Indx_Ch, :));
        
        subplot( numel(ChLabels), numel(AllTasks), Indx)
        plotSpectrumDiff(Data, Freqs, 1, Bands, Sessions.Labels, Colors, Format)
        title(strjoin({ChLabels{Indx_Ch}, TaskLabels{Indx_T}}, ' '))
        Indx = Indx+1;
    end
end

setLims(numel(ChLabels), numel(AllTasks), 'y')

% save
saveFig(strjoin({TitleTag, 'Channel', 'Sessions'}, '_'), Results, Format)

% plot all tasks, split by session, one fig for each ch


%% plot all participants' spectrums ch x session, one fig per task

for Indx_Ch =  1:numel(ChLabels)
    figure('units','normalized','outerposition',[0 0 1 .5])
    for Indx_S = 1:numel(Sessions.Labels)
         Data = squeeze(chData(:, Indx_S, :, Indx_Ch, :));
         
       subplot(1, numel(Sessions.Labels), Indx_S)
        plotSpectrumDiff(Data, Freqs, numel(TaskLabels), Bands, TaskLabels, Format.Colors.AllTasks, Format)
        title(strjoin({ChLabels{Indx_Ch}, Sessions.Labels{Indx_S}}, ' '))
    end
    setLims(1, numel(Sessions.Labels), 'y')

    saveFig(strjoin({TitleTag, 'Channel', 'Tasks', ChLabels{Indx_Ch}}, '_'), Results, Format)

end


%% for each task, get peak frequency for every session, and every change with SD for all channels





%% Plot theta peak pairwise compared to each channel


%% plot theta for each channel compared to each session and session change


%% do the same from above but with theta determined by individual alpha frequency





