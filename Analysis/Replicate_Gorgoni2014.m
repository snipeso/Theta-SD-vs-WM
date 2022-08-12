clear
clc
close all

P = analysisParameters();
Participants = P.Participants;
Paths = P.Paths;
Sessions = P.Sessions;
PlotProps = P.Manuscript;
StatsP = P.StatsP;

% behavior
Task = 'PVT';
% Task = 'LAT';
T_Indx = 1;
[Trials, meanRT, Types, TotT] = loadBehavior(Participants, Sessions.(Task), Task, Paths, false);
Lapses = 100*(squeeze(Types(:, :, 1))./TotT);
[top10RT, ~] = tabulateTable(Trials, 'RT', 'top10mean', Participants, Sessions.(Task), []);
[bottom10RT, ~] = tabulateTable(Trials, 'RT', 'bottom10mean', Participants, Sessions.(Task), []);
[medianRT, ~] = tabulateTable(Trials, 'RT', 'median', Participants, Sessions.(Task), []);

%%% load EEG
Bands = P.Bands;
Duration = 4;
WelchWindow = 8;
AllTasks = {'PVT', 'LAT'};
Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];


Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);


% z-score it
% zData = zScoreData(AllData, 'last');
zData = log(AllData);

Channels = P.Channels;
ROI = 'preROI';
% average channel data into 2 spots
chData = meanChData(zData, Chanlocs, Channels.(ROI), 4);

% average frequencies into bands
bchData = bandData(chData, Freqs, Bands, 'last');


% average frequencies into bands
bData = bandData(zData, Freqs, Bands, 'last');


CLims_Diff = [-7 7];


%% Topography replication

B_Indx = 2;
CLims_R = [-.65 .65];
P = analysisParameters();

dTheta = squeeze(diff(squeeze(bData(:, [1 3], T_Indx, :, B_Indx)), 1, 2));

figure('Units','centimeters', 'position', [0 0,  PlotProps.Figure.W3, PlotProps.Figure.Height*.3])
subplot(1,3,1)
dBehavior = diff(medianRT(:, [1 3]), 1, 2);
Stats = topoCorr(dTheta, dBehavior, Chanlocs, CLims_R, StatsP, PlotProps, P.Labels);
title('median RTs')

subplot(1,3, 2)
dBehavior = diff(top10RT(:, [1 3]), 1, 2);
Stats = topoCorr(dTheta, dBehavior, Chanlocs, CLims_R, StatsP, PlotProps, P.Labels);
title('Fastest 10% RTs')

 subplot(1,3, 3)
 dBehavior = diff(bottom10RT(:, [1 3]), 1, 2);
Stats = topoCorr(dTheta, dBehavior, Chanlocs, CLims_R, StatsP, PlotProps, P.Labels);
title('Slowest 10% RTs')


%% ROI
AxisLabels = {'\DeltafastRTs', '\DeltaTheta'};
dThetaROI = squeeze(diff(squeeze(bchData(:, [1 3], T_Indx, 3, B_Indx)), 1, 2));
dBehavior = diff(top10RT(:, [1 3]), 1, 2);
figure
Stats = plotCorrelations(dBehavior, dThetaROI, AxisLabels, [], PlotProps.Color.Participants, PlotProps);
title(['r=', num2str(Stats.r, '%.2f'), '; p=', num2str(Stats.pvalue, '%.3f')])


%% lapses & mean RT

dTheta = squeeze(diff(squeeze(bData(:, [1 3], T_Indx, :, B_Indx)), 1, 2));

figure
subplot(1, 2, 1)
dBehavior = diff(Lapses(:, [1 3]), 1, 2);
Stats = topoCorr(dTheta, dBehavior, Chanlocs, CLims_R, StatsP, PlotProps, P.Labels);
title('Lapses')


subplot(1, 2, 2)
dBehavior = diff(meanRT(:, [1 3]), 1, 2);
Stats = topoCorr(dTheta, dBehavior, Chanlocs, CLims_R, StatsP, PlotProps, P.Labels);
title('Mean RT')

 %%
 figure
 topoDiff(squeeze(bData(:, 1, 2, :, B_Indx)), squeeze(bData(:, 3, 2, :, B_Indx)), Chanlocs, [], StatsP, PlotProps, P.Labels)
