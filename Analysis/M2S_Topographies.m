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
CLims_Diff = [-1.7 1.7];
[nParticipants, nSessions, nTrials, nEpochs, nCh, nFreqs] = size(AllData);

Epochs = Format.Labels.Epochs;
Levels = [1 3 6];

%% plot N3 vs N1 for every epoch

for Indx_S = 1:nSessions
    for Indx_B = 1:numel(BandLabels)
        
        figure('units','normalized','outerposition',[0 0 .75 .6])
        %         tiledlayout(1, nEpochs, 'Padding', 'none', 'TileSpacing', 'compact');
        Indx = 1;
        for Indx_L = 2:numel(Levels)
            for Indx_E = 1:nEpochs
                Data = squeeze(bData(:, Indx_S, :, Indx_E, :, Indx_B));
                
                N1 = averageTrials(Data, squeeze(AllTrials.level(:, Indx_S, :)) == 1);
                N3 = averageTrials(Data, squeeze(AllTrials.level(:, Indx_S, :)) == Levels(Indx_L));
                
                %             nexttile
                subplot(2, 5, Indx)
                plotTopoDiff(N1, N3, Chanlocs, CLims_Diff, StatsP, Format);
                title([Epochs{Indx_E}, ' N', num2str(Levels(Indx_L))], 'FontSize', Format.TitleSize)
                colorbar off
                Indx = Indx+1;
            end
        end
        saveFig(strjoin({ TitleTag, 'N3vN1', BandLabels{Indx_B}, Sessions.Labels{Indx_S}}, '_'), Results, Format)
    end
end


figure('units','normalized','outerposition',[0 0 .25 .35])
plotColorbar( CLims_Diff, 'hedges g', Format)
saveFig(strjoin({TitleTag, 'Diff_Colorbar'}, '_'), Results, Format)

close all

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
close all


%% for N3 trials, plot correct vs incorrect topos



for Indx_S = 1:nSessions
    for Indx_B = 1:numel(BandLabels)
        for Indx_L = 1:3
            figure('units','normalized','outerposition',[0 0 .75 .35])
            %         tiledlayout(1, nEpochs, 'Padding', 'none', 'TileSpacing', 'compact');
            
            for Indx_E = 1:nEpochs
                Data = squeeze(bData(:, Indx_S, :, Indx_E, :, Indx_B));
                
                T = squeeze(AllTrials.level(:, Indx_S, :)) == Levels(Indx_L) & squeeze(AllTrials.correct(:, Indx_S, :)) == 1;
                Correct = averageTrials(Data, T);
                
                T = squeeze(AllTrials.level(:, Indx_S, :)) == Levels(Indx_L) & squeeze(AllTrials.correct(:, Indx_S, :)) == 0;
                Incorrect = averageTrials(Data, T);
                
                %             nexttile
                subplot(1, 5, Indx_E)
                plotTopoDiff(Correct, Incorrect, Chanlocs, CLims_Diff, StatsP, Format);
                title(Epochs{Indx_E}, 'FontSize', Format.TitleSize)
                colorbar off
                
            end
            saveFig(strjoin({ TitleTag, 'CorrectvsIncorrect', ['N', num2str(Levels(Indx_L))], BandLabels{Indx_B}, Sessions.Labels{Indx_S}, }, '_'), Results, Format)
        end
    end
    close all
end



%% Epochs relative to baseline


for Indx_S = 1:nSessions
    for Indx_B = 1:numel(BandLabels)
        figure('units','normalized','outerposition',[0 0 .75 1])
        %         tiledlayout(1, nEpochs, 'Padding', 'none', 'TileSpacing', 'compact');
        Indx = 1;
        BL =  squeeze(nanmean(bData(:, Indx_S, :, 1, :, Indx_B), 3));
        for Indx_L = 1:numel(Levels)
            for Indx_E = 2:nEpochs
                
                Data = squeeze(bData(:, Indx_S, :, Indx_E, :, Indx_B));
                
                L = averageTrials(Data, squeeze(AllTrials.level(:, Indx_S, :)) == Levels(Indx_L));
                
                %             nexttile
                subplot(3, 4, Indx)
                plotTopoDiff(BL, L, Chanlocs, CLims_Diff, StatsP, Format);
                title([Epochs{Indx_E}, ' N', num2str(Levels(Indx_L))], 'FontSize', Format.TitleSize)
                colorbar off
                Indx = Indx+1;
            end
            
        end
        saveFig(strjoin({ TitleTag, 'EpochvsBaseline', BandLabels{Indx_B}, Sessions.Labels{Indx_S}}, '_'), Results, Format)
    end
end


figure('units','normalized','outerposition',[0 0 .25 .35])
plotColorbar( CLims_Diff, 'hedges g', Format)
saveFig(strjoin({TitleTag, 'Diff_Colorbar'}, '_'), Results, Format)

close all
