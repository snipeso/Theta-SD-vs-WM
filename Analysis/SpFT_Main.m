% Plot theta and behavior changes with SD during speech task

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
Task = 'SpFT';
Tag = ['w', num2str(Window)];

BandLabels = fieldnames(Bands);
ChLabels = fieldnames(Channels.(ROI));

Main_Results = fullfile(Paths.Results, 'SpFT_ANOVA', Tag, ROI);
if ~exist(Main_Results, 'dir')
    for Indx_B = 1:numel(BandLabels)
        for Indx_Ch = 1:numel(ChLabels)
        mkdir(fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch}))
        end
    end
end


TitleTag = strjoin({'SpFT', Tag, 'Main'}, '_');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Locked', Task, Tag);
[AllData, Freqs, Chanlocs, AllTrials] = loadSpFTpower(P, Filepath);

% z-score it
zData = zScoreData(AllData, 'last');

chData = meanChData(zData, Chanlocs, Channels.(ROI), 5);

% save it into bands
bData = bandData(chData, Freqs, Bands, 'last');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

CLims_Diff = [-1.7 1.7];

Epochs = {'Read', 'Speak'};


%% 2-way ANOVA for preROI channels with Epoch x Session

FactorLabels = {'Session', 'Epoch'};

YLims = [-.3 .8];

for Indx_B = 1:numel(BandLabels)
    for Indx_Ch = 1:numel(ChLabels)
         Results = fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch});
        
        Data = squeeze(nanmean(bData(:, :, :, :, Indx_Ch, Indx_B), 3));
        
        Stats = anova2way(Data, FactorLabels, Sessions.Labels, Epochs, StatsP);
        
        TitleStats = strjoin({'Stats_Main', TitleTag, BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_');
        saveStats(Stats, 'rmANOVA', Results, TitleStats, StatsP)
        
        figure('units','normalized','outerposition',[0 0 .2 1])
        subplot(4, 1, 1)
        plotANOVA2way(Stats, FactorLabels, StatsP, Format)
        ylim([0 1])
        title(strjoin({BandLabels{Indx_B}, ChLabels{Indx_Ch}}, ' '), 'FontSize', Format.TitleSize)
        
        subplot(4, 1, 2:4)
        Stats = plotSpaghettiOs(Data, 1, Sessions.Labels, Epochs, ...
            Format.Colors.Levels([1, 3], :), StatsP, Format);
        ylim(YLims)
        
        saveFig(strjoin({TitleTag, 'ANOVA', 'TrialType', BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_'), Results, Format)
        
    end
end


%% pairwise comparison of # of words with session

Tot = AllTrials.correct + AllTrials.incorrect;

figure('units','normalized','outerposition',[0 0 .75 .5])
subplot(1, 4, 1)
Data = nanmean(Tot, 3)/10;
plotConfettiSpaghetti(Data, Sessions.Labels, [], [], Format.Colors.Participants, StatsP, Format)
title('Total Words')
ylabel('words/s')

subplot(1, 4, 2)
Data = nanmean(AllTrials.correct, 3)/10;
plotConfettiSpaghetti(Data, Sessions.Labels, [], [], Format.Colors.Participants, StatsP, Format)
title('Correct Words')
ylabel('words/s')

% pairwise comparison of # of mistakes with session

subplot(1, 4, 3)
Data = nanmean(AllTrials.incorrect, 3)/10;
plotConfettiSpaghetti(Data, Sessions.Labels, [], [], Format.Colors.Participants, StatsP, Format)
title('Incorrect Words')
ylabel('words/s')

subplot(1, 4, 4)
Data = nanmean(AllTrials.RT, 3);
plotConfettiSpaghetti(Data, Sessions.Labels, [], [], Format.Colors.Participants, StatsP, Format)
title('Reading Time')
ylabel('seconds')

saveFig(strjoin({TitleTag, 'Performance'}, '_'), Main_Results, Format)


%% correlation between power and mistakes
close all

S = 3;
for Indx_Ch = 1:numel(ChLabels)
    for Indx_B = 1:numel(BandLabels)
         Results = fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch});
        
        for Indx_E = 1:2
            figure('units','normalized','outerposition',[0 0 .5 1])
            subplot(2, 2, 1)
            Data1 = squeeze(Tot(:, S, :))'/10;
            Data2 = squeeze(bData(:, S, :, Indx_E, Indx_Ch, Indx_B))';
            plotSticksAndStones(Data1, Data2, ...
                {'Total Words (words/s)', strjoin({BandLabels{Indx_B}, ChLabels{Indx_Ch}, Epochs{Indx_E}}, ' ')}, ...
                [], Format.Colors.Participants, Format);

            
             subplot(2, 2, 2)
            Data1 = squeeze(AllTrials.correct(:, S, :))'/10;
            plotSticksAndStones(Data1, Data2, ...
                {'Correct Words (words/s)', strjoin({BandLabels{Indx_B}, ChLabels{Indx_Ch}, Epochs{Indx_E}}, ' ')}, ...
                [], Format.Colors.Participants, Format);
            
                         subplot(2, 2, 3)
            Data1 = squeeze(AllTrials.incorrect(:, S, :))'/10;
            plotSticksAndStones(Data1, Data2, ...
                {'Incorrect Words (words/s)', strjoin({BandLabels{Indx_B}, ChLabels{Indx_Ch}, Epochs{Indx_E}}, ' ')}, ...
                [], Format.Colors.Participants, Format);
            
                         subplot(2, 2, 4)
            Data1 = squeeze(AllTrials.RT(:, S, :))';
            plotSticksAndStones(Data1, Data2, ...
                {'Reading time (s)', strjoin({BandLabels{Indx_B}, ChLabels{Indx_Ch}, Epochs{Indx_E}}, ' ')}, ...
                [], Format.Colors.Participants, Format);
            
            
            
            saveFig(strjoin({TitleTag, 'TrialsPower', BandLabels{Indx_B}, ChLabels{Indx_Ch}, Epochs{Indx_E}}, '_'), Results, Format)
        end
    end
end

