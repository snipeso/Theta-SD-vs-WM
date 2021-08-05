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
TitleTag = strjoin({'Task', 'Topos', 'Welch', num2str(WelchWindow), 'zScored'}, '_');

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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data


%% Plot spectrums as task x ch coloring all channels




%% plot all participants' spectrums ch x session, one fig per task



%% for each task, get peak frequency for every session, and every change with SD for all channels





%% Plot theta peak pairwise compared to each channel


%% plot theta for each channel compared to each session and session change


%% do the same from above but with theta determined by individual alpha frequency





