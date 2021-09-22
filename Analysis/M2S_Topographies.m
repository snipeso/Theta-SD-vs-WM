% script for plotting topoplots of the different trial epochs from the
% match2sample (short term memory) task. Compares 3 Items vs 1 and SD vs
% BL, and correct responses vs lapses


% Predictions:
% If theta is higher during incorrect answers (but only following SD) then
% this is evidence of local sleep impairing performance. If frontal theta is lower
% during incorrect answers, this is a sign that theta is a form of
% compensation and helps with performance.

clear
close all
clc


P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
StatsP = P.StatsP;
Channels = P.Channels;

Window = 2;
Task = 'Match2Sample';
Tag = ['w', num2str(Window)];

TitleTag = strjoin({'M2S', Tag, 'Topos'}, '_');

Results = fullfile(Paths.Results, 'M2S_Topographies', Tag);
if ~exist(Results, 'dir')
    mkdir(Results)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Locked', Task, Tag);
[AllData, Freqs, Chanlocs, AllTrials] = loadM2Spower(P, Filepath);

% z-score it
zData = zScoreData(AllData, 'last');

% save it into bands
bData = bandData(zData, Freqs, Bands, 'last');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data
BandLabels = fieldnames(Bands);
CLims_Diff = [-1.8 1.8];
[nParticipants, nSessions, nTrials, nEpochs, nCh, nFreqs] = size(AllData);

Epochs = Format.Labels.Epochs;

%% plot N3 vs N1 for every epoch

for Indx_S = 1:nSessions
    for Indx_B = 1:numel(BandLabels)
        figure('units','normalized','outerposition',[0 0 .75 .35])
        %         tiledlayout(1, nEpochs, 'Padding', 'none', 'TileSpacing', 'compact');
        
        for Indx_E = 1:nEpochs
            Data = squeeze(bData(:, Indx_S, :, Indx_E, :, Indx_B));
            
            N1 = averageTrials(Data, squeeze(AllTrials.level(:, Indx_S, :)) == 1);
            N3 = averageTrials(Data, squeeze(AllTrials.level(:, Indx_S, :)) == 3);
            
            %             nexttile
            subplot(1, 5, Indx_E)
            plotTopoDiff(N1, N3, Chanlocs, CLims_Diff, StatsP, Format);
            title(Epochs{Indx_E}, 'FontSize', Format.TitleSize)
            colorbar off
            
        end
        saveFig(strjoin({ TitleTag, 'N3vN1', BandLabels{Indx_B}, Sessions.Labels{Indx_S}}, '_'), Results, Format)
    end
end


figure('units','normalized','outerposition',[0 0 .25 .35])
plotColorbar( CLims_Diff, 'hedges g', Format)
saveFig(strjoin({TitleTag, 'Diff_Colorbar'}, '_'), Results, Format)


%% plot SD - BL for each epoch



for Indx_S = 2:nSessions
    for Indx_B = 1:numel(BandLabels)
        figure('units','normalized','outerposition',[0 0 .75 .35])
        %         tiledlayout(1, nEpochs, 'Padding', 'none', 'TileSpacing', 'compact');
        
        for Indx_E = 1:nEpochs

            BL = squeeze(nanmean(bData(:, 1, :, Indx_E, :, Indx_B), 3));
            SD = squeeze(nanmean(bData(:, Indx_S, :, Indx_E, :, Indx_B), 3));
            
            %             nexttile
            subplot(1, 5, Indx_E)
            plotTopoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Format);
            title(Epochs{Indx_E}, 'FontSize', Format.TitleSize)
            colorbar off
            
        end
        saveFig(strjoin({ TitleTag, 'SDEffect', BandLabels{Indx_B}, Sessions.Labels{Indx_S}}, '_'), Results, Format)
    end
end