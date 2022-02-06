% This script hosts the main analyses for the paper regarding the task
% comparison. % It runs a 2 way anova between task and session to determine
% if there's an interaction. If not, will plot eta-squared for T and S to
% determine which had a larger effect. If yes, will plot cohen's d for each
% task SD-BL to show which has the largest effects. Does this seperately
% for generic frontspot and generic backspot. Does this also for all bands,
% but the only one we care about is theta, so no need for pairwise
% correction.
% will plot spaghetti-o plots for tasks and SD.
% Plots the scatter+whisker plot for individuals raw and z-scored to show
% magnitude of theta.
clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

ROI = 'preROI';

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
Channels = P.Channels;
StatsP = P.StatsP;
Pixels = P.Pixels;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;


TASKTYPE = 'Main';

Format.Colors.AllTasks = Format.Colors.AllTasks(1:numel(TaskLabels), :);

ChLabels = fieldnames(Channels.(ROI));
BandLabels = fieldnames(Bands);
FactorLabels = {'Session', 'Task'};

Duration = 4;
WelchWindow = 8;

Tag = ['window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = strjoin({'Task', 'ANOVA'}, '_');
% TitleTag = strjoin({'RAW', 'Task', 'ANOVA'}, '_');

Main_Results = fullfile(Paths.Results, 'Task_ANOVA', strjoin({TASKTYPE, Tag}, '_'), ROI);
if ~exist(Main_Results, 'dir')
    for Indx_B = 1:numel(BandLabels)
        for Indx_Ch = 1:numel(ChLabels)
            mkdir(fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch}))
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);

% z-score it
zData = zScoreData(AllData, 'last');

% average channel data into 2 spots
chData = meanChData(zData, Chanlocs, Channels.(ROI), 4);

% average frequencies into bands
bData = bandData(chData, Freqs, Bands, 'last');

chRawData = meanChData(AllData, Chanlocs, Channels.(ROI), 4);
bRawData = bandData(chRawData, Freqs, Bands, 'last');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot & analyze data




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure

%% Theta changes for ROIs

Indx_B = 2; % theta
Grid = [2, 5];
YLim = [-.75 1.9];
Indx_BL = 1; % the reference for SpaghettiO plots

figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.33])
Indx = 1; % tally of axes

%%% change in means
for Indx_Ch = 1:numel(ChLabels)
    
    subfigure([], Grid, [2, Indx_Ch], [2, 1], true, Pixels.Letters{Indx}, Pixels);
    Indx = Indx+1;
    
    Data = squeeze(bData(:, :, :, Indx_Ch, Indx_B));
    
    % plot spaghetti-o plot of tasks x sessions for each ch and each band
    Stats = plotSpaghettiOs(Data, Indx_BL, Sessions.Labels, TaskLabels, ...
        Format.Colors.AllTasks, StatsP, Pixels);
    ylim(YLim)
    
    % plot labels only in specific plots
    if Indx_Ch == 1
        ylabel(Format.Labels.zPower)
        legend off
    elseif Indx_Ch ~= 2
        legend off
    end
    
    title(ChLabels{Indx_Ch}, 'FontSize', Pixels.TitleSize)
end


%%% difference at baseline
Data = squeeze(bData(:, 1, :, 1, Indx_B));
MEANS = nanmean(Data);
[~, Order] = sort(MEANS, 'descend');

subfigure([], Grid, [1, Indx_Ch+1], [1, Grid(2)-Indx_Ch], true, Pixels.Letters{Indx}, Pixels);
Indx = Indx+1;
plotScatterBox(Data(:, Order), TaskLabels(Order), StatsP, ...
    Format.Colors.AllTasks(Order, :), [], Pixels);
ylabel(Format.Labels.zPower)
title('Baseline Front Means', 'FontSize', Pixels.TitleSize)


% effect sizes
subfigure([], Grid, [2, Indx_Ch+1], [1, Grid(2)-Indx_Ch], true, Pixels.Letters{Indx}, Pixels);

Data = squeeze(bData(:, :, :, 2, Indx_B)); % for middle channels
Stats = plotES(Data, 'horizontal', true, Format.Colors.AllTasks, TaskLabels, ...
    {'SR vs BL', 'SD vs BL'}, Pixels, StatsP);

%  title('Center', 'FontSize', Pixels.TitleSize)
X = get(gca, 'XLim');
text(X(1)+diff(X)/2, YLim(2)*1.2, 'Center Effect Sizes', ...
    'FontSize', Pixels.TitleSize, 'FontName', Format.FontName, ...
    'FontWeight', 'Bold', 'HorizontalAlignment', 'Center');


% save
saveFig(strjoin({TitleTag, 'Means'}, '_'), Paths.Paper, Format)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% plot map of channels

PlotChannelMap(Chanlocs, Channels.(ROI), Format.Colors.(ROI), Format)
saveFig(strjoin({TitleTag, 'Channel', 'Map'}, '_'), Main_Results, Format)


%% run main ANOVA


for Indx_Ch = 1:numel(ChLabels)
    for Indx_B = 1:numel(BandLabels)
        
        Data = squeeze(bData(:, :, :, Indx_Ch, Indx_B));
        Results = fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch});
        
        % 2 way repeated measures anova with factors Session and Task
        Stats = anova2way(Data, FactorLabels, Sessions.Labels, TaskLabels, StatsP);
        TitleStats = strjoin({'Stats_Main', TitleTag, BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_');
        saveStats(Stats, 'rmANOVA', Results, TitleStats, StatsP)
        
        % eta2 comparison for task and session to determine which has larger impact
        Title = strjoin({BandLabels{Indx_B}, ChLabels{Indx_Ch}, 'Effects'}, ' ');
        
        figure('units','normalized','outerposition',[0 0 .2 .3])
        plotANOVA2way(Stats, FactorLabels, StatsP, Format)
        ylim([0 .7])
        title(Title, 'FontSize', 30)
        saveFig(strjoin({TitleTag, 'eta2', BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_'), Results, Format)
        
        % if interaction, identify which task has the largest increase
        P = Stats.ranovatbl.(StatsP.ANOVA.pValue);
        Interaction = P(7);
        if Interaction < StatsP.Alpha
            figure('units','normalized','outerposition',[0 0 .2 .6])
            Stats = plotES(Data, 'vertical', Format.Colors.AllTasks, TaskLabels, {'SR-BL', 'SD-BL'}, Format, StatsP);
            title(strjoin({BandLabels{Indx_B}, ChLabels{Indx_Ch}, 'Hedges g'}, ' '))
            saveFig(strjoin({TitleTag, 'hedgesg', BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_'), Results, Format)
        end
    end
end


%% plot raw data boxplots, showcasing task differences

% for Indx_Ch = 1:numel(ChLabels)
%     for Indx_B = 1:numel(BandLabels)
% Results = fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch});
%         %         All = bRawData(:, :, :, Indx_Ch, Indx_B);
%         %         YLims = [min(All(:)), max(All(:))];
%         %         Diff =  diff(YLims);
%         %         YLims(2) =Diff*.5 + YLims(2);
%         %         YLims(1) = YLims(1)-Diff*.05;
%         YLims = [];
%
%         figure('units','normalized','outerposition',[0 0 .6 .5])
%         for Indx_S = 1:numel(Sessions.Labels)
%             Data = squeeze(bRawData(:, Indx_S, :, Indx_Ch, Indx_B));
%
%             subplot(1, numel(Sessions.Labels), Indx_S)
%             Stats = plotScatterBox(Data, TaskLabels, StatsP, ...
%                 Format.Colors.AllTasks, YLims, Format);
%             ylabel('Power (miV)')
%             title(strjoin({Sessions.Labels{Indx_S}, BandLabels{Indx_B}, ChLabels{Indx_Ch}, 'Raw Data'}, ' '))
%
%         end
%
%         saveFig(strjoin({TitleTag, 'scatter', 'raw', ...
%             BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_'), Results, Format)
%     end
% end
%
%
%
%

%% plot z-scored data boxplots showcasing task differences

Format.TitleSize = 20;
Format.FontSize = 14;
Format.LW = 2.5;
Format.ScatterSize = 50;

for Indx_Ch = 1:numel(ChLabels)
    for Indx_B = 1:numel(BandLabels)
        
        %         All = bData(:, :, :, Indx_Ch, Indx_B);
        %         YLims = [min(All(:)), max(All(:))];
        %         Diff =  diff(YLims);
        %         YLims(2) =Diff*.5 + YLims(2);
        %         YLims(1) = YLims(1)-Diff*.05;
        YLims = [];
        Results = fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch});
        
        figure('units','normalized','outerposition',[0 0 1 .5])
        tiledlayout(1, 3, 'Padding', 'none', 'TileSpacing', 'compact');
        for Indx_S = 1:numel(Sessions.Labels)
            Data = squeeze(bData(:, Indx_S, :, Indx_Ch, Indx_B));
            
            %             subplot(1, numel(Sessions.Labels), Indx_S)
            nexttile
            Stats = plotScatterBox(Data, TaskLabels, StatsP, ...
                Format.Colors.AllTasks, YLims, Format);
            ylabel('Power (z score)')
            title(strjoin({Sessions.Labels{Indx_S}, BandLabels{Indx_B}, ChLabels{Indx_Ch}, 'zData'}, ' '))
            
            
        end
        
        saveFig(strjoin({TitleTag, 'scatter', 'zscore', ...
            BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_'), Results, Format)
    end
end



%% plot z data for BL tasks (sorted) next to z data for SD2-BL changes
%
% Format.TitleSize = 20;
% Format.FontSize = 14;
% Format.LW = 2.5;
% Format.ScatterSize = 50;

for Indx_Ch = 1:numel(ChLabels)
    for Indx_B = 1:numel(BandLabels)
        Results = fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch});
        
        figure('units','normalized','outerposition',[0 0 .35 .6])
        
        % plot baseline tasks
        Data = squeeze(bData(:, 1, :, Indx_Ch, Indx_B));
        MEANS = nanmean(Data);
        [~, Order] = sort(MEANS, 'descend');
        
        
        plotScatterBox(Data(:, Order), TaskLabels(Order), StatsP, ...
            Format.Colors.AllTasks(Order, :), [], Format);
        ylabel('Power (z score)')
        title(strjoin({'BL Tasks', BandLabels{Indx_B}, ChLabels{Indx_Ch}}, ' '), 'FontSize', Format.TitleSize)
        
        saveFig(strjoin({TitleTag, 'scatter', 'BL_Tasks_Pairwise', ...
            BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_'), Results, Format)
        
        Stats = Pairwise(Data, StatsP);
        TitleStats = strjoin({'Stats_Main', TitleTag, BandLabels{Indx_B}, ChLabels{Indx_Ch}, 'BL'}, '_');
        saveStats(Stats, 'Pairwise', Results, TitleStats, StatsP)
        
        
        % plot changes with SD
        Data2 = squeeze(bData(:, 3, :, Indx_Ch, Indx_B));
        Diff = Data2-Data;
        MEANS = nanmean(Diff);
        [~, Order] = sort(MEANS, 'descend');
        figure('units','normalized','outerposition',[0 0 .35 .6])
        plotScatterBox(Diff(:, Order), TaskLabels(Order), StatsP, ...
            Format.Colors.AllTasks(Order, :), [], Format);
        ylabel('Power Difference (z score)')
        title(strjoin({'SD-BL', BandLabels{Indx_B}, ChLabels{Indx_Ch}}, ' '), 'FontSize', Format.TitleSize)
        
        
        saveFig(strjoin({TitleTag, 'scatter', 'SD_Pairwise', ...
            BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_'), Results, Format)
        Stats = Pairwise(Diff, StatsP);
        TitleStats = strjoin({'Stats_Main', TitleTag, BandLabels{Indx_B}, ChLabels{Indx_Ch}, 'SD-BL'}, '_');
        saveStats(Stats, 'Pairwise', Results, TitleStats, StatsP)
    end
end



%% plot task averages across sessions showcasing changes with SD

Indx_BL = 1;
YLim = [-.8 1.8];

for Indx_Ch = 1:numel(ChLabels)
    for Indx_B = 1:numel(BandLabels)
        
        Data = squeeze(bData(:, :, :, Indx_Ch, Indx_B));
        Results = fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch});
        
        % plot spaghetti-o plot of tasks x sessions for each ch and each band
        figure('units','normalized','outerposition',[0 0 .2 .7])
        Stats = plotSpaghettiOs(Data, Indx_BL, Sessions.Labels, TaskLabels, ...
            Format.Colors.AllTasks, StatsP, Format);
        ylim(YLim)
        ylabel('Power (z-scored)')
        
        title(strjoin({ ChLabels{Indx_Ch}, BandLabels{Indx_B}}, ' '), 'FontSize', Format.TitleSize)
        legend off
        saveFig(strjoin({TitleTag, 'SD', 'Means', ChLabels{Indx_Ch}, BandLabels{Indx_B}}, '_'), Results, Format)
        
    end
end


%% plot pairwise comparison for each channel for each task

for Indx_Ch = 1:numel(ChLabels)
    for Indx_B = 1:numel(BandLabels)
        Results = fullfile(Main_Results, BandLabels{Indx_B}, ChLabels{Indx_Ch});
        
        figure('units','normalized','outerposition',[0 0 1 .5])
        for Indx_T = 1:numel(AllTasks)
            
            Data = squeeze(bData(:, :, Indx_T, Indx_Ch, Indx_B));
            
            subplot(1, numel(AllTasks), Indx_T)
            
            Stats = plotConfettiSpaghetti(Data,  Sessions.Labels, [], [], ...
                Format.Colors.Participants, StatsP, Format );
            
            ylabel('Power (z-scored)')
            
            title(strjoin({TaskLabels{Indx_T}, ChLabels{Indx_Ch}, BandLabels{Indx_B}}, ' '))
            
        end
        setLims(1, numel(AllTasks), 'y');
        saveFig(strjoin({TitleTag, 'TaskChange', ChLabels{Indx_Ch}, BandLabels{Indx_B}}, '_'), Results, Format)
        
    end
end