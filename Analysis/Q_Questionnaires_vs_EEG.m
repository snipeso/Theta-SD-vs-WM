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
Bands = P.Bands;
PlotProps = P.Manuscript;

ROI = 'preROI';
Channels = P.Channels;

TitleTag = 'C_Questionnaires';
FactorLabels = {'Session', 'Task'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

% load questionnaire data
Filepath = fullfile(P.Paths.Data, 'Questionnaires');
[Answers, Labels] = loadAllBAT(Filepath, Participants, Sessions, AllTasks);

Questions = fieldnames(Answers);


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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%

Grid = [1 3];
Indx_B = 4;
CLims = [-.7 .7];
Data1 = squeeze(Answers.KSS(:, 3, :)) - squeeze(Answers.KSS(:, 1, :));

PlotProps = P.Manuscript;
PlotProps.Figure.Padding = 55;
figure('units','centimeters','position',[0 0 PlotProps.Figure.W3 PlotProps.Figure.Height*.3])

for Indx_Ch = 1:3
    Axes = subfigure([], Grid,[1 Indx_Ch], [], false, '', PlotProps);

    Data2 = squeeze(bchData(:, 3, :, Indx_Ch, Indx_B)) - squeeze(bchData(:, 1, :, Indx_Ch, Indx_B));
    Stats = corrAll(Data1, Data2, 'Sleepiness', TaskLabels, 'EEG', TaskLabels, StatsP, PlotProps);
    title(ChLabels{Indx_Ch}, 'FontSize', PlotProps.Text.TitleSize)
    axis square
    caxis(CLims)
    colorbar off
    if Indx_Ch > 1
        ylabel('')
        set(gca, 'YTick', [])
    end
end

 Axes = subfigure([], Grid,[1 Indx_Ch], [], false, '', PlotProps);
 Axes.Units = 'normalized';
 Axes.Position(1) =  Axes.Position(1)+.08;
 PlotProps.Colorbar.Location = 'eastoutside';
 PlotProps.Color.Steps.Divergent = 100;
plotColorbar('Divergent', CLims, 'R', PlotProps)






