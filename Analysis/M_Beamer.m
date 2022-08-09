% this script analyzes data from the PVT and LAT projector tasks
% (questionnaires, behavior, EEG) to demonstrate the return to baseline.

clear
clc
% close all

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
CompSessions = P.Sessions;
BeamSessions.LAT = { 'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam1', 'MainPost'};
BeamSessions.PVT = { 'BaselineBeam', 'MainPre', 'Session1Beam', 'Session2Beam', 'MainPost'};
BeamSessionLabels = {'BL','Pre', 'S1', 'S2', 'Post'};

AllTasks =  {'LAT', 'PVT'};
TaskLabels = AllTasks;
StatsP = P.StatsP;
TaskColors = [P.Manuscript.Color.Tasks.LAT; P.Manuscript.Color.Tasks.PVT];

TitleTag = 'M_Beamer';

Colors = [getColors([1, 2], '', 'orange'); getColors([1, 2], '', 'yellow')];

% "Tasks": LAT Beam, LAT comp, PVT Beam, PVT comp

%%% Load Questionnaires
Filepath = fullfile(P.Paths.Data, 'Questionnaires');
[BeamAnswers, Labels] = loadAllBAT(Filepath, Participants, BeamSessions, AllTasks);
[CompAnswers, ~] = loadAllBAT(Filepath, Participants, CompSessions, AllTasks);


%%% Load behavior
Source_Tables = fullfile(Paths.Data, 'Behavior');

% LAT
LAT = loadLATmeta(P, BeamSessions.LAT, false);
TotT = size(LAT.RT, 3);
LAT_RT_B = mean(LAT.RT, 3, 'omitnan');
LAT_Lapses_B = 100*(sum(squeeze(LAT.Tally) == 1, 3, 'omitnan')/TotT);

LAT = loadLATmeta(P, CompSessions.LAT, false);
TotT = size(LAT.RT, 3);
LAT_RT_C = mean(LAT.RT, 3, 'omitnan');
LAT_Lapses_C = 100*(sum(squeeze(LAT.Tally) == 1, 3, 'omitnan')/TotT);


% PVT
PVT = loadPVTmeta(P, BeamSessions.PVT, false);
PVT_RT_B = mean(PVT.RT, 3, 'omitnan');
TotT = size(PVT.RT, 3);
PVT_Lapses_B = 100*(sum(squeeze(PVT.Tally) == 2, 3, 'omitnan'))/TotT;

PVT = loadPVTmeta(P, CompSessions.PVT, false);
PVT_RT_C = mean(PVT.RT, 3, 'omitnan');
TotT = size(PVT.RT, 3);
PVT_Lapses_C = 100*(sum(squeeze(PVT.Tally) == 2, 3, 'omitnan'))/TotT;


%%% load EEG
Bands = P.Bands;
Duration = 4;
WelchWindow = 8;
P.Sessions = BeamSessions;
P.Sessions.Labels = BeamSessionLabels;
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
bchData_B = bandData(chData, Freqs, Bands, 'last');


% computer sessions
P.Sessions = CompSessions;
P.Sessions.Labels = {'BL', 'S1', 'S2'};
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);

% z-score it
zData = zScoreData(AllData, 'last');

% save it into bands
bData = bandData(zData, Freqs, Bands, 'last');

% average channel data into 2 spots
chData = meanChData(zData, Chanlocs, Channels.(ROI), 4);

% average frequencies into bands
bchData_C = bandData(chData, Freqs, Bands, 'last');

CLims_Diff = [-7 7];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figures for paper


%% Figure 13

Grid = [2 3];
Format = P.Manuscript;
Format.Axes.xPadding = 20;
Indx_BL = 1;

%%% Questionnaires

Shift = .08;
YLim = [-0.05 1.1];

% KSS
Data = BeamAnswers.KSS;
L = Labels.KSS;

figure('units','centimeters','position',[0 0 Format.Figure.W3 Format.Figure.Height*.5])
A = subfigure([], Grid, [1 1], [], true, Format.Indexes.Letters{1}, Format);
A.Position(1) = A.Position(1)+Shift;
A.Position(3) = A.Position(3)-Shift;
A.Position(4) = A.Position(4)-Shift/2;

hold on
plot([1 3 4], squeeze(mean(CompAnswers.KSS(:, :, 1), 'omitnan')), ':', 'LineWidth', 1, 'Color', TaskColors(1, :), 'HandleVisibility','on')
plot([1 3 4], squeeze(mean(CompAnswers.KSS(:, :, 2), 'omitnan')), ':', 'LineWidth', 1, 'Color', TaskColors(2, :), 'HandleVisibility', 'off')

data3D(Data, Indx_BL, BeamSessionLabels, TaskLabels, TaskColors, StatsP, Format);
ylim(YLim)
set(gca, 'XTickLabel', [])
yticks(linspace(0, 1, 9))
yticklabels(["Extremely alert", repmat("", 1, 7), "Fighting sleep"])
title('KSS', 'FontSize', Format.Text.TitleSize)
legend off
legend({'Desk', 'LAT', 'PVT'}, 'location', 'southwest')
set(legend, 'ItemTokenSize', [7 7])




% Motivation
Data = BeamAnswers.Motivation;
L = Labels.Motivation;

A = subfigure([], Grid, [2 1], [], true, Format.Indexes.Letters{2}, Format);
A.Position(1) = A.Position(1)+Shift;
A.Position(3) = A.Position(3)-Shift;
A.Position(4) = A.Position(4)-Shift/2;

hold on
plot([1 3 4], squeeze(mean(CompAnswers.Motivation(:, :, 1), 'omitnan')), ':', 'LineWidth', 1, 'Color', TaskColors(1, :), 'HandleVisibility','on')
plot([1 3 4], squeeze(mean(CompAnswers.Motivation(:, :, 2), 'omitnan')), ':', 'LineWidth', 1, 'Color', TaskColors(2, :), 'HandleVisibility', 'off')

data3D(Data, Indx_BL, BeamSessionLabels, TaskLabels, TaskColors, StatsP, Format);
ylim(YLim)
yticks([0 .5 1])
yticklabels({'Not motivated', '', 'Motivated'})
title('Motivation', 'FontSize', Format.Text.TitleSize)
set(gca, 'YDir','reverse')
legend off



%%% Behavior

% RTs
Data = cat(3, LAT_RT_B, PVT_RT_B);

A = subfigure([], Grid, [1 2], [], true, Format.Indexes.Letters{3}, Format);
A.Position(1) = A.Position(1)+Shift/2;
A.Position(3) = A.Position(3)-Shift/2;
A.Position(4) = A.Position(4)-Shift/2;

hold on
plot([1 3 4], squeeze(mean(LAT_RT_C(:, :), 'omitnan')), ':', 'LineWidth', 1, 'Color', TaskColors(1, :), 'HandleVisibility','on')
plot([1 3 4], squeeze(mean(PVT_RT_C(:, :), 'omitnan')), ':', 'LineWidth', 1, 'Color', TaskColors(2, :), 'HandleVisibility', 'off')

data3D(Data, Indx_BL, BeamSessionLabels, TaskLabels, TaskColors, StatsP, Format);
legend off
set(gca, 'XTickLabel', [])
ylabel('seconds')
title('RTs', 'FontSize', Format.Text.TitleSize)
padAxis('y')


% Lapses
Data = cat(3, LAT_Lapses_B, PVT_Lapses_B);

A = subfigure([], Grid, [2 2], [], true, Format.Indexes.Letters{4}, Format);
A.Position(1) = A.Position(1)+Shift/2;
A.Position(3) = A.Position(3)-Shift/2;
A.Position(4) = A.Position(4)-Shift/2;

hold on
plot([1 3 4], squeeze(mean(LAT_Lapses_C(:, :), 'omitnan')), ':', 'LineWidth', 1, 'Color', TaskColors(1, :), 'HandleVisibility','on')
plot([1 3 4], squeeze(mean(PVT_Lapses_C(:, :), 'omitnan')), ':', 'LineWidth', 1, 'Color', TaskColors(2, :), 'HandleVisibility', 'off')

data3D(Data, Indx_BL, BeamSessionLabels, TaskLabels, TaskColors, StatsP, Format);
legend off
ylabel('%')
ylim([0 25])
title('Lapses', 'FontSize', Format.Text.TitleSize)




%%% EEG
Indx_B = 2;
Titles = {'Front Theta', 'Center Theta'};
FigLabels = P.Labels;
YLim = [-.5 1.4];

for Indx_Ch = [1 2]

    Data_B = squeeze(bchData_B(:, :, :, Indx_Ch, Indx_B));
    Data_C = squeeze(mean(bchData_C(:, :, :, Indx_Ch, Indx_B), 'omitnan'));

    A = subfigure([], Grid, [Indx_Ch 3], [], true, Format.Indexes.Letters{4+Indx_Ch}, Format);
A.Position(1) = A.Position(1)+Shift/2;
A.Position(3) = A.Position(3)-Shift/2;
A.Position(4) = A.Position(4)-Shift/2;

    hold on
    plot([1 3 4], Data_C(:, 1), ':', 'LineWidth', 1, 'Color', TaskColors(1, :), 'HandleVisibility','on')
    plot([1 3 4], Data_C(:, 2), ':', 'LineWidth', 1, 'Color', TaskColors(2, :), 'HandleVisibility', 'off')


    data3D(Data_B, Indx_BL, BeamSessionLabels, TaskLabels, TaskColors, StatsP, Format);
    legend off
    if Indx_Ch ~= 2
        set(gca, 'XTickLabel', [])
    end
    ylabel(P.Labels.zPower)
    ylim(YLim)
    title(Titles{Indx_Ch}, 'FontSize', Format.Text.TitleSize)
end



saveFig([TitleTag, 'v2'], Paths.Paper, Format)
