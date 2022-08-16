clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
StatsP = P.StatsP;
Channels = P.Channels;
Labels = P.Labels;

SmoothFactor = 1; % in Hz, range to smooth over for spectrums

Window = 2;
ROI = 'preROI';
Task = 'Match2Sample';
Tag = ['w', num2str(Window)];

TitleTag = 'N1_fmTheta_vs_Behavior';
BandLabels = fieldnames(Bands);
ChLabels = fieldnames(Channels.(ROI));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Locked', Task, Tag);
[AllData, Freqs, Chanlocs, AllTrials] = loadM2Spower(P, Filepath);

% trial data
tData = trialData(AllData, AllTrials.level);

% z-score it
% zData = zScoreData(tData, 'last');
zData = tData;

% average data into ROIs
chData = meanChData(zData, Chanlocs, Channels.(ROI), 5);

% save it into bands
bchData = bandData(chData, Freqs, Bands, 'last');
bData = bandData(zData, Freqs, Bands, 'last');


[nParticipants, nSessions, nTrials, nEpochs, nCh, nFreqs] = size(AllData);

Epochs = Labels.Epochs;
Levels = [1 3 6];
Legend = append('L', string(Levels));


Source_Tables = fullfile(Paths.Data, 'Behavior');

Participants = P.Participants;
Sessions = P.Sessions;

[Answers, Correct] = loadM2Sbehavior(Source_Tables, Participants, Sessions);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot & stats

%% Anova for behavior change in performance

Stats = anova2way(Correct, {'Session', 'Level'}, Sessions.Labels, Legend, StatsP);

dispStat(Stats, Stats.labels, '% Correct:')


%% replicate previous study
clc


Indx_B  = 2; % theta
Indx_S = 1;
Indx_L = 2;
Ret = {'Ret1', 'Ret2'};
StatsP = P.StatsP;
% StatsP.Correlation = 'Pearson';
PlotProps = P.Manuscript;

% AFZ log difference vs behavioral difference
AFZ = squeeze(log(bData(:, Indx_S, [1 Indx_L], [2 3], labels2indexes(16, Chanlocs), Indx_B)));

Data1 = squeeze(Correct(:, Indx_S, Indx_L)-Correct(:, Indx_S, 1));

for Indx_E = 1:2
    Data2 = squeeze(AFZ(:, 2, Indx_E)-AFZ(:, 1, Indx_E));
    Stats = correlation(Data1, Data2, StatsP);
    dispStat(Stats,[], ['fmTheta vs performance change ', Ret{Indx_E}])

    figure
    Stats = plotCorrelations(Data1, Data2, {'\Delta %Correct', '\Delta Theta'}, ...
        [], PlotProps.Color.Participants, PlotProps, StatsP);
    title(['L1 vs L', num2str(Levels(Indx_L)), ' (r=', num2str(Stats.r, '%2.2f'), '; p=', num2str(Stats.p, '%2.2f'), ')'])

end

% % Check to see if its the correct data
% figure
% topoDiff(squeeze(log(bData(:, Indx_S, 1, 2, :, Indx_B))), squeeze(log(bData(:, Indx_S, 2, 2, :, Indx_B))), ...
%     Chanlocs, [], StatsP, PlotProps, P.Labels);

%% see with correct data parameters

Indx_B = 2;
StatsP = P.StatsP;

Data1 = squeeze(Correct(:, Indx_S, 2)-Correct(:, Indx_S, 1));


Data2 = squeeze(bData(:, 1, [1 2], 2, :, Indx_B));
Data2 = squeeze(Data2(:, 2, :)-Data2(:, 1, :));

figure
Stats = topoCorr(Data2, Data1, Chanlocs, [], StatsP, PlotProps, P.Labels);

%% with ROI

Indx_B = 2;
Indx_Ch = 1;
Indx_E = 2;
Indx_S = 1;
StatsP = P.StatsP;
% Indx_L = 2;
Indx_L = 3;

Data1 = squeeze(Correct(:, Indx_S, Indx_L)-Correct(:, Indx_S, 1));

Data2 = squeeze(bchData(:, Indx_S, [1 Indx_L], Indx_E, Indx_Ch, Indx_B));
Data2 = squeeze(Data2(:, 2, :)-Data2(:, 1, :));

clc
Stats = correlation(Data1, Data2, StatsP);
dispStat(Stats, [], 'fmTheta vs performance change ROI')



%% correlate each ROI for each level with each level change in performance
clc

Indx_B = 2;
Indx_Ch = 3;
Indx_E = 2;
StatsP = P.StatsP;

for Indx_L = 1:3

    Data1 = squeeze(Correct(:, 3, Indx_L)-Correct(:, 1, Indx_L));

    Data2 = squeeze(bchData(:, [1 3], Indx_L, Indx_E, Indx_Ch, Indx_B));
    Data2 = squeeze(Data2(:, 2, :)-Data2(:, 1, :));

    Stats = correlation(Data1, Data2, StatsP);
    dispStat(Stats, [], ['sdTheta vs ', Legend{Indx_L}])

end
