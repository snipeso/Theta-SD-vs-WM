% plot patches of theta increase for special peaks

clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
Tasks = P.AllTasks;
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
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, Tasks);

% z-score it
zData = zScoreData(AllData, 'last');

% smooth spectrums
sData = smoothFreqs(zData, Freqs, 'last', SmoothFactor);

%%

Peaks = struct();
Peaks(1).Ch = [4, 6, 129, 16];% M2S
Peaks(2).Ch = [124, 6, 129, 24, 81]; % LAT
Peaks(3).Ch = [5, 6, 129]; % PVT
Peaks(4).Ch = [11, 6, 129]; % Speech
Peaks(5).Ch = [23, 6, 129, 4, 102, 51]; % Game
Peaks(6).Ch = [10, 6, 129, 33]; % Music
xLog = true;
xLims = [1 35];
yLims = [-1.5, 4.7];

figure('units','normalized','outerposition',[0 0 1 1])
for Indx_T = 1:numel(Tasks)
    subplot(2, 3, Indx_T)
    Ch = labels2indexes(Peaks(Indx_T).Ch, Chanlocs);
    
    Colors = getColors(numel(Ch));
    for Indx_Ch = 1:numel(Ch)
        Data = squeeze(nanmean(sData(:, [1, 3], Indx_T, Ch(Indx_Ch), :), 1));
        plotPatch(Data, Freqs, 'pos', Colors(Indx_Ch, :), xLog, xLims, Format)
        
    end
    ylim(yLims)
    legend(string(Peaks(Indx_T).Ch), 'Location','northwest')
    title(TaskLabels{Indx_T})
    
end


%%

ChLabels = [6 13 112];
xLims = [4 8];
Ch = labels2indexes(ChLabels, Chanlocs);
Colors = getColors(numel(Ch), 'rainbow');
% Colors = Colors([2, 3, 4, 1, 5], :);

figure('units','normalized','outerposition',[0 0 .3 1])
for Indx_Ch = 1:numel(Ch)
    Data = squeeze(nanmean(sData(:, [1, 3], 1, Ch(Indx_Ch), :), 1));
    plotPatch(Data, Freqs, 'pos', Colors(Indx_Ch, :), xLog, xLims, Format)
    
end
ylim(yLims)
legend(string(ChLabels), 'Location','northwest')
title(TaskLabels{1})



ChStruct = struct();

for Indx_Ch = 1:numel(Ch)
    ChStruct.(['ch', num2str(ChLabels(Indx_Ch))]) = ChLabels(Indx_Ch);
    
end

PlotChannelMap(Chanlocs, ChStruct, Colors, Format)



%%

ChLabels = [24, 11, 124];

Ch = labels2indexes(ChLabels, Chanlocs);
xLims = [2 10];
xLog = false;
figure('units','normalized','outerposition',[0 0 1 1])
for Indx_Ch = 1:numel(Ch)
    subplot(1, 3, Indx_Ch)
    for Indx_T = numel(Tasks):-1:1
        
        Data = squeeze(nanmean(sData(:, [1, 3], Indx_T, Ch(Indx_Ch), :), 1));
        plotPatch(Data, Freqs, 'pos', Format.Colors.AllTasks(Indx_T, :), xLog, xLims, Format)
        
    end
end
setLims(1, 3, 'y');
legend(flip(TaskLabels))
