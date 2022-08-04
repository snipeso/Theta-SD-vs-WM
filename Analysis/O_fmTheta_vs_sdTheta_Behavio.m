% script to correlate fmtheta and sdtheta to performance, in as much as it
% makes sense
clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Sessions = P.Sessions;
StatsP = P.StatsP;
Channels = P.Channels;
Labels = P.Labels;

SmoothFactor = 1; % in Hz, range to smooth over for spectrums

Window = 2;
ROI = 'preROI';
Task = 'Match2Sample';
Tag = ['w', num2str(Window)];

TitleTag = 'O_fmTheta_vs_sdTheta_Behavior';
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



[nParticipants, nSessions, nTrials, nEpochs, nCh, nFreqs] = size(AllData);

Epochs = Labels.Epochs;
Levels = [1 3 6];
Legend = append('L', string(Levels));



%%% Behavior
%%
Source_Tables = fullfile(Paths.Data, 'Behavior');

Participants = P.Participants;
Sessions = P.Sessions;

Answers_Path = fullfile(Source_Tables, 'Match2Sample_AllAnswers.mat');
load(Answers_Path, 'Answers')
M2S = Answers;


Levels = unique(M2S.level);
nLevels = numel(Levels);

% load data
M2S_Correct = nan(nParticipants, nSessions, nLevels); % percent correct
for Indx_P = 1:nParticipants
    for Indx_S = 1:nSessions
        for Indx_L = 1:nLevels
            T = M2S(strcmp(M2S.Participant, Participants{Indx_P}) & ...
                strcmp(M2S.Session, Sessions.Match2Sample{Indx_S}) & ...
                M2S.level == Levels(Indx_L), :);
            Tot = size(T, 1);
            C = nnz(T.correct==1);
            
            M2S_Correct(Indx_P, Indx_S, Indx_L) = 100*C/Tot;
        end
    end
end




%% PLot

L_Indx = 2;
Ch_Indx = 1; % front
Indx_E = 2; % retention 1
Indx_S = 3;
Grid = [1 2];
Indx_B = 2;
PlotProps = P.Manuscript;
PlotProps.Axes.xPadding = 20;
Colors = PlotProps.Color.Participants;



figure('units','centimeters','position',[0 0 PlotProps.Figure.W3 PlotProps.Figure.Height*.4])

% fmTheta relationship to behavior
L1 = squeeze(bchData(:, 1, 1, Indx_E, Ch_Indx, Indx_B));
LX = squeeze(bchData(:, 1, L_Indx, Indx_E, Ch_Indx, Indx_B));


Data1 = squeeze(M2S_Correct(:, 1, L_Indx));
% Data2 = LX-L1;
Data2 = (LX-L1)./L1;

subfigure([], Grid,[1 1], [], true, '', PlotProps);
AxisLabels = {[Legend{L_Indx}, ' % Correct'], [Legend{L_Indx}, '  fmTheta']};
Stats = plotCorrelations(Data1, Data2, AxisLabels, [], Colors, PlotProps);
title(['BL fmTheta (r=', num2str(Stats.r, '%2.2f'), '; p=', num2str(Stats.pvalue, '%2.2f'), ')'])


% sdTheta relationship to behavior
BL = squeeze(bchData(:, 1, L_Indx, Indx_E, Ch_Indx, Indx_B));
SD = squeeze(bchData(:, 3, L_Indx, Indx_E, Ch_Indx, Indx_B));

% Data2 = SD-BL;
Data2 = (SD-BL)./BL;

Data1 = squeeze(M2S_Correct(:, Indx_S, L_Indx));


subfigure([], Grid,[1 2], [], true, '', PlotProps);
AxisLabels = {[Legend{L_Indx}, ' SD % Correct'], [Legend{L_Indx}, ' SD \DeltaTheta']};
Stats = plotCorrelations(Data1, Data2, AxisLabels, [], Colors, PlotProps);
title(['sdTheta (r=', num2str(Stats.r, '%2.2f'), '; p=', num2str(Stats.pvalue, '%2.2f'), ')'])




