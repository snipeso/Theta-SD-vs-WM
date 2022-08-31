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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure


%% Figure 3

%%% A: KSS

% parameters
Grid = [1 4];
Format = P.Manuscript;
YLim = [0 1.3];
Indx_BL = 1; % which is the baseline session to statistically compare to

% data & labels
Data = Answers.KSS;
L = Labels.KSS;

% plot
figure('units','centimeters','position',[0 0 Format.Figure.W3 Format.Figure.Height*.3])
subfigure([], Grid, [1 2], [], true, Format.Indexes.Letters{1}, Format);
data3D(Data, Indx_BL, Sessions.Labels, TaskLabels, ...
    Format.Color.AllTasks, StatsP, Format);

% adustments
legend({'' '', '', '', '', '', 'p<.05'})
set(legend, 'position', [0.36    0.7562    0.11    0.0659],  'ItemTokenSize', [5 5])
% set(legend, 'position', [0.3452    0.7562    0.1    0.0659])
ylim(YLim)
yticks(linspace(0, 1, numel(L)))
yticklabels(L)

X = xlim;
text(X(1)+diff(X)/2, YLim(2), 'KSS', 'FontSize', Format.Text.TitleSize, ... % title
    'FontName', Format.Text.FontName, 'FontWeight', 'bold', 'HorizontalAlignment', 'center') 

PosA = get(gca, 'position');
Shift = PosA(3)*.2;
PosA(1) = PosA(1)+Shift;
PosA(3) = PosA(3)-Shift;
set(gca, 'position', PosA) % shift so all text fits in plot

%%% B: Sleep deprivation KSS

% sort data by mean
Data = squeeze(Data(:, 3, :));
MEANS = mean(Data, 'omitnan');
[~, Order] = sort(MEANS, 'descend');

% plot
subfigure([], Grid, [1 3], [1 2], true, Format.Indexes.Letters{2}, Format);
data2D('box', Data(:, Order), TaskLabels(Order), [], [], Format.Color.AllTasks(Order, :), ...
    StatsP, Format);

% adjustments
ylim(YLim)
yticks(linspace(0, 1, numel(L)))

X = xlim;
text(X(1)+diff(X)/2, YLim(2), 'SD KSS', 'FontSize', Format.Text.TitleSize, ... % title
    'FontName', Format.Text.FontName, 'FontWeight', 'bold', 'HorizontalAlignment', 'center')

PosB = get(gca, 'position');
PosB([2, 4]) = PosA([2, 4]);
set(gca, 'position', PosB) % match position of second axis to the same as first


saveFig(strjoin({TitleTag, 'KSS'}, '_'), Paths.Paper, Format)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Figure 3-1

% parameters
Format = P.Manuscript;
Format.Axes.yPadding = 25;
Format.Axes.xPadding = 16;
Format.Figure.Padding = 45;
Grid = [3, 6];

YLim = [-.05 1.05];

AxesIndexes = [2, 4, 6];
Indx = 1;
Indx_BL = 1;

% labels
Questions_Order = {'KSS', 'Relaxing', 'Interesting'; ...
    'Focused',  'Difficult', 'Effortful';  ...
    'Performance',   'Motivation',  'Slept',};
Titles = {'Subjective Sleepiness', 'Relaxing', 'Engaging'; ...
    'Focus', 'Subjective Difficulty', 'Effort'; ...
    'Subjective Performance', 'Motivation', 'Slept',};



figure('units','centimeters','position',[0 0 Format.Figure.Width*1.2 Format.Figure.Height*.9])

for Indx_G1 = 1:Grid(1)
    for Indx_G2 = 1:3
        
        % data & labels
        Q = Questions_Order{Indx_G1, Indx_G2};
        Data = Answers.(Q);
        L = Labels.(Q);
        
        % plot
        Axis = subfigure([], Grid, [Indx_G1 AxesIndexes(Indx_G2)], [], true, {}, Format);
        
        if strcmp(Q, 'Slept') % hack to have just the legend
            data3D(Answers.Motivation, Indx_BL, [], TaskLabels, ...
                Format.Color.AllTasks, StatsP, Format);
            ylim([-10 -9])
            axis off
            continue
        end
        
        data3D(Data, Indx_BL, Sessions.Labels, TaskLabels, ...
            Format.Color.AllTasks, StatsP, Format);
        
        % adjustments
        ylim(YLim)
        yticks(linspace(0, 1, numel(L)))
        yticklabels(L)
        
        legend off
        
        title([Format.Indexes.Letters{Indx}, ': ' Titles{Indx_G1, Indx_G2}], ...
            'FontSize', Format.Text.TitleSize)
        Indx = Indx+1;
        
        %%% 2 way repeated measures anova with factors Session and Task
        Stats = anova2way(Data, FactorLabels, Sessions.Labels, TaskLabels, StatsP);
        TitleStats = strjoin({TitleTag, Titles{Indx_G1, Indx_G2}, 'rmANOVA'}, '_');
        saveStats(Stats, 'rmANOVA', Paths.PaperStats, TitleStats, StatsP)
    end
end

saveFig(strjoin({TitleTag, 'All'}, '_'), Paths.Paper, Format)


