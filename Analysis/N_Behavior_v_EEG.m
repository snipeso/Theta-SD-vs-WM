%%% Here I test specific hypotheses about a link between theta and
%%% behavior.

clear
clc
close all


ROI = 'preROI';

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Sessions = P.Sessions;
Participants = P.Participants;
Channels = P.Channels;
StatsP = P.StatsP;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Labels = P.Labels;

TitleTag = 'N_Behavior_vs_EEG';



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
bchData = bandData(chData, Freqs, Bands, 'last');

% average frequencies into bands
bData = bandData(zData, Freqs, Bands, 'last');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load performance

nParticipants = numel(Participants);
nSessions = numel(Sessions.Labels);
Source_Tables = fullfile(Paths.Data, 'Behavior');

Performance = [];
Performance_Labels = {};

%%% M2S

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

Performance = cat(3, Performance, M2S_Correct);
Performance_Labels = cat(1, Performance_Labels, append('STM ', string(Levels)));


% LAT
[Trials, LAT_RT, Types, TotT] = loadBehavior(Participants, Sessions.LAT, 'LAT', Paths, false);

Performance = cat(3, Performance, LAT_RT);
Performance_Labels = cat(1, Performance_Labels, "LAT meanRT");

LAT_Lapses = 100*(squeeze(Types(:, :, 1))./TotT);
Performance = cat(3, Performance, LAT_Lapses);
Performance_Labels = cat(1, Performance_Labels, "LAT lapses");

LAT_Correct = 100*(squeeze(Types(:, :, 3))./TotT);
Performance = cat(3, Performance, LAT_Correct);
Performance_Labels = cat(1, Performance_Labels, "LAT correct");

LAT_Late = 100*(squeeze(Types(:, :, 2))./TotT);
Performance = cat(3, Performance, LAT_Late);
Performance_Labels = cat(1, Performance_Labels, "LAT late");

[LAT_top10RT, ~] = tabulateTable(Trials, 'RT', 'top10mean', Participants, Sessions.LAT, []);
Performance = cat(3, Performance, LAT_top10RT);
Performance_Labels = cat(1, Performance_Labels, "LAT top10RT");

[Matrix, ~] = tabulateTable(Trials, 'RT', 'median', Participants, Sessions.LAT, []);
Performance = cat(3, Performance, Matrix);
Performance_Labels = cat(1, Performance_Labels, "LAT median");

[Matrix, ~] = tabulateTable(Trials, 'RT', 'bottom10mean', Participants, Sessions.LAT, []);
Performance = cat(3, Performance, Matrix);
Performance_Labels = cat(1, Performance_Labels, "LAT bottom10RT");

[Matrix, ~] = tabulateTable(Trials, 'RT', 'std', Participants, Sessions.LAT, []);
Performance = cat(3, Performance, Matrix);
Performance_Labels = cat(1, Performance_Labels, "LAT std");

% PVT
[Trials, PVT_RT, Types, ~] = loadBehavior(Participants, Sessions.PVT, 'PVT', Paths, false);
Performance = cat(3, Performance, PVT_RT);
Performance_Labels = cat(1, Performance_Labels, "PVT meanRT");

PVT_Lapses = squeeze(Types(:, :, 1));
Performance = cat(3, Performance, PVT_Lapses);
Performance_Labels = cat(1, Performance_Labels, "PVT lapses");

[PVT_top10RT, ~] = tabulateTable(Trials, 'RT', 'top10mean', Participants, Sessions.PVT, []);
Performance = cat(3, Performance, PVT_top10RT);
Performance_Labels = cat(1, Performance_Labels, "PVT top10RT");

[Matrix, ~] = tabulateTable(Trials, 'RT', 'median', Participants, Sessions.PVT, []);
Performance = cat(3, Performance, Matrix);
Performance_Labels = cat(1, Performance_Labels, "PVT median");

[Matrix, ~] = tabulateTable(Trials, 'RT', 'bottom10mean', Participants, Sessions.PVT, []);
Performance = cat(3, Performance, Matrix);
Performance_Labels = cat(1, Performance_Labels, "PVT bottom10RT");

[Matrix, ~] = tabulateTable(Trials, 'RT', 'std', Participants, Sessions.PVT, []);
Performance = cat(3, Performance, Matrix);
Performance_Labels = cat(1, Performance_Labels, "PVT std");

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

Performance = cat(3, Performance, SpFT_Incorrect);
Performance_Labels = cat(1, Performance_Labels, "Speech mistakes/s");
Performance = cat(3, Performance, SpFT_Correct);
Performance_Labels = cat(1, Performance_Labels, "Speech words/s");

Performance(:, 2, :) = [];  % ignore SR condition

%%% Load questionnaire data
Filepath = fullfile(P.Paths.Data, 'Questionnaires');
[Answers, Labels] = loadAllBAT(Filepath, Participants, Sessions, AllTasks);

Questions = fieldnames(Answers);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plot correlations


%% Colors for plots

PlotProps = P.Manuscript;

Colors = nan(numel(Performance_Labels), 3);
for Indx_P = 1:numel(Performance_Labels)
    Task = extractBefore(Performance_Labels(Indx_P), ' ');
    if strcmp(Task, 'STM')
        Task = 'Match2Sample';
    elseif strcmp(Task, 'Speech')
        Task = 'SpFT';
    end
    Colors(Indx_P, :) = PlotProps.Color.Tasks.(Task);
end
%%

%%% identify only measures that show a significant change from BL to SD
clc
Stats = pairedttest(squeeze(Performance(:, 1, :)), squeeze(Performance(:, 2, :)), StatsP);

% [~, Order] = sort(abs(Stats.hedgesg), 'descend');
Order =1:numel(Performance_Labels);

Data1 = squeeze(Performance(:, 2, Order) - Performance(:, 1, Order));


Grid = [1 4];
Indx_B = 2;
CLims = [-.75 .75];
PlotProps = P.Manuscript;
PlotProps.Figure.Padding = 30;
PlotProps.Scatter.Size = 15;
figure('units','centimeters','position',[0 0 PlotProps.Figure.W3*1.2 PlotProps.Figure.Height*.65])

Axes = subfigure([], Grid, [1 1], [], true, PlotProps.Indexes.Letters{1}, PlotProps);
Axes.Position(1) = Axes.Position(1)+.08;
Axes.Position(3) = Axes.Position(3)-.08;
Axes.Position(4) = Axes.Position(4)-.02;
plotUFO(Stats.hedgesg, Stats.hedgesgCI, Performance_Labels, {}, Colors, 'vertical', PlotProps);
set(gca, 'XDir','reverse')
xlim([.5 numel(Performance_Labels)+.5])
ylabel(P.Labels.ES)
title('BL vs SD', 'FontSize',PlotProps.Text.TitleSize)

for Indx_Ch = 1:3
    Data2 = squeeze(bchData(:, 3, :, Indx_Ch, Indx_B)- bchData(:, 1, :, Indx_Ch, Indx_B));

    if Indx_Ch == 1
        Letter = PlotProps.Indexes.Letters{2};
    else
        Letter = '';
    end
    Axes = subfigure([], Grid, [1 1+Indx_Ch], [], true,Letter, PlotProps);
    shiftaxis(Axes, PlotProps.Axes.xPadding, [])
    Axes.Position(4) = Axes.Position(4)-.02;
    %   Axes.Position(1) = Axes.Position(1)-.02;
    Stats = corrAll(Data1, Data2, '', Performance_Labels(Order), 'EEG', TaskLabels, StatsP, PlotProps);

    title(ChLabels{Indx_Ch}, 'FontSize', PlotProps.Text.TitleSize)
    caxis(CLims)
    colorbar off
    %     if Indx_Ch > 1
    ylabel('')
    xlabel('')
    set(gca, 'YTick', [])
    %     end
    addRectangles(TaskLabels, Performance_Labels, PlotProps)
  
    for Indx_P = 1:numel(Performance_Labels)
      for Indx_T = 1:numel(TaskLabels)

            if Stats.p(Indx_P, Indx_T) > StatsP.Alpha
                continue
            end
            dispStat(Stats, [Indx_P, Indx_T], [ChLabels{Indx_Ch}, ...
                Performance_Labels{Indx_P}, ':EEG-', TaskLabels{Indx_T}])
        end
    end

end


saveFig(strjoin({TitleTag, 'Correlations'}, '_'), Paths.Paper, PlotProps)






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

Theta = squeeze(bchData(:, [1 3], Task_Indx, Ch_Indx, B_Indx));
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

Theta = squeeze(bchData(:, [1 3], Task_Indx, Ch_Indx, B_Indx));
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

Theta = squeeze(bchData(:, [1 3], Task_Indx, Ch_Indx, B_Indx));
dTheta = Theta(:, 2) - Theta(:, 1);

Behavior = PVT_RT(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

AxisLabels = {'\DeltaRTs', '\DeltaTheta'};
Colors = PlotProps.Color.Participants;


figure
Stats = plotCorrelations(dBehavior, dTheta, AxisLabels, [], Colors, PlotProps);
title(['r=', num2str(Stats.r, '%2.2f'), '; p=', num2str(Stats.pvalue, '%2.2f')])




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Statstics

%% Behavior vs EEG
clc

Ch_Indx = 3;

AllTheta = squeeze(bchData(:, [1 3], :, Ch_Indx, B_Indx));


%%% STM
% Pass, since no sgnificant change with session


%%% LAT
Task_Indx = 2;
Theta = squeeze(AllTheta(:, :, Task_Indx));
dTheta = Theta(:, 2) - Theta(:, 1);

% correct
Behavior = LAT_Correct(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

Stats = correlation(dBehavior, dTheta);
dispStat(Stats, [], 'LAT %Correct:')

% late
Behavior = LAT_Late(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

Stats = correlation(dBehavior, dTheta);
dispStat(Stats, [], 'LAT %Late:')


% lapses
Behavior = LAT_Lapses(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

Stats = correlation(dBehavior, dTheta);
dispStat(Stats, [], 'LAT %Lapses:')

% RT
Behavior = LAT_RT(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

Stats = correlation(dBehavior, dTheta);
dispStat(Stats, [], 'LAT RTs:')

% fastest RTs
Behavior = LAT_top10RT(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

Stats = correlation(dBehavior, dTheta);
dispStat(Stats, [], 'LAT fast RTs:')


%%% PVT
Task_Indx = 3;
Theta = squeeze(AllTheta(:, :, Task_Indx));
dTheta = Theta(:, 2) - Theta(:, 1);

% lapses
Behavior = PVT_Lapses(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

Stats = correlation(dBehavior, dTheta);
dispStat(Stats, [], 'PVT %Lapses:')

% RTs
Behavior = PVT_RT(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

Stats = correlation(dBehavior, dTheta);
dispStat(Stats, [], 'PVT RTs:')

% fastest RTs
Behavior = PVT_top10RT(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

Stats = correlation(dBehavior, dTheta);
dispStat(Stats, [], 'PVT fast RTs:')

%%% SpFT
Task_Indx = 4;
Theta = squeeze(AllTheta(:, :, Task_Indx));
dTheta = Theta(:, 2) - Theta(:, 1);

% Correct
Behavior = SpFT_Correct(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

Stats = correlation(dBehavior, dTheta);
dispStat(Stats, [], 'Speech %Correct:')

% Incorrect
Behavior = SpFT_Incorrect(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

Stats = correlation(dBehavior, dTheta);
dispStat(Stats, [], 'Speech %Mistakes:')



%% topography

clc
AllTheta = squeeze(bData(:, [1 3], :, :, B_Indx));
CLims_R = [-.7 .7];

%%% STM
% Pass, since no sgnificant change with session


%%% LAT
Task_Indx = 2;
Theta = squeeze(AllTheta(:, :, Task_Indx, :));
dTheta = squeeze(Theta(:, 2, :) - Theta(:, 1, :));

% correct
Behavior = LAT_Correct(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);
figure
Stats = topoCorr(dTheta, dBehavior, Chanlocs, CLims_R, StatsP, PlotProps, P.Labels);
title('LAT % Correct')


% lapses
Behavior = LAT_Lapses(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

figure
Stats = topoCorr(dTheta, dBehavior, Chanlocs, CLims_R, StatsP, PlotProps, P.Labels);
title('LAT %Lapses:')

% RT
Behavior = LAT_RT(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

figure
Stats = topoCorr(dTheta, dBehavior, Chanlocs, CLims_R, StatsP, PlotProps, P.Labels);
title('LAT RTs:')

% fastest RTs
Behavior = LAT_top10RT(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);
figure
Stats = topoCorr(dTheta, dBehavior, Chanlocs, CLims_R, StatsP, PlotProps, P.Labels);
title('LAT fastest RTs:')

%%% PVT
Task_Indx = 3;
Theta = squeeze(AllTheta(:, :, Task_Indx, :));
dTheta = squeeze(Theta(:, 2, :) - Theta(:, 1, :));

% lapses
Behavior = PVT_Lapses(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

figure
Stats = topoCorr(dTheta, dBehavior, Chanlocs, CLims_R, StatsP, PlotProps, P.Labels);
title('PVT %Lapses')

% fastest RTs
Behavior = PVT_top10RT(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

figure
Stats = topoCorr(dTheta, dBehavior, Chanlocs, CLims_R, StatsP, PlotProps, P.Labels);
title('PVT fast RTs')

%%% SpFT
Task_Indx = 4;
Theta = squeeze(AllTheta(:, :, Task_Indx, :));
dTheta = squeeze(Theta(:, 2, :) - Theta(:, 1, :));

% Incorrect
Behavior = SpFT_Incorrect(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

figure
Stats = topoCorr(dTheta, dBehavior, Chanlocs, CLims_R, StatsP, PlotProps, P.Labels);
title('Speech %Mistakes')






%% Behavior vs Questionnaires

Question = 'KSS';

%%% SpFT
Task_Indx = 4;
Questionnaire = squeeze(Answers.(Question)(:, [1 3], Task_Indx));
dQuestionnaire = Questionnaire(:, 2) - Questionnaire(:, 1);

% Correct
Behavior = SpFT_Correct(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

Stats = correlation(dBehavior, dQuestionnaire);
dispStat(Stats, [], 'Speech %Correct:')

% Incorrect
Behavior = SpFT_Incorrect(:, [1 3]);
dBehavior = Behavior(:, 2) - Behavior(:, 1);

Stats = correlation(dBehavior, dQuestionnaire);
dispStat(Stats, [], 'Speech %Mistakes:')



%% Questionnaires vs theta

Question = 'KSS';
PlotProps = P.Manuscript;

B_Indx = 2;
Ch_Indx = 1;
% AllTheta = squeeze(bData(:, [1 3], :, Ch_Indx, B_Indx));
AllTheta = log(squeeze(bchData(:, [1 3], :, Ch_Indx, B_Indx)));

for Indx_T = 1:numel(AllTasks)

    Theta = squeeze(AllTheta(:, :, Indx_T));
    dTheta = Theta(:, 2) - Theta(:, 1);

    Questionnaire = squeeze(Answers.(Question)(:, [1 3], Indx_T));
    %     dQuestionnaire = Questionnaire(:, 2) - Questionnaire(:, 1);
    dQuestionnaire = Questionnaire(:, 2);

    Stats = correlation(dBehavior, dQuestionnaire);
    dispStat(Stats, [], [TaskLabels{Indx_T}, ' ', Question, ' vs ', BandLabels{B_Indx}])

    figure
    plotCorrelations(dQuestionnaire, dTheta, {Question, BandLabels{B_Indx}}, [], ...
        PlotProps.Color.Participants, PlotProps);
    title(TaskLabels{Indx_T})
end


%% Speech corr with coloring


Task_Indx = 4; % speech
Ch_Indx = 1; % front
B_Indx = 2; % theta
Grid = [1 2];
YLim = [0 3];

Theta = squeeze(bchData(:, [1 3], Task_Indx, Ch_Indx, B_Indx));
dTheta = Theta(:, 2) - Theta(:, 1);


Behavior = SpFT_Incorrect(:, [1 3]);

dBehavior = Behavior(:, 2) - Behavior(:, 1);

Color = repmat(getColors(1, '', 'yellow'), nParticipants, 1);
Color([1 5 12 end], :) = repmat(getColors(1, '', 'blue'), 4, 1);

AxisLabels = {'\Delta # Mistakes/s', '\DeltaTheta'};
figure
Stats = plotCorrelations(dBehavior, dTheta, AxisLabels, [], Color, PlotProps);
title(['Speech (r=', num2str(Stats.r, '%2.2f'), '; p=', num2str(Stats.pvalue, '%2.2f'), ')'])
padAxis('x'); padAxis('y')



%% Load speech trials

Window = 2;
ROI = 'preROI';
Task = 'SpFT';
Tag = ['w', num2str(Window)];

Filepath =  fullfile(Paths.Data, 'EEG', 'Locked', Task, Tag);
[AllData, Freqs, Chanlocs, AllTrials] = loadSpFTpower(P, Filepath);

%%
% average the individual trials
tData = squeeze(mean(AllData, 3, 'omitnan'));

% z-score it
% tData = zScoreData(tData, 'last');


% average data into ROIs
chData = meanChData(tData, Chanlocs, Channels.(ROI), 5);

% save it into bands
bchData = bandData(chData, Freqs, Bands, 'last');

[nParticipants, nSessions, nTrials, nEpochs, nCh, nFreqs] = size(AllData);


%% correlate speech with performance, splitting theta in reading vs speaking



PlotProps = P.Manuscript;

PlotProps.Figure.Padding = 20;
PlotProps.Axes.xPadding = 20;
Task_Indx = 4; % speech
Ch_Indx = 1; % front
B_Indx = 2; % theta
Grid = [1 2];
YLim = [-.3 1.8];

Theta = squeeze(bchData(:, [1 3], 1, Ch_Indx, B_Indx));
dTheta = Theta(:, 2) - Theta(:, 1);

Behavior = SpFT_Incorrect(:, [1 3]);

dBehavior = Behavior(:, 2) - Behavior(:, 1);

Color = repmat(getColors(1, '', 'yellow'), nParticipants, 1);
Color([1 5 12 end], :) = repmat(getColors(1, '', 'blue'), 4, 1);

AxisLabels = {'\Delta # Mistakes/s', '\DeltaTheta'};

figure('units','centimeters','position',[0 0 PlotProps.Figure.W3 PlotProps.Figure.Height*.4])
subfigure([], Grid, [1 1], [], true, '', PlotProps);
Stats = plotCorrelations(dBehavior, dTheta, AxisLabels, [], Color, PlotProps);
title(['Reading (r=', num2str(Stats.r, '%2.2f'), '; p=', num2str(Stats.pvalue, '%2.2f'), ')'])
ylim(YLim)
padAxis('x'); padAxis('y')


Theta = squeeze(bchData(:, [1 3], 2, Ch_Indx, B_Indx));
dTheta = Theta(:, 2) - Theta(:, 1);


subfigure([], Grid, [1 2], [], true, '', PlotProps);
Stats = plotCorrelations(dBehavior, dTheta, AxisLabels, [], Color, PlotProps);
title(['Speaking (r=', num2str(Stats.r, '%2.2f'), '; p=', num2str(Stats.pvalue, '%2.2f'), ')'])
ylim(YLim)
padAxis('x'); padAxis('y')

