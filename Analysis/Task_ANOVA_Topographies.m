% plots topographies of the effect sizes of the main effects and
% interactions of theta at every channel, to highlight which channels are
% more affected by what.


clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

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

Duration = 4;
WelchWindow = 8;

Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = strjoin({'Task', 'ANOVA', 'Topography'}, '_');

Results = fullfile(Paths.Results, 'Task_ANOVA_Topography', Tag);
if ~exist(Results, 'dir')
    mkdir(Results)
end

BandLabels = fieldnames(Bands);
FactorLabels = {'Session', 'Task'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(P.Paths.Data, 'EEG', ['Unlocked_' Tag]);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);

% z-score it
zData = zScoreData(AllData, 'last');

% average frequencies into bands
bData = bandData(zData, Freqs, Bands, 'last');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot & analyze data

%% plot eta2 for every channel

for Indx_B = 1:numel(BandLabels)
    
    Data = squeeze(bData(:, :, :, :, Indx_B));
    
    Stats = PlotTopoANOVA2(Data, Chanlocs, FactorLabels, Sessions.Labels, TaskLabels,  BandLabels{Indx_B}, StatsP, Format);
    saveFig(strjoin({TitleTag, 'Eta2', BandLabels{Indx_B}}, '_'), Results, Format)

end


%%  plot eta2 but only using SD and SR

for Indx_B = 1:numel(BandLabels)
    
    Data = squeeze(bData(:, [2, 3], :, :, Indx_B));
    
    Stats = PlotTopoANOVA2(Data, Chanlocs, FactorLabels, Sessions.Labels, TaskLabels,  BandLabels{Indx_B}, StatsP, Format);
    saveFig(strjoin({TitleTag, 'Eta2_SD_', BandLabels{Indx_B}}, '_'), Results, Format)

end



%%  plot eta2 but only using SR and BL

for Indx_B = 1:numel(BandLabels)
    
    Data = squeeze(bData(:, [1, 2], :, :, Indx_B));
    
    Stats = PlotTopoANOVA2(Data, Chanlocs, FactorLabels, Sessions.Labels, TaskLabels,  BandLabels{Indx_B}, StatsP, Format);
    saveFig(strjoin({TitleTag, 'Eta2_SR_', BandLabels{Indx_B}}, '_'), Results, Format)

end

