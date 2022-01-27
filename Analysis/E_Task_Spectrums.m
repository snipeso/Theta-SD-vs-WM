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
Format = P.Format;
Sessions = P.Sessions;
Channels = P.Channels;
StatsP = P.StatsP;
Pixels = P.Pixels;

PeakRange = [3 15];
SmoothFactor = 1; % in Hz, range to smooth over

Duration = 4;
WelchWindow = 8;
ChannelLabels = 'preROI';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = strjoin({'Task', 'Spectrums', 'Welch', num2str(WelchWindow), 'zScored'}, '_');

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

%% plot spectrum changes for all participants for each task

xLog = false;
Indx_Ch = 1;
Grid = [2 3];
xLims = [2 10];
yLims = [-1.5 6.4];

Coordinates = [1 1; 1 2; 1 3; 2 1; 2 2; 2 3]; % stupd way of dealing with grid indexing

% Pixels.xPadding = 10; % smaller distance than default because no labels
% Pixels.yPadding = 10;

figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.47])
for Indx_T = 1:numel(AllTasks)
    Data = squeeze(chData(:, [1, 3], Indx_T, Indx_Ch, :));
    
    subfigure([], Grid, Coordinates(Indx_T, :), [], '', Pixels);
    %     Indx = Indx+1;
    
    plotSpectrumFlames(Data, Freqs, xLog, xLims, Pixels)
    title(TaskLabels{Indx_T}, 'FontSize', Pixels.LetterSize)
    ylim(yLims)
    
    if Indx_T <= 3 % only x labels for bottom row
        xlabel('')
    end
    
    if Indx_T == 1 || Indx_T == 4 % only y labels for left-most plots
        ylabel(Pixels.Labels.zPower)
    end
end

set(gcf, 'Color', 'w')

saveFig('Spectrums_AllP', Paths.Paper, Format)



%% Same as above, but raw values

yLims = [0 60];

figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.47])
for Indx_T = 1:numel(AllTasks)
    Data = squeeze(chDataRaw(:, [1, 3], Indx_T, Indx_Ch, :));
    subfigure([], Grid, Coordinates(Indx_T, :), [], '', Pixels);
    %     Indx = Indx+1;
    
    
    plotSpectrumFlames(Data, Freqs, xLog, xLims, Pixels)
    title(TaskLabels{Indx_T}, 'FontSize', Pixels.LetterSize)
    ylim(yLims)
    
    if Indx_T <= 3 % only x labels for bottom row
        xlabel('')
    end
    
    if Indx_T == 1 || Indx_T == 4 % only y labels for left-most plots
        ylabel(Pixels.Labels.Power)
    end
end

set(gcf, 'Color', 'w')

saveFig('Spectrums_AllP_RAW', Paths.Paper, Format)


%% Plot spectrums as ch x task, shade indicating task block

% format variables
Pixels.xPadding = 10; % smaller distance than default because no labels
Pixels.yPadding = 10;

Grid = [numel(ChLabels),numel(AllTasks)];
YLim = [-1 3.5];

Log = true; % whether to plot on log scale or not
figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.47])
Indx = 1; % tally of axes

for Indx_Ch = 1:numel(ChLabels)
    for Indx_T = 1:numel(AllTasks)
        Data = squeeze(chData(:, :, Indx_T, Indx_Ch, :));
        
        %%% plot
        Axes(Indx) = subfigure([], Grid, [Indx_Ch, Indx_T], [], '', Pixels);
        Indx = Indx+1;
        Stats = plotSpectrumDiff(Data, Freqs, 1, Sessions.Labels, flip(Format.Colors.Sessions(:, :, Indx_T)), Log, Pixels, StatsP);
        
        Title = strjoin({'Task_Spectrum', TaskLabels{Indx_T}, ChLabels{Indx_Ch}}, '_');
        saveStats(Stats, 'Spectrum', Paths.PaperStats, Title, StatsP)
        
        set(gca, 'FontSize', Pixels.FontSize, 'YLim', YLim)
        
        % plot labels/legends only in specific locations
        if Indx_Ch > 1 || Indx_T > 1 % first tile
            legend off
            
        end
        
        if Indx_T == 1 % first column
            ylabel(Format.Labels.zPower)
            X = double(get(gca, 'XLim'));
            text(X(1)-diff(X)*.5, YLim(1)+diff(YLim)*.5, ChLabels{Indx_Ch}, ...
                'FontSize', Pixels.LetterSize, 'FontName', Format.FontName, ...
                'FontWeight', 'Bold', 'Rotation', 90, 'HorizontalAlignment', 'Center');
        else
            ylabel ''
        end
        
        if Indx_Ch == 1 % first row
            title(TaskLabels{Indx_T}, 'FontSize', Pixels.LetterSize, 'Color', 'k')
        end
        
        if Indx_Ch == numel(ChLabels) % last row
            xlabel(Format.Labels.Frequency)
        else
            xlabel ''
        end
    end
end

% save
saveFig(strjoin({TitleTag, 'All', 'Sessions', 'Channels'}, '_'), Paths.Paper, Format)



%% peak frequency in the game
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
    Title = strjoin({'ThetaPeak', TaskLabels{Indx_T}, ChLabels{Ch_Indx}}, '_');
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
    Title = strjoin({'ThetaProminence', TaskLabels{Indx_T}, ChLabels{Ch_Indx}}, '_');
    saveStats(Stats, 'Paired', Paths.PaperStats, Title, StatsP)
    disp('****')
end


%%
Grid = [2 2];
YLims = [0 8];
figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.5])

% BL Prom
Data = squeeze(Prominence(:, 1, :, 1));
subfigure([], Grid, [1 1], [], Pixels.Letters{1}, Pixels);
Stats = plotConfettiSpaghetti(Data, TaskLabels, [], [0 6], Format.Colors.Participants, StatsP, Pixels);
title('BL Prominence', 'FontSize', Pixels.TitleSize)
ylim(YLims)
ylabel(Pixels.Labels.zPower)

% SD Prom
Data = squeeze(Prominence(:, 3, :, 1));
subfigure([], Grid, [1 2], [], Pixels.Letters{1}, Pixels);
Stats = plotConfettiSpaghetti(Data, TaskLabels, [], [], Format.Colors.Participants, StatsP, Pixels);
title('SD Prominence',  'FontSize', Pixels.TitleSize)
ylim(YLims)

% BL Peaks
Data = squeeze(Peaks(:, 1, :, 1));
subfigure([], Grid, [2 1], [], Pixels.Letters{3}, Pixels);
Stats = plotConfettiSpaghetti(Data, TaskLabels, [], [], Format.Colors.Participants, StatsP, Pixels);
title('BL Peaks', 'FontSize', Pixels.TitleSize)
ylim([2 11])
ylabel(Pixels.Labels.Frequency)

% SD Peaks
Data = squeeze(Peaks(:, 2, :, 1));
subfigure([], Grid, [2 2], [], Pixels.Letters{3}, Pixels);
Stats = plotConfettiSpaghetti(Data, TaskLabels, [], [], Format.Colors.Participants, StatsP, Pixels);
title('SD Peaks', 'FontSize', Pixels.TitleSize)
ylim([2 11])
ylabel(Pixels.Labels.Frequency)


% save
saveFig('TaskPeaks', Paths.Paper, Format)

%%
figure('units','centimeters','position',[0 0 Pixels.W*.6 Pixels.H*.4])
Pixels.xPadding = 40;
% plot change in prominence for all data
Data = squeeze(Prominence(:, :, :, 1));
subfigure([], [1 2], [1 1], [], Pixels.Letters{1}, Pixels);
plotSpaghettiOs(Data, 1, Sessions.Labels, TaskLabels, Format.Colors.AllTasks, StatsP, Format)
ylabel(Pixels.Labels.zPower)
ylim([0 4])
title('Prominence')

Data = squeeze(Peaks(:, :, :, 1));
subfigure([], [1 2], [1 2], [], Pixels.Letters{2}, Pixels);
plotSpaghettiOs(Data, 1, Sessions.Labels, TaskLabels, Format.Colors.AllTasks, StatsP, Format)
legend off
ylabel(Pixels.Labels.Frequency)
ylim([4 8])
title('Frequency')

% save
saveFig('TaskPeaks', Paths.Results, Format)

%%

Pixels.xPadding = 25;
%% Overlap of all participants' spectrums for subset of tasks, with raw data for reference TODO: remove

Log = true;
Indx_Ch = 1;
Tasks = {'Game', 'PVT'};
S = [1 3];
YLim = [0 60];
Grid = [3 2];

Pixels.xPadding = 20;
Pixels.yPadding = 50; % larger distance than default because no labels

TaskIndx = [5 2];

figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.75])

% plot raw data
LetterIndx = 1;
for Indx_S = 1:numel(S)
    
    Data = squeeze(chDataRaw(:, S(Indx_S), TaskIndx(1), Indx_Ch, :));
    
    subfigure([], Grid, [1, Indx_S], [], Pixels.Letters{LetterIndx}, Pixels);
    LetterIndx = LetterIndx+1;
    plotSpectrum(Data, Freqs, Participants, Format.Colors.Participants, ...
        Format.Alpha.Participants, Pixels.LW, Log, Pixels)
    ylabel(Format.Labels.Power)
    legend off
    set(gca, 'FontSize', Pixels.FontSize, 'YLim', YLim)
    title(strjoin({Tasks{1}, Sessions.Labels{S(Indx_S)}, ChLabels{Indx_Ch}}, ' '), ...
        'FontSize', Pixels.TitleSize)
end

YLim = [-1.5 5.5];

%
% plot z-scored data
for Indx_T = 1:numel(Tasks)
    for Indx_S = 1:numel(S)
        
        Data = squeeze(chData(:, Indx_S,  TaskIndx(Indx_T), Indx_Ch, :));
        
        subfigure([], Grid, [1+Indx_T, Indx_S], [], Pixels.Letters{LetterIndx}, Pixels);
        LetterIndx = LetterIndx+1;
        plotSpectrum(Data, Freqs, Participants, Format.Colors.Participants, ...
            Format.Alpha.Participants, Pixels.LW, Log, Pixels)
        legend off
        set(gca, 'FontSize', Pixels.FontSize, 'YLim', YLim)
        title(strjoin({Tasks{Indx_T}, Sessions.Labels{S(Indx_S)}, ChLabels{Indx_Ch}}, ' '), ...
            'FontSize', Pixels.TitleSize)
        
    end
end

saveFig(strjoin({TitleTag, 'Participants'}, '_'), Paths.Paper, Format)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% WARNING: all scripts after this are a mess, and were not used for the
% paper, just trying things out.

%% Plot map of clusters

PlotChannelMap(Chanlocs, ChannelStruct, getColors(3), Format)
saveFig(strjoin({TitleTag, 'Channel', 'Map'}, '_'), Results, Format)


%% Plot spectrums as task x ch coloring all channels
Format.Labels.Bands = [1 4 8 12 35];

Log = true;
figure('units','normalized','outerposition',[0 0 .8 1])
tiledlayout( numel(ChLabels),numel(AllTasks), 'Padding', 'compact', 'TileSpacing', 'normal');
for Indx_Ch = 1:numel(ChLabels)
    for Indx_T = 1:numel(AllTasks)
        Data = squeeze(chData(:, :, Indx_T, Indx_Ch, :));
        
        nexttile
        plotSpectrumDiff(Data, Freqs, 1, Sessions.Labels, flip(Format.Colors.Sessions(:, :, Indx_T)), Log, Format, StatsP);
        set(gca, 'FontSize', 14)
        if Indx_Ch > 1 || Indx_T > 1
            legend off
        end
        if Indx_T ==1
            ylabel(Format.Labels.zPower)
        else
            ylabel ''
        end
        if Indx_Ch == numel(ChLabels)
            xlabel(Format.Labels.Frequency)
        else
            xlabel ''
        end
        title(strjoin({ChLabels{Indx_Ch}, TaskLabels{Indx_T}}, ' '), 'FontSize', Format.Pixels.FontSize, 'Color', 'k')
        
    end
end
setLimsTiles(numel(ChLabels)*numel(AllTasks), 'y');

% save
saveFig(strjoin({TitleTag, 'All', 'Sessions', 'Channels'}, '_'), Results, Format)

%% plot all tasks, split by session, one fig for each ch


for Indx_Ch =  1:numel(ChLabels)
    figure('units','normalized','outerposition',[0 0 .8 .5])
    tiledlayout(1,numel(Sessions.Labels), 'Padding', 'compact', 'TileSpacing', 'normal');
    
    for Indx_S = 1:numel(Sessions.Labels)
        Data = squeeze(chData(:, Indx_S, :, Indx_Ch, :));
        
        nexttile
        plotSpectrumDiff(Data, Freqs, numel(TaskLabels), TaskLabels, Format.Colors.AllTasks, Log, Format, StatsP);
        legend off
        title(strjoin({ChLabels{Indx_Ch}, Sessions.Labels{Indx_S}}, ' '))
    end
    setLimsTiles(numel(Sessions.Labels), 'y');
    saveFig(strjoin({TitleTag, 'Channel', 'Tasks', ChLabels{Indx_Ch}}, '_'), Results, Format)
    
end

%% plot difference spectrums, one per channel
figure('units','normalized','outerposition',[0 0 1 .6])
Indx = 1;
for Indx_S = 2:3
    for Indx_Ch = 1:numel(ChLabels)
        SD = squeeze(chData(:, Indx_S, :, Indx_Ch, :));
        BL =  squeeze(chData(:, 1, :, Indx_Ch, :));
        Data = SD - BL;
        
        subplot(2, numel(ChLabels), Indx)
        plotSpectrumDiff(Data, Freqs, numel(TaskLabels), TaskLabels,Format.Colors.AllTasks, Log, Format, StatsP);
        title(strjoin({ChLabels{Indx_Ch}, Sessions.Labels{Indx_S}}, ' '))
        legend off
        
        Indx = Indx+1;
    end
end
setLims(2,  numel(ChLabels), 'y');
saveFig(strjoin({TitleTag, 'DiffSpectrums'}, '_'), Results, Format)



%% for each task, get peak frequency for every session, and every change with SD for ALL channels

disp('Gathering peaks, this is slow')

Peaks = nan(numel(Participants), numel(Sessions.Labels), numel(AllTasks), numel(Chanlocs));
DiffPeaks = Peaks;
BL_Task = strcmp(AllTasks, 'Music');

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions.Labels)
        
        for Indx_T = 1:numel(AllTasks)
            Data = squeeze(zData(Indx_P, Indx_S, Indx_T, :, :));
            [Peaks(Indx_P, Indx_S, Indx_T, :), ~] = findPeaks(Data, PeakRange, Freqs, false);
            
            if Indx_S == 1 % if session 1, use baseline Rest
                BL = squeeze(zData(Indx_P, Indx_S, BL_Task, :, :));
            else % otherwise, compare to task baseline
                BL = squeeze(zData(Indx_P, 1, Indx_T, :, :));
            end
            
            DiffPeaks(Indx_P, Indx_S, Indx_T, :) = findPeaks(Data-BL, PeakRange, Freqs, false);
        end
    end
end

clc

%% plot mean peak frequencies for each ch and each task/session

BubbleSize = 50;
PeakPlotRange = [4 13];
Colormap = reduxColormap(Format.Colormap.Rainbow, numel(PeakPlotRange(1)+1:PeakPlotRange(2)));

for Indx_T = 1:numel(AllTasks)
    figure('units','normalized','outerposition',[0 0 .5 .5])
    for Indx_S = 1:numel(Sessions.Labels)
        
        Data = squeeze(nanmean(Peaks(:, Indx_S, Indx_T, :), 1));
        
        subplot(2, numel(Sessions.Labels), Indx_S)
        bubbleTopo(Data, Chanlocs, BubbleSize, '2D', [], Format)
        caxis(PeakPlotRange)
        colormap(Colormap)
        title(strjoin({Sessions.Labels{Indx_S}, TaskLabels{Indx_T}}, ' '))
        
        Data = squeeze(nanmean(DiffPeaks(:, Indx_S, Indx_T, :), 1));
        subplot(2, numel(Sessions.Labels), numel(Sessions.Labels)+Indx_S)
        bubbleTopo(Data, Chanlocs, BubbleSize, '2D', [], Format)
        caxis(PeakPlotRange)
        colormap(Colormap)
        if Indx_S == 1
            title(strjoin({Sessions.Labels{Indx_S},  TaskLabels{Indx_T}, 'vs Rest'}, ' '), 'FontSize', Format.TitleSize)
        else
            title(strjoin({Sessions.Labels{Indx_S},  TaskLabels{Indx_T}, 'vs BL'}, ' '), 'FontSize', Format.TitleSize)
        end
    end
    
    saveFig(strjoin({TitleTag, 'PeakFreqTopo', AllTasks{Indx_T}}, '_'), Results, Format)
end




%% for each task, get peak frequency for every session, and every change with SD for ALL channels

chPeaks = nan(numel(Participants), numel(Sessions.Labels), numel(AllTasks), numel(ChLabels));
DiffchPeaks = chPeaks;

BL_Task = strcmp(AllTasks, 'Music');

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions.Labels)
        
        for Indx_T = 1:numel(AllTasks)
            Data = squeeze(chData(Indx_P, Indx_S, Indx_T, :, :));
            [chPeaks(Indx_P, Indx_S, Indx_T, :), ~] = findPeaks(Data, PeakRange, Freqs, false);
            
            if Indx_S == 1 % if session 1, use baseline Rest
                BL =  squeeze(chData(Indx_P, Indx_S, BL_Task, :, :));
            else % otherwise, compare to task baseline
                BL = squeeze(chData(Indx_P, 1, Indx_T, :, :));
            end
            
            DiffchPeaks(Indx_P, Indx_S, Indx_T, :) = findPeaks(Data-BL, PeakRange, Freqs, false);
        end
    end
end

%%

%%% Do the same as above for raw data


chPeaksRAW = nan(numel(Participants), numel(Sessions.Labels), numel(AllTasks), numel(ChLabels));
DiffchPeaksRAW = chPeaksRAW;

BL_Task = find(strcmp(AllTasks, 'Music'));

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions.Labels)
        
        for Indx_T = 1:numel(AllTasks)
            Data = squeeze(chDataRaw(Indx_P, Indx_S, Indx_T, :, :));
            [chPeaksRAW(Indx_P, Indx_S, Indx_T, :), ~] = findPeaks(Data, PeakRange, Freqs, false);
            
            if Indx_S == 1 % if session 1, use baseline Rest
                BL =  squeeze(chDataRaw(Indx_P, Indx_S, BL_Task, :, :));
            else % otherwise, compare to task baseline
                BL = squeeze(chDataRaw(Indx_P, 1, Indx_T, :, :));
            end
            
            DiffchPeaksRAW(Indx_P, Indx_S, Indx_T, :) = findPeaks(Data-BL, PeakRange, Freqs, false);
        end
    end
end


%% Plot theta peak pairwise compared to each channel at BL, SD2 and SD2-BL
% see if channel differences are maintained with SD

for Indx_T = 1:numel(AllTasks)
    figure('units','normalized','outerposition',[0 0 .3 1])
    
    % plot peak channel differences at baseline
    subplot(3, 1, 1)
    Data = squeeze(chPeaks(:, 1, Indx_T, :));
    Stats = plotConfettiSpaghetti(Data, ChLabels, PeakRange(1):3:PeakRange(2), PeakRange,...
        Format.Colors.Participants, StatsP, Format);
    ylabel('Peak Frequency (Hz)')
    title(strjoin({'BL', TaskLabels{Indx_T}}, ' '))
    
    % plot peak channel differences at SD2
    subplot(3, 1, 2)
    Data = squeeze(chPeaks(:, 3, Indx_T, :));
    Stats = plotConfettiSpaghetti(Data, ChLabels, PeakRange(1):3:PeakRange(2), PeakRange,...
        Format.Colors.Participants, StatsP, Format);
    ylabel('Peak Frequency (Hz)')
    title(strjoin({'SD', TaskLabels{Indx_T}}, ' '))
    
    % plot peak channel differences SD2-BL
    subplot(3, 1, 3)
    Data = squeeze(DiffchPeaks(:, 3, Indx_T, :));
    Stats = plotConfettiSpaghetti(Data, ChLabels, PeakRange(1):3:PeakRange(2), PeakRange,...
        Format.Colors.Participants, StatsP, Format);
    ylabel('Peak Frequency (Hz)')
    title(strjoin({'SD-BL', TaskLabels{Indx_T}}, ' '))
    
    
    saveFig(strjoin({TitleTag, 'PeakFreq', 'Channel', AllTasks{Indx_T}}, '_'), Results, Format)
end


%% plot theta for each channel compared to each session and session change (BL, SD2, SD2-BL)
% see if the theta that changes is the same as what was there before


for Indx_Ch = 1:numel(ChLabels)
    figure('units','normalized','outerposition',[0 0 1 .4])
    for Indx_T = 1:numel(AllTasks)
        
        subplot(1, numel(AllTasks), Indx_T)
        Data = cat(2, squeeze(chPeaks(:, [1 3], Indx_T, Indx_Ch)),  squeeze(DiffchPeaks(:, 3, Indx_T, Indx_Ch)));
        Stats = plotConfettiSpaghetti(Data, {'BL', 'SD', 'SD-BL'}, PeakRange(1):3:PeakRange(2), PeakRange,...
            Format.Colors.Participants, StatsP, Format);
        ylabel('Peak Frequency (Hz)')
        title(strjoin({TaskLabels{Indx_T}, ChLabels{Indx_Ch}}, ' '))
    end
    setLims(1,  numel(AllTasks), 'y');
    saveFig(strjoin({TitleTag, 'PeakFreq', 'Session', ChLabels{Indx_Ch}}, '_'), Results, Format)
end



%% plot task theta at BL, SD2 and SD2-BL
% see if SD theta is the same for different tasks


for Indx_Ch = 1:numel(ChLabels)
    figure('units','normalized','outerposition',[0 0 .3 1])
    
    % plot peak channel differences at baseline
    subplot(3, 1, 1)
    Data = squeeze(chPeaks(:, 1, :, Indx_Ch));
    Stats = plotConfettiSpaghetti(Data, TaskLabels, PeakRange(1):3:PeakRange(2), PeakRange,...
        Format.Colors.Participants, StatsP, Format);
    ylabel('Peak Frequency (Hz)')
    title(strjoin({'BL', ChLabels{Indx_Ch}}, ' '))
    
    % plot peak channel differences at SD2
    subplot(3, 1, 2)
    Data = squeeze(chPeaks(:, 3, :, Indx_Ch));
    Stats = plotConfettiSpaghetti(Data, TaskLabels, PeakRange(1):3:PeakRange(2), PeakRange,...
        Format.Colors.Participants, StatsP, Format);
    ylabel('Peak Frequency (Hz)')
    title(strjoin({'SD', ChLabels{Indx_Ch}}, ' '))
    
    
    % plot peak channel differences SD2-BL
    subplot(3, 1, 3)
    Data = squeeze(DiffchPeaks(:, 3, :, Indx_Ch));
    Stats = plotConfettiSpaghetti(Data, TaskLabels, PeakRange(1):3:PeakRange(2), PeakRange,...
        Format.Colors.Participants, StatsP, Format);
    ylabel('Peak Frequency (Hz)')
    title(strjoin({'SD-BL', ChLabels{Indx_Ch}}, ' '))
    
    
    saveFig(strjoin({TitleTag, 'PeakFreq', 'Tasks', ChLabels{Indx_Ch}}, '_'), Results, Format)
end



%% plot corr matrix of t-values
% BL (Ch [Tasks]) SD (Ch [Tasks]) SD-BL (Ch [Tasks])

BL = squeeze(chPeaks(:, 1, :, :));
BL = reshape(BL, numel(Participants), []);

SD = squeeze(chPeaks(:, 3, :, :));
SD = reshape(SD, numel(Participants), []);

BLSD = squeeze(DiffchPeaks(:, 3, :, :));
BLSD = reshape(BLSD, numel(Participants), []);

Data = cat(2, BL, SD, BLSD);

Stats = Pairwise(Data);

Labels = {};
for Indx_Ch = 1:numel(ChLabels)
    for Indx_T = 1:numel(AllTasks)
        Labels = cat(1, Labels, strjoin({ChLabels{Indx_Ch}, TaskLabels{Indx_T}}, ' '));
    end
end

figure('units','normalized','outerposition',[0 0 1 1])
T = Stats.t;
T = triu(T) + triu(T)'; % fills in lower half of matrix, for symmetry
T(1:size(T, 1)+1:numel(T)) = 0; % set diagonal values to 0;

PlotCorrMatrix_AllSessions(T, repmat(Labels, 3, 1), {'BL', 'SD', 'SD-BL'},  ...
    numel(Labels), Format)
title('tValues of peak differences by channel, session and task')
colorbar
colormap(Format.Colormap.Divergent)
caxis([-15 15])
saveFig(strjoin({TitleTag, 'PeakFreq', 'All'}, '_'), Results, Format)



%% plot all participants' spectrums session x task, one fig per ch


Log = true;


for Indx_Ch =  1:numel(ChLabels)
    for Indx_T = 1:numel(AllTasks)
        figure('units','normalized','outerposition',[0 0 .24 1])
        for Indx_S = 1:numel(Sessions.Labels)
            
            Data = squeeze(chData(:, Indx_S, Indx_T, Indx_Ch, :));
            
            subplot(numel(Sessions.Labels), 1, Indx_S)
            % TODO: plot peaks! so can inspect where peak came from
            plotSpectrum(Data, Freqs, Participants, Format.Colors.Participants, ...
                Format.Alpha.Participants, Format.LW, Log, Format)
            legend off
            title(strjoin({TaskLabels{Indx_T}, Sessions.Labels{Indx_S}, ChLabels{Indx_Ch}}, ' '))
        end
        setLims(numel(Sessions.Labels), 1, 'y');
        
        saveFig(strjoin({TitleTag, 'Channel', 'AllP', ChLabels{Indx_Ch}, AllTasks{Indx_T}}, '_'), Results, Format)
        pause(.5)
        close
    end
end

%% plot all participants' spectrums session x task, one fig per ch NOT Z SCORED

Log = true;

for Indx_Ch =  1:numel(ChLabels)
    for Indx_T = 1:numel(AllTasks)
        figure('units','normalized','outerposition',[0 0 .24 1])
        for Indx_S = 1:numel(Sessions.Labels)
            
            Data = squeeze(chDataRaw(:, Indx_S, Indx_T, Indx_Ch, :));
            
            subplot(numel(Sessions.Labels), 1, Indx_S)
            plotSpectrum(Data, Freqs, Participants, Format.Colors.Participants, ...
                Format.Alpha.Participants, Format.LW, Log, Format)
            title(strjoin({TaskLabels{Indx_T}, Sessions.Labels{Indx_S}, ChLabels{Indx_Ch}}, ' '), 'FontSize', Format.TitleSize)
            legend off
            ylabel(Format.Labels.Power)
        end
        setLims(numel(Sessions.Labels), 1, 'y');
        
        saveFig(strjoin({TitleTag, 'Channel', 'AllP', 'RAW', ChLabels{Indx_Ch}, AllTasks{Indx_T}}, '_'), Results, Format)
        pause(.5)
        close
    end
end




%% TODO: 1 way anova SDvBL peak freq x task (apply to plotting loop?)
% or 2 way anova with task and channel?



%% for each channel, plot scatterbox plot for every task at each session, to show amplitude magnitudes
% zscored and raw


%% plot individual difference spectrums for each task, seperate fig for each channel
% see if that super peaky theta in game is consistent or not

close all
Colors = [Format.Colors.Dark1; Format.Colors.Red;   Format.Colors.Light1; 0.67 0.67 0.67];
Alpha = 1;

for Indx_Ch = 1:numel(ChLabels)
    for Indx_T = 1:numel(TaskLabels)
        figure('units','normalized','outerposition',[0 0 1 1])
        
        tiledlayout(4, 5, 'Padding', 'none', 'TileSpacing', 'compact');
        for Indx_P = 1:numel(Participants)
            
            Spectrum = squeeze(chData(Indx_P, :, Indx_T, Indx_Ch, :));
            Diff = diff(Spectrum([1, 3], :));
            Spectrum = cat(1, Spectrum, Diff);
            
            Peaks = squeeze(chPeaks(Indx_P, :, Indx_T, Indx_Ch));
            PeaksDiff = squeeze(DiffchPeaks(Indx_P, end, Indx_T, Indx_Ch));
            Peaks = cat(1, Peaks', PeaksDiff);
            
            nexttile
            plotSpectrumPeaks(Spectrum, Peaks, Freqs, {'BL', 'SR', 'SD', 'SD-BL'}, Colors, Alpha, Format)
            title(strjoin({Participants{Indx_P}, ChLabels{Indx_Ch}, TaskLabels{Indx_T}}, ' '))
            xlim(PeakRange)
            set(gca, 'FontSize', 13)
        end
        setLimsTiles(4, 5, 'y');
        saveFig(strjoin({TitleTag, 'PeaksSpectrums', 'AllP', ChLabels{Indx_Ch}, AllTasks{Indx_T}}, '_'), Results, Format)
    end
end


close all
%% Plot individual differences in spectrum with raw data
Colors = [Format.Colors.Dark1; Format.Colors.Red;  Format.Colors.Light1; 0.67 0.67 0.67];

Alpha = 1;

for Indx_Ch = 1:numel(ChLabels)
    for Indx_T = 1:numel(TaskLabels)
        figure('units','normalized','outerposition',[0 0 1 1])
        tiledlayout(4, 5, 'Padding', 'none', 'TileSpacing', 'compact');
        for Indx_P = 1:numel(Participants)
            
            Spectrum = squeeze(chDataRaw(Indx_P, :, Indx_T, Indx_Ch, :));
            
            Peaks = squeeze(chPeaksRAW(Indx_P, :, Indx_T, Indx_Ch));
            
            nexttile
            plotSpectrumPeaks(Spectrum, Peaks, Freqs, {'BL', 'SR', 'SD'}, Colors, Alpha, Format)
            title(strjoin({Participants{Indx_P}, ChLabels{Indx_Ch}, TaskLabels{Indx_T}}, ' '), 'FontSize', Format.TitleSize)
            xlim(PeakRange)
            
            F_Indx = dsearchn(Freqs', PeakRange');
            Shown = Spectrum(:, F_Indx(1):F_Indx(2));
            ylim([min(Shown(:)) max(Shown(:))])
            padAxis('y')
            set(gca, 'FontSize', 20)
        end
        saveFig(strjoin({TitleTag, 'PeaksSpectrums', 'AllP', 'RAW', ChLabels{Indx_Ch}, AllTasks{Indx_T}}, '_'), Results, Format)
    end
end

