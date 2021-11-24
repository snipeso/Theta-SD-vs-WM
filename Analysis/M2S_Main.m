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
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
StatsP = P.StatsP;
Channels = P.Channels;

ROI = 'preROI';
Window = 2;
Task = 'Match2Sample';
Tag = ['w', num2str(Window)];
BandLabels = fieldnames(Bands);
ChLabels = fieldnames(Channels.(ROI));


Main_Results = fullfile(Paths.Results, 'M2S_ANOVA',  ROI);
if ~exist(Main_Results, 'dir')
    for Indx_B = 1:numel(BandLabels)
        for Indx_Ch = 1:numel(ChLabels)
            mkdir(fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch}))
        end
    end
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


% split levels
tData = trialData(bData, AllTrials.level);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

CLims_Diff = [-1.7 1.7];
[nParticipants, nSessions, nTrials, nEpochs, nCh, nFreqs] = size(AllData);

Epochs = Format.Labels.Epochs;
Levels = [1 3 6];

YLims = [-.2 .6];

%% Bands ANOVA for SD vs memory load

FactorLabels = {'Session', 'Trial'};


for Indx_B = 1:numel(BandLabels)
    for Indx_Ch = 1:numel(ChLabels)
        Results = fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch});
        
        for Indx_E = 1:numel(Epochs)
            Data = squeeze(bData(:, :, :, Indx_E, Indx_Ch, Indx_B));
            Data = splitLevels(Data, AllTrials.level, 'mean');
            
            Stats = anova2way(Data, FactorLabels, Sessions.Labels, string(Levels), StatsP);
            
            TitleStats = strjoin({'Stats_Main_Level', TitleTag, BandLabels{Indx_B}, ChLabels{Indx_Ch}, Epochs{Indx_E}}, '_');
            saveStats(Stats, 'rmANOVA', Results, TitleStats, StatsP)
            
            figure('units','normalized','outerposition',[0 0 .2 1])
            subplot(4, 1, 1)
            plotANOVA2way(Stats, FactorLabels, StatsP, Format)
            ylim([0 1])
            title(strjoin({BandLabels{Indx_B}, ChLabels{Indx_Ch}, Epochs{Indx_E}}, ' '), 'FontSize', Format.TitleSize)
            
            subplot(4, 1, 2:4)
            Stats = plotSpaghettiOs(Data, 1, Sessions.Labels, string(Levels), ...
                Format.Colors.Levels, StatsP, Format);
            ylim(YLims)
            
            saveFig(strjoin({TitleTag, 'ANOVA', 'TrialType', BandLabels{Indx_B}, ChLabels{Indx_Ch}, Epochs{Indx_E}}, '_'), Results, Format)
        end
    end
end

close all

%% ANOVA between session and epoch type

FactorLabels = {'Session', 'Epoch'};
for Indx_B = 1:numel(BandLabels)
    for Indx_Ch = 1:numel(ChLabels)
        Data = squeeze(nanmean(bData(:, :, :, :, Indx_Ch, Indx_B), 3));
        Results = fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch});
        
        Stats = anova2way(Data, FactorLabels, Sessions.Labels, Epochs, StatsP);
        figure('units','normalized','outerposition',[0 0 .2 1])
        subplot(4, 1, 1)
        plotANOVA2way(Stats, FactorLabels, StatsP, Format)
        ylim([0 1])
        title(strjoin({BandLabels{Indx_B}, ChLabels{Indx_Ch}}, ' '), 'FontSize', Format.TitleSize)
        
        TitleStats = strjoin({'Stats_Main_Epoch', TitleTag, BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_');
        saveStats(Stats, 'rmANOVA', Results, TitleStats, StatsP)
        
        subplot(4, 1, 2:4)
        Stats = plotSpaghettiOs(Data, 1, Sessions.Labels, Epochs, ...
            reduxColormap(Format.Colormap.Rainbow, numel(Epochs)+1), StatsP, Format);
        ylim(YLims)
        
        saveFig(strjoin({TitleTag, 'ANOVA', 'Epochs', BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_'), Results, Format)
    end
end
close all


%% hedgesg for N3 vs N1 and BL vs SR and BL vs SD

Hedges = [];
CI = [];
% fmTheta
Data = squeeze(bData(:, 1, :, 2, 1, 2)); % BL Ret1 front theta
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
Data1 = squeeze(nanmean(bData(:, 1, :, 2, 1, 2), 3)); % BL Ret1 front theta
Data2 = squeeze(nanmean(bData(:, 2, :, 2, 1, 2), 3));
Data3 = squeeze(nanmean(bData(:, 3, :, 2, 1, 2), 3));
Stats = hedgesG(Data1, Data2, StatsP);
Hedges = [Hedges, Stats.hedgesg];
CI = [CI; Stats.hedgesgCI];
Stats = hedgesG(Data1, Data3, StatsP);
Hedges = [Hedges, Stats.hedgesg];
CI = [CI; Stats.hedgesgCI];

%
% Colors = [makePale(Format.Colors.Tasks.Match2Sample, .5); Format.Colors.Tasks.Match2Sample; makePale( Format.Colors.Tasks.Music, .5);  Format.Colors.Tasks.Music;];
Colors = flip(getColors([2, 2]));

Colors = cat(1, Colors(:, :, 1), Colors(:, :, 2));

figure
plotUFO(Hedges', CI, {'L3 vs L1', 'L6 vs L1', 'SR vs BL', 'SD vs BL'}, {}, Colors, 'vertical', Format)
yticks(0:.5:2)
ylabel("Hedge's G")
set(gca, 'YGrid', 'on')
title('fmTheta vs sdTheta effect sizes')
saveFig(strjoin({TitleTag, 'theta', 'hedgesg'}, '_'), Results, Format)



%% plot g-matrix of all epochs and all sessions to show what is significantly different from what else

Labels = {'N1', 'N3', 'N6'};

for Indx_Ch = 1:numel(ChLabels)
    
    for Indx_B = 1:numel(BandLabels)
        Results = fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch});
        for Indx_S = 1:numel(Sessions.Labels)
            % gather matrix
            
            Data = squeeze(tData(:, Indx_S, :, :, Indx_Ch, Indx_B));
            
            Data = reshape(Data, numel(Participants), []);
            
            Stats = hedgesG(Data, StatsP);
            G = Stats.hedgesg;
            Stats = Pairwise(Data, StatsP);
            G(Stats.p > StatsP.Alpha) = nan;
            G(isnan(G)) = 0;
            
            % plot matrix
            figure('units','normalized','outerposition',[0 0 .35, .65])
            plotStatsMatrix(G, repmat(Labels, 1, numel(Epochs)), Epochs, numel(Labels), StatsP.Paired.ES, Format)
            title(strjoin({Sessions.Labels{Indx_S}, ChLabels{Indx_Ch}, BandLabels{Indx_B}, 'Hedges G'}, ' '), 'FontSize', Format.TitleSize)
            
            saveFig(strjoin({TitleTag, 'gMatrix', Sessions.Labels{Indx_S}, ChLabels{Indx_Ch}, BandLabels{Indx_B}, 'hedgesg'}, '_'), Results, Format)
            
        end
    end
end











