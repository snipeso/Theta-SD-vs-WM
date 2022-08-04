%%% Here I test specific hypotheses about a link between theta and
%%% behavior.



ROI = 'preROI';

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Sessions = P.Sessions;
Channels = P.Channels;
StatsP = P.StatsP;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Labels = P.Labels;

TitleTag = 'F_TaskTheta_ROI';



%%% Load EEG

Duration = 4;
WelchWindow = 8;

Tag = ['window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];

ChLabels = fieldnames(Channels.(ROI));
BandLabels = fieldnames(Bands);

Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);

% z-score it
% zData = zScoreData(AllData, 'last');
zData = AllData;

% average channel data into 2 spots
chData = meanChData(zData, Chanlocs, Channels.(ROI), 4);

% average frequencies into bands
bData = bandData(chData, Freqs, Bands, 'last');



%%% Load performance

nParticipants = numel(Participants);
nSessions = numel(Sessions.Labels);


% SPFT
Answers_Path = fullfile(Source_Tables, 'SpFT_AllAnswers.mat');
load(Answers_Path, 'Answers')
SpFT = Answers;

SpFT_Correct = nan(nParticipants, nSessions); % percent correct
SpFT_Incorrect = SpFT_Correct;

for Indx_P = 1:nParticipants
    for Indx_S = 1:nSessions
            T = SpFT(strcmp(SpFT.Participant, Participants{Indx_P}) & ...
                strcmp(SpFT.Session, Sessions.SpFT{Indx_S}), :);
            C = nanmean(T.Correct);
            IC =  nanmean(T.Incorrect);
            
            SpFT_Correct(Indx_P, Indx_S) = C/10;
            SpFT_Incorrect(Indx_P, Indx_S) = IC/10;
    end
end


% LAT
LAT = loadLATmeta(P, Sessions.LAT, false);
TotT = size(LAT.RT, 3);

LAT_RT = nanmean(LAT.RT, 3);
LAT_Correct = 100*(nansum(squeeze(LAT.Tally) == 3, 3)/TotT);
LAT_Lapses = 100*(nansum(squeeze(LAT.Tally) == 1, 3)/TotT);

%%% PVT

PVT = loadPVTmeta(P, Sessions.PVT, false);
TotT = size(PVT.RT, 3);

PVT_RT = nanmean(PVT.RT, 3);
PVT_Lapses = nansum(squeeze(PVT.Tally) == 2, 3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%


PlotProps = P.Manuscript;
PlotProps.Axes.xPadding = 20;

%%% Change in theta vs change in # mistakes in Speech task
% prediction: theta will increase more in cases where speech did not
% improve much
Task_Indx = 4; % speech
Ch_Indx = 1; % front
B_Indx = 2; % theta
Grid = [1 2];
YLim = [0 3];

Theta = squeeze(bData(:, [1 3], Task_Indx, Ch_Indx, B_Indx));
dTheta = Theta(:, 2) - Theta(:, 1);

Behavior = SpFT_Incorrect(:, [1 3]);

dBehavior = Behavior(:, 2) - Behavior(:, 1);


AxisLabels = {'\Delta # Mistakes/s', '\DeltaTheta'};
figure('units','centimeters','position',[0 0 PlotProps.Figure.W3 PlotProps.Figure.Height*.4])
subfigure([], Grid,[1 1], [], true, '', PlotProps);
Stats = plotCorrelations(dBehavior, dTheta, AxisLabels, [], PlotProps.Color.Participants, PlotProps);
title(['Speech (r=', num2str(Stats.r, '%2.2f'), '; p=', num2str(Stats.pvalue, '%2.2f'), ')'])
ylim(YLim)
padAxis('x'); padAxis('y')



% prediction failed....



%%% Change in theta vs change in RT in LAT
% prediction: theta will increase more in participants who got a lot worse
Task_Indx = 2; % speech
Ch_Indx = 1; % front
B_Indx = 2; % theta

Theta = squeeze(bData(:, [1 3], Task_Indx, Ch_Indx, B_Indx));
dTheta = Theta(:, 2) - Theta(:, 1);

Behavior = LAT_Lapses(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

AxisLabels = {'\DeltaLapses', '\DeltaTheta'};
Colors = PlotProps.Color.Participants;

subfigure([], Grid, [1 2], [], true, '', PlotProps);
Stats = plotCorrelations(dBehavior, dTheta, AxisLabels, [], Colors, PlotProps);
title(['LAT (r=', num2str(Stats.r, '%2.2f'), '; p=', num2str(Stats.pvalue, '%2.2f'), ')'])
ylim(YLim)
padAxis('x'); padAxis('y')

saveFig(strjoin({TitleTag, 'Corr'}, '_'), Paths.Paper, PlotProps)



%%

%%% Change in theta vs change in RT in PVT
% prediction: theta will increase more in participants who got a lot worse
Task_Indx = 2; % speech
Ch_Indx = 1; % front
B_Indx = 2; % theta

Theta = squeeze(bData(:, [1 3], Task_Indx, Ch_Indx, B_Indx));
dTheta = Theta(:, 2) - Theta(:, 1);

Behavior = PVT_RT(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

AxisLabels = {'\DeltaRTs', '\DeltaTheta'};
Colors = PlotProps.Color.Participants;


figure
Stats = plotCorrelations(dBehavior, dTheta, AxisLabels, [], Colors, PlotProps);
title(['r=', num2str(Stats.r, '%2.2f'), '; p=', num2str(Stats.pvalue, '%2.2f')])



