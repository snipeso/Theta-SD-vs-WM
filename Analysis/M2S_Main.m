% Script for looking at responses across trial types and sleep deprivation.


% magnitude of theta.
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
StatsP = P.StatsP;
Channels = P.Channels;

ROI = 'preROI';
Window = 2;
Task = 'Match2Sample';
Tag = ['w', num2str(Window)];

Results = fullfile(Paths.Results, 'M2S_ANOVA', Tag, ROI);
if ~exist(Results, 'dir')
    mkdir(Results)
end


TitleTag = strjoin({'M2S', Tag, 'Main'}, '_');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Locked', Task, Tag);
[AllData, Freqs, Chanlocs, AllTrials] = loadM2Spower(P, Filepath);

% z-score it
zData = zScoreData(AllData, 'last');

chData = meanChData(zData, Chanlocs, Channels.(ROI), 5);

% save it into bands
bData = bandData(chData, Freqs, Bands, 'last');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data
BandLabels = fieldnames(Bands);
chLabels = fieldnames(Channels.(ROI));
CLims_Diff = [-1.7 1.7];
[nParticipants, nSessions, nTrials, nEpochs, nCh, nFreqs] = size(AllData);

Epochs = Format.Labels.Epochs;
Levels = [1 3 6];


%% Bands ANOVA for SD vs memory load

FactorLabels = {'Session', 'Trial'};

YLims = [-.2 .6];

for Indx_B = 1:numel(BandLabels)
    for Indx_Ch = 1:numel(chLabels)
        for Indx_E = 1:numel(Epochs)
            Data = squeeze(bData(:, :, :, Indx_E, Indx_Ch, Indx_B));
            Data = splitLevels(Data, AllTrials.level, 'mean');
            
            Stats = anova2way(Data, FactorLabels, Sessions.Labels, string(Levels), StatsP);
            figure('units','normalized','outerposition',[0 0 .2 1])
            subplot(4, 1, 1)
            plotANOVA2way(Stats, FactorLabels, StatsP, Format)
            ylim([0 1])
            title(strjoin({BandLabels{Indx_B}, chLabels{Indx_Ch}, Epochs{Indx_E}}, ' '), 'FontSize', Format.TitleSize)
            
            subplot(4, 1, 2:4)
            Stats = plotSpaghettiOs(Data, 1, Sessions.Labels, string(Levels), ...
                Format.Colors.Levels, StatsP, Format);
            ylim(YLims)
            
            saveFig(strjoin({TitleTag, 'ANOVA', 'TrialType', BandLabels{Indx_B}, chLabels{Indx_Ch}, Epochs{Indx_E}}, '_'), Results, Format)
        end
    end
end

close all

%% ANOVA between session and epoch type

FactorLabels = {'Session', 'Epoch'};
for Indx_B = 1:numel(BandLabels)
    for Indx_Ch = 1:numel(chLabels)
        Data = squeeze(nanmean(bData(:, :, :, :, Indx_Ch, Indx_B), 3));
        
        Stats = anova2way(Data, FactorLabels, Sessions.Labels, Epochs, StatsP);
        figure('units','normalized','outerposition',[0 0 .2 1])
        subplot(4, 1, 1)
        plotANOVA2way(Stats, FactorLabels, StatsP, Format)
        ylim([0 1])
        title(strjoin({BandLabels{Indx_B}, chLabels{Indx_Ch}}, ' '), 'FontSize', Format.TitleSize)
        
        subplot(4, 1, 2:4)
        Stats = plotSpaghettiOs(Data, 1, Sessions.Labels, Epochs, ...
            reduxColormap(Format.Colormap.Rainbow, numel(Epochs)+1), StatsP, Format);
        ylim(YLims)
        
        saveFig(strjoin({TitleTag, 'ANOVA', 'Epochs', BandLabels{Indx_B}, chLabels{Indx_Ch}}, '_'), Results, Format)
    end
end
close all


%% hedgesg for N3 vs N1 and BL vs SR and BL vs SD

Hedges = [];
CI = [];
% fmTheta
Data = squeeze(bData(:, 1, :, 2, 2, 2)); % BL Ret1 front theta
Data1 = averageTrials(Data, squeeze(AllTrials.level(:, 1, :)) == 1);
Data2 =  averageTrials(Data, squeeze(AllTrials.level(:, 1, :)) == 3);
Data3 =  averageTrials(Data, squeeze(AllTrials.level(:, 1, :)) == 6);
Stats = hedgesG(Data1, Data2, StatsP);
Hedges = [Hedges, Stats.hedgesg];
CI = [CI; Stats.hedgesgCI];
Stats = hedgesG(Data1, Data3, StatsP);
Hedges = [Hedges, Stats.hedgesg];
CI = [CI; Stats.hedgesgCI];

% sdTheta
Data1 = squeeze(nanmean(bData(:, 1, :, 2, 2, 2), 3)); % BL Ret1 front theta
Data2 = squeeze(nanmean(bData(:, 2, :, 2, 2, 2), 3));
Data3 = squeeze(nanmean(bData(:, 3, :, 2, 2, 2), 3));
Stats = hedgesG(Data1, Data2, StatsP);
Hedges = [Hedges, Stats.hedgesg];
CI = [CI; Stats.hedgesgCI];
Stats = hedgesG(Data1, Data3, StatsP);
Hedges = [Hedges, Stats.hedgesg];
CI = [CI; Stats.hedgesgCI];

%%
Colors = [makePale(Format.Colors.Tasks.Match2Sample, .5); Format.Colors.Tasks.Match2Sample; makePale( Format.Colors.Tasks.Music, .5);  Format.Colors.Tasks.Music;];
figure
plotUFO(Hedges', CI, {'L3 vs L1', 'L6 vs L1', 'SR vs BL', 'SD vs BL'}, {}, Colors, 'vertical', Format)
yticks(0:.5:2)
ylabel("Hedge's G")
set(gca, 'YGrid', 'on')
title('fmTheta vs sdTheta effect sizes')
saveFig(strjoin({TitleTag, 'theta', 'hedgesg'}, '_'), Results, Format)

