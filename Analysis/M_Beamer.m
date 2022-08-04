% this script analyzes data from the PVT and LAT projector tasks
% (questionnaires, behavior, EEG) to demonstrate the return to baseline.

clear
clc
% close all

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
Sessions.LAT = { 'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'MainPost'};
Sessions.PVT = { 'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam', 'MainPost'};
SessionLabels = {'BL','Pre', 'S1', 'S2', 'Post'};

AllTasks =  {'LAT', 'PVT'};
TaskLabels = AllTasks;
StatsP = P.StatsP;
TaskColors = [P.Manuscript.Color.Tasks.LAT; P.Manuscript.Color.Tasks.PVT];

TitleTag = 'M_Beamer';


%%% Load Questionnaires
Filepath = fullfile(P.Paths.Data, 'Questionnaires');
[Answers, Labels] = loadAllBAT(Filepath, Participants, Sessions, AllTasks);




%%% Load behavior
Source_Tables = fullfile(Paths.Data, 'Behavior');

% LAT
LAT = loadLATmeta(P, Sessions.LAT, false);
TotT = size(LAT.RT, 3);

LAT_RT = mean(LAT.RT, 3, 'omitnan');
LAT_Correct = 100*(sum(squeeze(LAT.Tally) == 3, 3, 'omitnan')/TotT);
LAT_Lapses = 100*(sum(squeeze(LAT.Tally) == 1, 3, 'omitnan')/TotT);


% PVT
PVT = loadPVTmeta(P, Sessions.PVT, false);
TotT = size(PVT.RT, 3);

PVT_RT = mean(PVT.RT, 3, 'omitnan');
PVT_Lapses = sum(squeeze(PVT.Tally) == 2, 3, 'omitnan');



%%% load EEG
Bands = P.Bands;
Duration = 4;
WelchWindow = 8;
P.Sessions = Sessions;
P.Sessions.Labels = SessionLabels;
Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];


Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);

% z-score it
zData = zScoreData(AllData, 'last');

% save it into bands
bData = bandData(zData, Freqs, Bands, 'last');

Channels = P.Channels;
ROI = 'preROI';
% average channel data into 2 spots
chData = meanChData(zData, Chanlocs, Channels.(ROI), 4);

% average frequencies into bands
bchData = bandData(chData, Freqs, Bands, 'last');

CLims_Diff = [-7 7];



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

figure('units','centimeters','position',[0 0 Format.Figure.W3 Format.Figure.Height*.3])
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
set(gca, 'YDir','reverse')
yticks([0 .5 1])
yticklabels({'Not motivated', '', 'Motivated'})
title('B: Motivation', 'FontSize', Format.Text.TitleSize)
legend off



%%% Behavior

% RTs
Data = cat(3, LAT_RT, PVT_RT);

A = subfigure([], Grid, [1 3], [1 2], true, '', Format);
A.Position(1) = A.Position(1)+Shift/2;
A.Position(3) = A.Position(3)-Shift;
data3D(Data, Indx_BL, SessionLabels, TaskLabels, TaskColors, StatsP, Format);
legend off
set(gca, 'XTickLabel', [])
ylabel('seconds')
title('C: RTs', 'FontSize', Format.Text.TitleSize)


% Lapses
Data = cat(3, LAT_Lapses, PVT_Lapses);

A = subfigure([], Grid, [2 3], [1 2], true, '', Format);
A.Position(1) = A.Position(1)+Shift/2;
A.Position(3) = A.Position(3)-Shift;
data3D(Data, Indx_BL, SessionLabels, TaskLabels, TaskColors, StatsP, Format);
legend off
ylabel('#')
ylim([0 25])
title('D: Lapses', 'FontSize', Format.Text.TitleSize)




%%% EEG
Indx_B = 2;

FigLabels = P.Labels;

for Indx_T = 1:2
    for Indx_S = 2:numel(SessionLabels)

        BL = squeeze(bData(:, 1, Indx_T, :, Indx_B));
        SD = squeeze(bData(:, Indx_S, Indx_T, :, Indx_B));

        A = subfigure([], Grid, [Indx_T Indx_S+3], [], false, '', Format);
        shiftaxis(A, Format.Axes.xPadding, Format.Axes.yPadding)
        Stats = topoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Format, FigLabels);
        colorbar off
        colormap(gca, Format.Color.Maps.Divergent)
        if Indx_T ==1
            title(SessionLabels{Indx_S}, 'FontSize', Format.Text.TitleSize)
        end
        % task label
        if Indx_S == 2
            X = get(gca, 'XLim');
            Y = get(gca, 'YLim');
            text(X(1)-diff(X)*.15, Y(1)+diff(Y)*.5, TaskLabels{Indx_T}, ...
                'FontSize', Format.Text.TitleSize, 'FontName', Format.Text.FontName, ...
                'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'Rotation', 90);
        end
    end
end



saveFig([TitleTag, 'v1'], Paths.Paper, Format)




%% Figure 13 v2

Grid = [2 3];
Format = P.Manuscript;
Format.Axes.xPadding = 20;
Indx_BL = 1;

%%% Questionnaires

Shift = .08;
YLim = [-0.05 1.05];

% KSS
Data = Answers.KSS;
L = Labels.KSS;

figure('units','centimeters','position',[0 0 Format.Figure.W3 Format.Figure.Height*.4])
A = subfigure([], Grid, [1 1], [], true, '', Format);
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

A = subfigure([], Grid, [2 1], [], true, '', Format);
A.Position(1) = A.Position(1)+Shift;
A.Position(3) = A.Position(3)-Shift;
data3D(Data, Indx_BL, SessionLabels, TaskLabels, TaskColors, StatsP, Format);
ylim(YLim)
yticks([0 .5 1])
yticklabels({'Not motivated', '', 'Motivated'})
title('B: Motivation', 'FontSize', Format.Text.TitleSize)
set(gca, 'YDir','reverse')
legend off



%%% Behavior

% RTs
Data = cat(3, LAT_RT, PVT_RT);

A = subfigure([], Grid, [1 2], [], true, '', Format);
data3D(Data, Indx_BL, SessionLabels, TaskLabels, TaskColors, StatsP, Format);
legend off
set(gca, 'XTickLabel', [])
ylabel('seconds')
title('C: RTs', 'FontSize', Format.Text.TitleSize)


% Lapses
Data = cat(3, LAT_Lapses, PVT_Lapses);

A = subfigure([], Grid, [2 2], [], true, '', Format);
data3D(Data, Indx_BL, SessionLabels, TaskLabels, TaskColors, StatsP, Format);
legend off
ylabel('#')
ylim([0 25])
title('D: Lapses', 'FontSize', Format.Text.TitleSize)




%%% EEG
Indx_B = 2;
Titles = {'D: Front Theta', 'E: Center Theta'};
FigLabels = P.Labels;
YLim = [-.5 1.4];

for Indx_Ch = [1 2]

    Data = squeeze(bchData(:, :, :, Indx_Ch, Indx_B));

    A = subfigure([], Grid, [Indx_Ch 3], [], true, '', Format);
    data3D(Data, Indx_BL, SessionLabels, TaskLabels, TaskColors, StatsP, Format);
legend off
if Indx_Ch ~= 2
set(gca, 'XTickLabel', [])
end
ylabel(P.Labels.zPower)
ylim(YLim)
title(Titles{Indx_Ch}, 'FontSize', Format.Text.TitleSize)
end



saveFig([TitleTag, 'v2'], Paths.Paper, Format)
