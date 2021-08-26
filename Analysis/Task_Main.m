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

AllTasks = {'Match2Sample', 'LAT', 'PVT', 'SpFT', 'Game', 'Music'};
TaskLabels = {'STM', 'LAT', 'PVT', 'Speech', 'Game', 'Music'};
Format.Colors.AllTasks = Format.Colors.AllTasks(1:numel(TaskLabels), :);
% 
% AllTasks = P.AllTasks;
% TaskLabels = P.TaskLabels;

Duration = 4;
WelchWindow = 8;

Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = strjoin({'Task', 'ANOVA'}, '_');

Results = fullfile(Paths.Results, 'Task_ANOVA', Tag);
if ~exist(Results, 'dir')
    mkdir(Results)
end

ChLabels = fieldnames(Channels.(ROI));
BandLabels = fieldnames(Bands);
FactorLabels = {'Session', 'Task'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(P.Paths.Data, 'EEG', ['Unlocked_' Tag]);
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


%% plot map of channels

Colors = reduxColormap(Format.Colormap.Rainbow, numel(ChLabels));
PlotChannelMap(Chanlocs, Channels.(ROI), Colors, Format)
saveFig(strjoin({TitleTag, 'Channel', 'Map'}, '_'), Results, Format)


%% run main ANOVA

Effects = 0:.5:3;

for Indx_Ch = 1:numel(ChLabels)
    for Indx_B = 1:numel(BandLabels)
        
        Data = squeeze(bData(:, :, :, Indx_Ch, Indx_B));
        
        % 2 way repeated measures anova with factors Session and Task
        Stats = anova2way(Data, FactorLabels, Sessions.Labels, TaskLabels, StatsP);
        
        % eta2 comparison for task and session to determine which has larger impact
        Title = strjoin({BandLabels{Indx_B}, ChLabels{Indx_Ch}, '2 way RANOVA Effect Sizes'}, ' ');
        
        figure('units','normalized','outerposition',[0 0 .2 .3])
        plotANOVA2way(Stats, FactorLabels, StatsP, Format)
        title(Title)
        saveFig(strjoin({TitleTag, 'eta2', BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_'), Results, Format)
        
        % if interaction, identify which task has the largest increase
        P = Stats.ranovatbl.(StatsP.ANOVA.pValue);
        Interaction = P(7);
        if Interaction < StatsP.Alpha
            
            % get hedge's g stats (because <50 participants)
            BL = Data(:, 1, :);
            BL = permute(repmat(BL, 1, 2, 1), [1 3 2]);
            
            SD = permute(Data(:, 2:3, :), [1 3 2]);
            StatsH = hedgesG(BL, SD, StatsP);
            
            figure('units','normalized','outerposition',[0 0 .2 .6])
            
            % plot effect size lines
            hold on
            for E = Effects
                plot([E, E], [.5, numel(TaskLabels)+.5], 'Color', [.9 .9 .9], 'HandleVisibility', 'off')
            end
            
            plotUFO(StatsH.hedgesg, StatsH.hedgesgCI, TaskLabels, {'SR-BL', 'SD-BL'}, ...
                Format.Colors.AllTasks, 'vertical', Format)
            title(strjoin({BandLabels{Indx_B}, ChLabels{Indx_Ch}, 'Hedges g'}, ' '))
            xlabel('Hedges g')
            saveFig(strjoin({TitleTag, 'hedgesg', BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_'), Results, Format)
        end
    end
end


%% plot raw data boxplots, showcasing task differences

% for Indx_Ch = 1:numel(ChLabels)
%     for Indx_B = 1:numel(BandLabels)
%         
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


for Indx_Ch = 1:numel(ChLabels)
    for Indx_B = 1:numel(BandLabels)
        
        %         All = bData(:, :, :, Indx_Ch, Indx_B);
        %         YLims = [min(All(:)), max(All(:))];
        %         Diff =  diff(YLims);
        %         YLims(2) =Diff*.5 + YLims(2);
        %         YLims(1) = YLims(1)-Diff*.05;
        YLims = [];
        
        figure('units','normalized','outerposition',[0 0 .6 .5])
        for Indx_S = 1:numel(Sessions.Labels)
            Data = squeeze(bData(:, Indx_S, :, Indx_Ch, Indx_B));
            
            subplot(1, numel(Sessions.Labels), Indx_S)
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

for Indx_Ch = 1:numel(ChLabels)
    for Indx_B = 1:numel(BandLabels)
        figure('units','normalized','outerposition',[0 0 .5 .5])
        
        % plot baseline tasks
        Data = squeeze(bData(:, 1, :, Indx_Ch, Indx_B));
        MEANS = nanmean(Data);
        [~, Order] = sort(MEANS, 'descend');
        
        subplot(1, 2, 1)
        Stats = plotScatterBox(Data(:, Order), TaskLabels(Order), StatsP, ...
            Format.Colors.AllTasks(Order, :), [], Format);
        ylabel('Power (z score)')
        title(strjoin({'BL Tasks', BandLabels{Indx_B}, ChLabels{Indx_Ch}}, ' '))
        set(gca, 'FontSize', 15)

        
        % plot changes with SD
        Data2 = squeeze(bData(:, 3, :, Indx_Ch, Indx_B));
        Diff = Data2-Data;
         MEANS = nanmean(Diff);
        [~, Order] = sort(MEANS, 'descend');
        
        subplot(1, 2, 2)
        Stats = plotScatterBox(Diff(:, Order), TaskLabels(Order), StatsP, ...
            Format.Colors.AllTasks(Order, :), [], Format);
        ylabel('Power Difference (z score)')
        title(strjoin({'SD-BL', BandLabels{Indx_B}, ChLabels{Indx_Ch}}, ' '))
        set(gca, 'FontSize', 15)

        
        saveFig(strjoin({TitleTag, 'scatter', 'BL vs SD change', ...
            BandLabels{Indx_B}, ChLabels{Indx_Ch}}, '_'), Results, Format)
    end
end



%% plot task averages across sessions showcasing changes with SD

Indx_BL = 1;
YLim = [-.8 1.8];

for Indx_Ch = 1:numel(ChLabels)
    for Indx_B = 1:numel(BandLabels)
        
        Data = squeeze(bData(:, :, :, Indx_Ch, Indx_B));
        
        % plot spaghetti-o plot of tasks x sessions for each ch and each band
        figure('units','normalized','outerposition',[0 0 .18 .45])
        Stats = plotSpaghettiOs(Data, Indx_BL, Sessions.Labels, TaskLabels, ...
            Format.Colors.AllTasks, StatsP, Format);
        ylim(YLim)
        ylabel('Power (z-scored)')
      
        title(strjoin({ ChLabels{Indx_Ch}, BandLabels{Indx_B}}, ' '))
       
        saveFig(strjoin({TitleTag, 'SD', 'Means', ChLabels{Indx_Ch}, BandLabels{Indx_B}}, '_'), Results, Format)
        
    end
end



