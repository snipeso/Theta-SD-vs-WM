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

WelchWindow = 8;
TitleTag = strjoin({'Task', 'Topos', 'vs' 'Fixation', 'Welch', num2str(WelchWindow), 'zscored'}, '_');

Results = fullfile(Paths.Results, 'Task_vs_Rest_Topographies');
if ~exist(Results, 'dir')
    mkdir(Results)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(P.Paths.Data, 'EEG', ['Unlocked_' num2str(WelchWindow)]);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath);

% z-score it
zData = zScoreData(AllData, 'last');

% save it into bands
bData = bandData(zData, Freqs, Bands, 'last');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

BandLabels = fieldnames(Bands);
BL_CLabel = 'A.U.';
CLims_BL = [ -10 10;
    -10 10;
    -10 10;
    -20 20;
    -20 20];
CLims_Diff = [-10 10];

%% Plot all topo changes together

for Indx_B = 1:numel(BandLabels)
    for Indx_T = 1:numel(AllTasks)
        figure('units','normalized','outerposition',[0 0 .5 .5])
        
        % plot baseline topography
        Data = squeeze(bData(:, 1, Indx_T, :, Indx_B));
        
        subplot(2, 3, 1)
        plotTopo(nanmean(Data, 1), Chanlocs, CLims_BL(Indx_B, :), BL_CLabel, 'Divergent', Format)
        title(strjoin({'BL', TaskLabels{Indx_T}, BandLabels{Indx_B}}, ' '), ...
            'FontSize', 14)
        
        % plot change from BL
        for Indx_S = [2,3]
            Data2 = squeeze(bData(:, Indx_S, Indx_T, :, Indx_B));
            
            subplot(2, 3, Indx_S)
            plotTopoDiff(Data, Data2, Chanlocs, CLims_Diff, Format);
            title(strjoin({Sessions.Labels{Indx_S}, 'vs BL', TaskLabels{Indx_T}, BandLabels{Indx_B}}, ' '), ...
                'FontSize', 14)
        end
        
        % plot change from Fix
        for Indx_S = 1:numel(Sessions.Labels)
            if Indx_T == numel(AllTasks) % skip for fixation
                continue
            end
            
            Data1 = squeeze(bData(:, Indx_S, end, :, Indx_B));
            Data2 = squeeze(bData(:, Indx_S, Indx_T, :, Indx_B));
            
            subplot(2, 3, Indx_S+3)
            plotTopoDiff(Data1, Data2, Chanlocs, CLims_Diff, Format);
            title(strjoin({Sessions.Labels{Indx_S}, TaskLabels{Indx_T}, 'vs', Sessions.Labels{Indx_S}, 'Rest'}, ' '), ...
                'FontSize', 14)
        end
        
        % save
        saveFig(strjoin({TitleTag, 'Diffs', TaskLabels{Indx_T}, BandLabels{Indx_B}}, '_'), Results, Format)
    end
end