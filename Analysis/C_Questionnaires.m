% script for analyzing and plotting questionnaire data from the tasks.

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;

Sessions = P.Sessions;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
StatsP = P.StatsP;

TitleTag = 'C_Questionnaires';

FactorLabels = {'Session', 'Task'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

% load questionnaire data
Filepath = fullfile(P.Paths.Data, 'Questionnaires');
[Answers, Labels] = loadAllBAT(Filepath, Participants, Sessions, AllTasks);

Questions = fieldnames(Answers);

Main_Results = fullfile(Paths.Results, 'Task_Questionnaires');
if ~exist(Main_Results, 'dir')
    for Indx_Q = 1:numel(Questions)
        mkdir(fullfile(Main_Results, Questions{Indx_Q}))
    end
end

% set to nan all answers for a questionnaire when more than 4 participants are missing data
for Indx_T = 1:numel(AllTasks)
    for Indx_Q = 1:numel(Questions)
        NanP = nnz(any(isnan(Answers.(Questions{Indx_Q})(:, :, Indx_T)), 2));
        
        if NanP > 4
            Answers.(Questions{Indx_Q})(:, :, Indx_T) = nan;
        end
    end
end


Labels.KSS(7:9) = {'Sleepy, but no effort to keep awake', 'Sleepy, some effort to keep awake', 'Fighting sleep'}; % Fix


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure


%% Figure KSSR plots changes in subjective sleepiness

Grid = [1 4];
Format = P.Manuscript;
YLim = [0 1.3];
Indx_BL = 1;

Data = Answers.KSS;
L = Labels.KSS;
figure('units','centimeters','position',[0 0 Format.Figure.Width Format.Figure.Height*.23])
subfigure([], Grid, [1 2], [], true, Format.Indexes.Letters{1}, Format);
data3D(Data, Indx_BL, Sessions.Labels, TaskLabels, ...
    Format.Color.AllTasks, StatsP, Format);
legend off
ylim(YLim)
yticks(linspace(0, 1, numel(L)))
yticklabels(L)
X = xlim;
text(X(1)+diff(X)/2, YLim(2), 'KSS', 'FontSize', Format.Text.TitleSize, ...
    'FontName', Format.Text.FontName, 'FontWeight', 'bold', 'HorizontalAlignment', 'center')


Data = squeeze(Data(:, 3, :));
MEANS = nanmean(Data);
[~, Order] = sort(MEANS, 'descend');


subfigure([], Grid, [1 3], [1 2], true, Format.Indexes.Letters{2}, Format);
data2D('box', Data(:, Order), TaskLabels(Order), [], [], Format.Color.AllTasks(Order, :), ...
    StatsP, Format);

ylim(YLim)
yticks(linspace(0, 1, numel(L)))

X = xlim;
text(X(1)+diff(X)/2, YLim(2), 'SD KSS', 'FontSize', Format.Text.TitleSize, ...
    'FontName', Format.Text.FontName, 'FontWeight', 'bold', 'HorizontalAlignment', 'center')


set(gca, 'YTickLabel',[],'YGrid', 'on')

saveFig(strjoin({TitleTag, 'KSS'}, '_'), Paths.Paper, Format)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Plot all questions in Supplementary Figure QUEZ and get stats for Table SUP_QUEZ_TBL

Format = P.Manuscript;
Format.Axes.yPadding = 50;
Format.Axes.xPadding = 35;
Format.Figure.Padding = 90;

YLim = [-.05 1.05];
Questions_Order = {'KSS', 'Relaxing', 'Interesting'; ...
    'Focused',  'Difficult', 'Effortful';  ...
    'Performance',   'Motivation',  'Slept',};
Titles = {'Subjective Sleepiness', 'Relaxing', 'Engaging'; ...
    'Focus', 'Subjective Difficulty', 'Effort'; ...
    'Subjective Performance', 'Motivation', 'Slept',};

Grid = [3, 6];

figure('units','centimeters','position',[0 0 Format.Figure.Width*1.2 Format.Figure.Height*.7])

AxesIndexes = [2, 4, 6];
Indx = 1;
Indx_BL = 1;

for Indx_G1 = 1:Grid(1)
    for Indx_G2 = 1:3
        
        Q = Questions_Order{Indx_G1, Indx_G2};
        Data = Answers.(Q);
        L = Labels.(Q);
        
        
        Axis = subfigure([], Grid, [Indx_G1 AxesIndexes(Indx_G2)], [], true, {}, Format);
        
        if strcmp(Q, 'Slept') % hack to have just the legend
            data3D(Answers.Motivation, Indx_BL, [], TaskLabels, ...
                Format.Color.AllTasks, StatsP, Format);
            ylim([-10 -9])
            axis off
            continue
        end
        
        ylim(YLim)
        yticks(linspace(0, 1, numel(L)))
        yticklabels(L)
        
        data3D(Data, Indx_BL, Sessions.Labels, TaskLabels, ...
            Format.Color.AllTasks, StatsP, Format);
        
        legend off
        
        title([Format.Indexes.Letters{Indx}, ': ' Titles{Indx_G1, Indx_G2}], 'FontSize', Format.Text.TitleSize)
        Indx = Indx+1;
        
        % 2 way repeated measures anova with factors Session and Task
        Stats = anova2way(Data, FactorLabels, Sessions.Labels, TaskLabels, StatsP);
        TitleStats = strjoin({TitleTag, Titles{Indx_G1, Indx_G2}, 'rmANOVA'}, '_');
        saveStats(Stats, 'rmANOVA', Paths.PaperStats, TitleStats, StatsP)
    end
end

saveFig(strjoin({TitleTag, 'All'}, '_'), Paths.Paper, Format)


