% This script plots all the tasks' change from baseline (fixation post), to
% indicate whether the change with sleep deprivation within tasks matches
% their task-specific theta.

% Predictions:
% If SHY hypothesis is true: SD increases in theta should have the
% same topography as BL theta, but with larger amplitude.
% If COMP/ALPHA hypothesis is true: both some tasks (especially WM) and all SD
% conditions should just have a frontal hotspot of theta
% If LS/N1 hypothesis is true, general frontal increase in SD, independant of
% theta in tasks.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

Baseline_Task = 'Fixation';
Baseline_Session = 'BaselinePost';

WelchWindow = 10;
TitleTag = strjoin({'Task', 'Topos', 'vs' Baseline_Task, 'Welch', num2str(WelchWindow), 'zscored'}, '_');


Results = fullfile(Paths.Results, 'Task_vs_Rest_Topographies');
if ~exist(Results, 'dir')
    mkdir(Results)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Load_All_Power % results in variable "AllData"; P x S x T x Ch x F

% z-score it
zData = ZscoreData(AllData, 'last');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data


%%% Plot participants' baselines, as a control that it's all reasonable
% spectrograms

% DTAB topographies


%%% plot BL, SD1, SD2 topographies of DTAB







