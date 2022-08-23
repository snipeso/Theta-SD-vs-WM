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
CLims = [-1 1];
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

Shift = [-.01 .01 .03];

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
    Axes.Position(3) = Axes.Position(3)-.02;

  Axes.Position(1) = Axes.Position(1)-Shift(Indx_Ch);

%       Axes.Position(1) = Axes.Position(1)-.02;
    disp(['******', ChLabels{Indx_Ch}, '******'])
    Stats = corrAll(Data1, Data2, '', Performance_Labels(Order), 'EEG', ...
        TaskLabels, StatsP, PlotProps, 'none');

    title(ChLabels{Indx_Ch}, 'FontSize', PlotProps.Text.TitleSize)
    caxis(CLims)
      
    colorbar off
   
    ylabel('')
    xlabel('')
    set(gca, 'YTick', [])
    %     end
    addRectangles(TaskLabels, Performance_Labels, PlotProps)
end

 Axes = subfigure([], [1 12], [1 12], [], true, '', PlotProps);
 Axes.Units = 'normalized';
  Axes.Position(4) = Axes.Position(4)+.02;
    Axes.Position(2) = Axes.Position(2)-.02;
  Axes.Position(3) = Axes.Position(3)+.1;
  Axes.Position(1) = Axes.Position(1)-.01;
 plotColorbar('Divergent', CLims, 'R', PlotProps)
colormap(PlotProps.Color.Maps.Divergent)
set(Axes, 'FontSize', PlotProps.Text.LegendSize)

saveFig(strjoin({TitleTag, 'Correlations'}, '_'), Paths.Paper, PlotProps)


%% correct everything

Data2 = squeeze(bchData(:, 3, :, :, Indx_B)- bchData(:, 1, :, :, Indx_B));
 Data2 = reshape(Data2, numel(Participants), []);
 
 Stats = corrAll(Data1, Data2, '', Performance_Labels, '', repmat(TaskLabels, 1, 3), StatsP, PlotProps, 'FDR');

%% same, but with source localization

PlotProps = P.Manuscript;
PlotProps.Figure.Padding = 50;

load(fullfile(Paths.Data, 'EEG', 'Source', 'Table', 'mtrx_all_tasks_median_noZscore.mat'))
AllTheta = mean(mtrx_all_crtx, 5, 'omitnan'); % average the different frequencies (4-8)
Areas = cortical_areas;
Areas = replace(Areas, '_', ' ');

Data1 = squeeze(Performance(:, 2, Order) - Performance(:, 1, Order));


for Indx_T = 1:numel(TaskLabels)

    Data2 = squeeze(AllTheta(:, 2, Indx_T, :)-AllTheta(:, 1, Indx_T, :));
figure('units','normalized','outerposition',[0 0 1 .9])

subfigure([], [1 1], [1, 1], [], false, '', PlotProps);
Stats = corrAll(Data1, Data2, '', Performance_Labels(Order), 'EEG', Areas, StatsP, PlotProps, 'Strict');

    title(TaskLabels{Indx_T}, 'FontSize', PlotProps.Text.TitleSize)
    caxis(CLims)
    colorbar off
end


%% mroe selective; only take areas that show a significant change with SD

PlotProps = P.Manuscript;
PlotProps.Figure.Padding = 50;

load(fullfile(Paths.Data, 'EEG', 'Source', 'Table', 'mtrx_all_tasks_median_noZscore.mat'))
AllTheta = mean(mtrx_all_crtx, 5, 'omitnan'); % average the different frequencies (4-8)
Areas = cortical_areas;
Areas = replace(Areas, '_', ' ');

Data1 = squeeze(Performance(:, 2, :) - Performance(:, 1, :));
Stats1 = pairedttest(squeeze(Performance(:, 1, :)), squeeze(Performance(:, 2, :)), StatsP);
Data1 = Data1(:, Stats1.p<StatsP.Alpha);


for Indx_T = 1:numel(TaskLabels)

    Data2 = squeeze(AllTheta(:, 2, Indx_T, :)-AllTheta(:, 1, Indx_T, :));
    Stats2 = pairedttest(squeeze(AllTheta(:, 1, Indx_T, :)), squeeze(AllTheta(:, 2, Indx_T, :)), StatsP);
Data2 = Data2(:, Stats2.p<StatsP.Alpha);

figure('units','normalized','outerposition',[0 0 1 .9])

subfigure([], [1 1], [1, 1], [], false, '', PlotProps);
Stats = corrAll(Data1, Data2, '', Performance_Labels(Stats1.p<StatsP.Alpha), 'EEG', Areas(Stats2.p<StatsP.Alpha), StatsP, PlotProps);

    title(TaskLabels{Indx_T}, 'FontSize', PlotProps.Text.TitleSize)
    caxis(CLims)
    colorbar off
end



%% plot all tasks together

PlotProps = P.Manuscript;
PlotProps.Axes.yPadding = 20;

load(fullfile(Paths.Data, 'EEG', 'Source', 'Table', 'mtrx_all_tasks_median_noZscore.mat'))
AllTheta = mean(mtrx_all_crtx, 5, 'omitnan'); % average the different frequencies (4-8)
Areas = cortical_areas;
Areas = replace(Areas, '_', ' ');

Grid = [6 1];

for Indx_P = 1:numel(Performance_Labels)
    Data1 = squeeze(Performance(:, 2, Indx_P) - Performance(:, 1, Indx_P));
figure('units','normalized','outerposition',[0 0 1 .5])

    for Indx_T  =1:numel(TaskLabels)
    Data2 = squeeze(AllTheta(:, 2, Indx_T, :)-AllTheta(:, 1, Indx_T, :));

subfigure([], Grid, [Indx_T, 1], [], true, '', PlotProps);
Stats = corrAll(Data1, Data2, '', Performance_Labels(Indx_P), 'EEG', Areas, StatsP, PlotProps);

    title([TaskLabels{Indx_T}, ' ', Performance_Labels{Indx_P}], 'FontSize', PlotProps.Text.TitleSize)
    caxis(CLims)
    colorbar off
    end
end


%% Correlation of task variables with each other
clc
Data1 = squeeze(Performance(:, 2, Order) - Performance(:, 1, Order));
figure('units','centimeters','position',[0 0 PlotProps.Figure.W3*1 PlotProps.Figure.Height*.7])
Stats = corrAll(Data1, Data1, '', Performance_Labels(Order), '', Performance_Labels(Order), StatsP, PlotProps, 'FDR');
axis square
colorbar off


%% correlation of areas with each other


for Indx_T = 1:numel(TaskLabels)
Data1 =  squeeze(AllTheta(:, 2, Indx_T, :)-AllTheta(:, 1, Indx_T, :));
figure('units','normalized','outerposition',[0 0 .5 1])
Stats = corrAll(Data1, Data1, '', Areas, '', Areas, StatsP, PlotProps, 'FDR');
axis square
colorbar off
title(TaskLabels{Indx_T})


end