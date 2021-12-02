% This script plots all the tasks' change from baseline

clear
close all
clc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

% P.AllTasks = {'Match2Sample', 'LAT', 'PVT' 'Game'};
% P.TaskLabels = {'STM', 'LAT', 'PVT', 'Game'};

Paths = P.Paths;
Participants = P.Participants;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
StatsP = P.StatsP;
Channels = P.Channels;

Duration = 2;
WelchWindow = 8;
Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = strjoin({'Task', 'Topos', 'Welch', num2str(WelchWindow), 'zscored'}, '_');

Results = fullfile(Paths.Results, 'Task_Topographies', Tag);
if ~exist(Results, 'dir')
    mkdir(Results)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data
Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);



% z-score it
zData = zScoreData(AllData, 'last');

% save it into bands
bData = bandData(zData, Freqs, Bands, 'last');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

BandLabels = fieldnames(Bands);
BL_CLabel = 'z-score';
CLims_Diff = [-2 2];
CLims = [-1 3];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure
%% All topographies

for Indx_B = 1:numel(BandLabels)
    
    % just baseline
    figure('units','normalized','outerposition',[0 0 1 .45])
    tiledlayout(1, numel(AllTasks), 'Padding', 'none', 'TileSpacing', 'compact');
    for Indx_T = 1:numel(AllTasks)
        BL = squeeze(bData(:, 1, Indx_T, :, Indx_B));
        
        
        nexttile
        plotTopo(nanmean(BL, 1), Chanlocs, CLims, Format.Labels.zPower, 'Linear', Format);
        
        colorbar off
        
        title({[TaskLabels{Indx_T}, ' BL']; BandLabels{Indx_B}}, 'Color', Format.Colors.AllTasks(Indx_T, :), 'FontSize', Format.TitleSize)
        
    end
    
    saveFig(strjoin({TitleTag, BandLabels{Indx_B}, 'BL'}, '_'), Results, Format.TitleSize)
    
    
    figure('units','normalized','outerposition',[0 0 1 .45])
    tiledlayout(1, numel(AllTasks), 'Padding', 'none', 'TileSpacing', 'compact');
    for Indx_T = 1:numel(AllTasks)
        BL = squeeze(bData(:, 1, Indx_T, :, Indx_B));
        
        % Sleep restriction vs baseline
        SR = squeeze(bData(:, 2, Indx_T, :, Indx_B));
        
        nexttile
        Stats = plotTopoDiff(BL, SR, Chanlocs, CLims_Diff, StatsP, Format);
        title({[TaskLabels{Indx_T}, ' SR vs BL']; BandLabels{Indx_B}}, 'Color', Format.Colors.AllTasks(Indx_T, :), 'FontSize', Format.TitleSize)
        
    end
    
    saveFig(strjoin({TitleTag,  BandLabels{Indx_B}, 'SRvBL'}, '_'), Results, Format.TitleSize)
    
    
    
    figure('units','normalized','outerposition',[0 0 1 .45])
    tiledlayout(1, numel(AllTasks), 'Padding', 'none', 'TileSpacing', 'compact');
    for Indx_T = 1:numel(AllTasks)
        BL = squeeze(bData(:, 1, Indx_T, :, Indx_B));
        
        % Sleep deprivation vs baseline
        SD = squeeze(bData(:, 3, Indx_T, :, Indx_B));
        
        nexttile
        Stats = plotTopoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Format);
        title({[TaskLabels{Indx_T}, ' SD vs BL']; BandLabels{Indx_B}}, 'Color', Format.Colors.AllTasks(Indx_T, :), 'FontSize', Format.TitleSize)
        
    end
    
    saveFig(strjoin({TitleTag, BandLabels{Indx_B}, 'SDvBL'}, '_'), Results, Format)
    
    
    % plot SD vs SR
    
        figure('units','normalized','outerposition',[0 0 1 .45])
    tiledlayout(1, numel(AllTasks), 'Padding', 'none', 'TileSpacing', 'compact');
    for Indx_T = 1:numel(AllTasks)
        SR = squeeze(bData(:, 2, Indx_T, :, Indx_B));
        
        % Sleep deprivation vs baseline
        SD = squeeze(bData(:, 3, Indx_T, :, Indx_B));
        
        nexttile
        plotTopoDiff(SR, SD, Chanlocs, CLims_Diff, StatsP, Format);
        title({[TaskLabels{Indx_T}, ' SD vs SR']; BandLabels{Indx_B}}, 'Color', Format.Colors.AllTasks(Indx_T, :), 'FontSize', Format.TitleSize)
    end
    
    saveFig(strjoin({TitleTag, BandLabels{Indx_B}, 'SDvSR'}, '_'), Results, Format)
end


figure('units','normalized','outerposition',[0 0 .25 .35])
plotColorbar('Divergent', CLims_Diff, 'hedges g', Format)
saveFig(strjoin({ TitleTag, 'Theta_Baseline_v_Rest_Colorbar'}, '_'), Results, Format)

figure('units','normalized','outerposition',[0 0 .25 .35])
plotColorbar('Linear', CLims, Format.Labels.zPower, Format)
saveFig(strjoin({ TitleTag, 'Theta_Baseline_Colorbar'}, '_'), Results, Format)


