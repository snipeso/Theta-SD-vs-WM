% this script analyzes data from the PVT and LAT projector tasks
% (questionnaires, behavior, EEG) to demonstrate the return to baseline.

clear
clc
close all

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
Sessions.LAT = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'MainPost'};
Sessions.PVT = {'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam', 'MainPost'};
SessionLabels = {'BL', 'Pre', 'S1', 'S2', 'Post'};

AllTasks =  {'LAT', 'PVT'};
TaskLabels = AllTasks;
StatsP = P.StatsP;
TaskColors = [P.Manuscript.Color.Tasks.LAT; P.Manuscript.Color.Tasks.PVT];

TitleTag = 'M_Beamer';


%%% Load Questionnaires
Filepath = fullfile(P.Paths.Data, 'Questionnaires');
[Answers, Labels] = loadAllBAT(Filepath, Participants, Sessions, AllTasks);




%%% Load behavior










%%% load EEG









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figures for paper

%% Figure 13

Grid = [2 8];
Format = P.Manuscript;
Indx_BL = 1;

%%% Questionnaires

Shift = .08;
YLim = [-0.05 1.05];

% KSS
Data = Answers.KSS;
L = Labels.KSS;

figure('units','centimeters','position',[0 0 Format.Figure.W3 Format.Figure.Height*.4])
A = subfigure([], Grid, [1 1], [1 2], true, '', Format);
A.Position(1) = A.Position(1)+Shift;
A.Position(3) = A.Position(3)-Shift;
data3D(Data, Indx_BL, SessionLabels, TaskLabels, TaskColors, StatsP, Format);
ylim(YLim)
set(gca, 'XTickLabel', [])
yticks(linspace(0, 1, 9))
yticklabels(["Extremely alert", repmat("", 1, 7), "Fighting sleep"])
title('A: KSS', 'FontSize', Format.Text.TitleSize)
legend off



% Motivation
Data = Answers.Motivation;
L = Labels.Motivation;
A = subfigure([], Grid, [2 1], [1 2], true, '', Format);
A.Position(1) = A.Position(1)+Shift;
A.Position(3) = A.Position(3)-Shift;
data3D(Data, Indx_BL, SessionLabels, TaskLabels, TaskColors, StatsP, Format);
ylim(YLim)
yticks([0 .5 1])
yticklabels({'Not motivated', '', 'Motivated'})
title('B: Motivation', 'FontSize', Format.Text.TitleSize)
legend off












