% this script plots the spectrums of EEG for specific channels and how the
% theta peak changes with conditions.

clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Sessions = P.Sessions;
Channels = P.Channels;
StatsP = P.StatsP;
PlotProps = P.Manuscript;
Labels = P.Labels;

SmoothFactor = 1; % in Hz, range to smooth over

Duration = 4;
WelchWindow = 8;
ChannelLabels = 'preROI';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = 'H_Task_Spectrums';

Results = fullfile(Paths.Results, 'Task_Spectrums', Tag, ChannelLabels);
if ~exist(Results, 'dir')
    mkdir(Results)
end

ChannelStruct =  Channels.(ChannelLabels);
ChLabels = fieldnames(ChannelStruct);

%%% load data
Filepath =  fullfile(P.Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);

% z-score it
zData = zScoreData(AllData, 'last');

% smooth spectrums
sData = smoothFreqs(zData, Freqs, 'last', SmoothFactor);
sDataRaw = smoothFreqs(AllData, Freqs, 'last', SmoothFactor);

% average across channels
chData = meanChData(sData, Chanlocs, ChannelStruct, 4);
chDataRaw = meanChData(sDataRaw, Chanlocs, ChannelStruct, 4);

% change frequency bin
StatsP.FreqBin = diff(Freqs(1:2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure

%% Figure SPECP plot spectrum changes for all participants for each task

PlotProps = P.Manuscript;

xLog = false;
Indx_Ch = 1;
Grid = [2 3];
xLims = [2 10];
yLims = [-1.5 6.5];

Coordinates = [1 1; 1 2; 1 3; 2 1; 2 2; 2 3]; % stupd way of dealing with grid indexing


figure('units','centimeters','position',[0 0 PlotProps.Figure.Width PlotProps.Figure.Height*.47])
for Indx_T = 1:numel(AllTasks)
    Data = squeeze(chData(:, [1, 3], Indx_T, Indx_Ch, :));
    
    subfigure([], Grid, Coordinates(Indx_T, :), [], true, '', PlotProps);
    plotSpectrumMountains(Data, Freqs, xLog, xLims, PlotProps, Labels)
    title(TaskLabels{Indx_T}, 'FontSize', PlotProps.Text.TitleSize)
    ylim(yLims)
    
    if Indx_T <= 3 % only x labels for bottom row
        xlabel('')
    end
    
    if Indx_T == 1 || Indx_T == 4 % only y labels for left-most plots
        ylabel(Labels.zPower)
    end
end

set(gcf, 'Color', 'w')

saveFig([TitleTag, '_zscored'], Paths.Paper, PlotProps)



%% Figure SPECR Same as above, but raw values
PlotProps = P.Manuscript;

xLog = false;
Indx_Ch = 1;
Grid = [2 3];
xLims = [2 10];
yLims = [0 60];

Coordinates = [1 1; 1 2; 1 3; 2 1; 2 2; 2 3]; % stupd way of dealing with grid indexing


figure('units','centimeters','position',[0 0 PlotProps.Figure.Width PlotProps.Figure.Height*.47])
for Indx_T = 1:numel(AllTasks)
    Data = squeeze(chDataRaw(:, [1, 3], Indx_T, Indx_Ch, :));
    
    subfigure([], Grid, Coordinates(Indx_T, :), [], true, '', PlotProps);
    plotSpectrumMountains(Data, Freqs, xLog, xLims, PlotProps, Labels)
    title(TaskLabels{Indx_T}, 'FontSize', PlotProps.Text.TitleSize)
    ylim(yLims)
    
    if Indx_T <= 3 % only x labels for bottom row
        xlabel('')
    end
    
    if Indx_T == 1 || Indx_T == 4 % only y labels for left-most plots
        ylabel(Labels.Power)
    end
end

set(gcf, 'Color', 'w')

saveFig([TitleTag, '_raw'], Paths.Paper, PlotProps)


%% Figure SPECZ Plot whole spectrums

PlotProps = P.Manuscript;

% format variables
PlotProps.Axes.xPadding = 15; % smaller distance than default because no labels
PlotProps.Axes.yPadding = 15;
PlotProps.Figure.Padding = 90;

Grid = [numel(ChLabels),numel(AllTasks)];
YLim = [-1 3.5];

Log = true; % whether to plot on log scale or not
figure('units','centimeters','position',[0 0 PlotProps.Figure.Width*1.1 PlotProps.Figure.Height*.6])

for Indx_Ch = 1:numel(ChLabels)
    for Indx_T = 1:numel(AllTasks)
        Data = squeeze(chData(:, :, Indx_T, Indx_Ch, :));
        
        %%% plot
        subfigure([], Grid, [Indx_Ch, Indx_T], [], true, '', PlotProps);
        Stats = plotSpectrumDiff(Data, Freqs, 1, Sessions.Labels, flip(PlotProps.Color.Sessions(:, :, Indx_T)), Log, PlotProps, StatsP, Labels);
        
        Title = strjoin({TitleTag, 'Task_Spectrum', TaskLabels{Indx_T}, ChLabels{Indx_Ch}}, '_');
        saveStats(Stats, 'Spectrum', Paths.PaperStats, Title, StatsP)
        
        set(gca, 'FontSize', PlotProps.Text.AxisSize, 'YLim', YLim)
        
        % plot labels/legends only in specific locations
        if Indx_Ch > 1 || Indx_T > 1 % first tile
            legend off
            
        end
        
        if Indx_T == 1 % first column
            ylabel(Labels.zPower)
            X = double(get(gca, 'XLim'));
            text(X(1)-diff(X)*.5, YLim(1)+diff(YLim)*.5, ChLabels{Indx_Ch}, ...
                'FontSize', PlotProps.Text.TitleSize, 'FontName', PlotProps.Text.FontName, ...
                'FontWeight', 'Bold', 'Rotation', 90, 'HorizontalAlignment', 'Center');
        else
            ylabel ''
        end
        
        if Indx_Ch == 1 % first row
            title(TaskLabels{Indx_T}, 'FontSize', PlotProps.Text.TitleSize, 'Color', 'k')
        end
        
        if Indx_Ch == numel(ChLabels) % last row
            xlabel(Labels.Frequency)
        else
            xlabel ''
        end
    end
end

% save
saveFig(strjoin({TitleTag, 'averages'}, '_'), Paths.Paper, PlotProps)



%% Figure PEKZ peak frequency and prominence

clc
Peaks = nan(numel(Participants), numel(Sessions.Labels), numel(AllTasks), numel(ChLabels));
Prominence = Peaks;
PeakRange = [3 9];

for Indx_T = 1:numel(AllTasks)
    for Indx_P = 1:numel(Participants)
        for Indx_S = 1:numel(Sessions.Labels)
            Data = squeeze(chData(Indx_P, Indx_S, Indx_T, :, :));
            [Peaks(Indx_P, Indx_S, Indx_T, :, :), ~, Prominence(Indx_P, Indx_S, Indx_T, :, :)] ...
                = findPeaks(Data, PeakRange, Freqs, false);
        end
    end
    
    % frontal peak frequency
    Ch_Indx = 1;
    Data1 = squeeze(Peaks(:, 1, Indx_T, Ch_Indx));
    Data2 = squeeze(Peaks(:, 3, Indx_T,  Ch_Indx));
    Stats = pairedttest(Data1, Data2, StatsP);
    disp([TaskLabels{Indx_T}, ':'])
    disp('---PEAK FREQUENCY---')
    disp(['BL Mean: ', num2str(Stats.mean1), ' STD: ', num2str(Stats.std1) ])
    disp(['SD Mean: ', num2str(Stats.mean2), ' STD: ', num2str(Stats.std2) ])
    disp(['p: ', num2str(Stats.p), ' t: ', num2str(Stats.t) ' g: ', num2str(Stats.hedgesg)])
    Title = strjoin({TitleTag, 'Peaks', TaskLabels{Indx_T}, ChLabels{Ch_Indx}}, '_');
    saveStats(Stats, 'Paired', Paths.PaperStats, Title, StatsP)
    
    
    % frontal peak prominence
    Ch_Indx = 1;
    Data1 = squeeze(Prominence(:, 1, Indx_T, Ch_Indx));
    Data2 = squeeze(Prominence(:, 3, Indx_T,  Ch_Indx));
    Stats = pairedttest(Data1, Data2, StatsP);
    disp([TaskLabels{Indx_T}, ':'])
    disp('---PEAK Prominence---')
    disp(['BL Mean: ', num2str(Stats.mean1), ' STD: ', num2str(Stats.std1) ])
    disp(['SD Mean: ', num2str(Stats.mean2), ' STD: ', num2str(Stats.std2) ])
    disp(['p: ', num2str(Stats.p), ' t: ', num2str(Stats.t) ' g: ', num2str(Stats.hedgesg)])
    Title = strjoin({TitleTag, 'Prominence', TaskLabels{Indx_T}, ChLabels{Ch_Indx}}, '_');
    saveStats(Stats, 'Paired', Paths.PaperStats, Title, StatsP)
    disp('****')
end


%%
Grid = [2 2];
YLims = [0 8];
PlotProps = P.Manuscript;
PlotProps.Axes.yPadding = 40;
PlotProps.Axes.xPadding = 40;

figure('units','centimeters','position',[0 0 PlotProps.Figure.Width PlotProps.Figure.Height*.5])

% BL Prom
Data = squeeze(Prominence(:, 1, :, 1));
subfigure([], Grid, [1 1], [], true, PlotProps.Indexes.Letters{1}, PlotProps);
data2D('line', Data, TaskLabels, [], [0 6], PlotProps.Color.Participants, StatsP, PlotProps);
title('BL Prominence', 'FontSize', PlotProps.Text.TitleSize)
ylim(YLims)
ylabel(Labels.zPower)

% SD Prom
Data = squeeze(Prominence(:, 3, :, 1));
subfigure([], Grid, [1 2], [], true, PlotProps.Indexes.Letters{2}, PlotProps);
Stats = data2D('line',Data, TaskLabels, [], [], PlotProps.Color.Participants, StatsP, PlotProps);
title('SD Prominence',  'FontSize', PlotProps.Text.TitleSize)
ylim(YLims)

% BL Peaks
Data = squeeze(Peaks(:, 1, :, 1));
subfigure([], Grid, [2 1], [], true, PlotProps.Indexes.Letters{3}, PlotProps);
Stats = data2D('line',Data, TaskLabels, [], [], PlotProps.Color.Participants, StatsP, PlotProps);
title('BL Peaks', 'FontSize', PlotProps.Text.TitleSize)
ylim([2 11])
ylabel(Labels.Frequency)

% SD Peaks
Data = squeeze(Peaks(:, 2, :, 1));
subfigure([], Grid, [2 2], [], true, PlotProps.Indexes.Letters{4}, PlotProps);
Stats = data2D('line',Data, TaskLabels, [], [], PlotProps.Color.Participants, StatsP, PlotProps);
title('SD Peaks', 'FontSize', PlotProps.Text.TitleSize)
ylim([2 11])


% save
saveFig([TitleTag, '_peaks'], Paths.Paper, PlotProps)


%% extra plot to see change in peak frequency

figure('units','centimeters','position',[0 0 PlotProps.Figure.Width*.6 PlotProps.Figure.Height*.4])
PlotProps = P.Manuscript;
PlotProps.Axes.xPadding = 40;

% plot change in prominence for all data
Data = squeeze(Prominence(:, :, :, 1));
subfigure([], [1 2], [1 1], [], true, PlotProps.Indexes.Letters{1}, PlotProps);
data3D(Data, 1, Sessions.Labels, TaskLabels, PlotProps.Color.AllTasks, StatsP, PlotProps)
ylabel(Labels.zPower)
ylim([0 4])
title('Prominence')

Data = squeeze(Peaks(:, :, :, 1));
subfigure([], [1 2], [1 2], [], true, PlotProps.Indexes.Letters{2}, PlotProps);
data3D(Data, 1, Sessions.Labels, TaskLabels, PlotProps.Color.AllTasks, StatsP, PlotProps)
legend off
ylabel(Labels.Frequency)
ylim([4 8])
title('Frequency')

% save
% saveFig('TaskPeaks', Paths.Results, PlotProps)


