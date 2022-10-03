% plot last 2 minutes vs first 2 minutes


clear
clc
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;

WelchWindow = 8;
Duration = 2;

Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = strjoin({'Task', 'StartvEnd'}, '_');

Results = fullfile(Paths.Results, 'Task_Start_vs_End', Tag);
if ~exist(Results, 'dir')
    mkdir(Results)
end

ChLabels = fieldnames(Channels.(ROI));
BandLabels = fieldnames(Bands);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%

Durations = [-Duration, Duration];

AllData = nan(numel(Participants), numel(Sessions.Labels), numel(AllTasks),  numel(Durations));

for Indx_D = 1:numel(Durations)
    D = Durations(Indx_D);
    
    disp(['Gathering data for ', num2str(D)])
    
    Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(D),'m'];
    Filepath =  fullfile(P.Paths.Data, 'EEG', ['Unlocked_' Tag]);
    [Data, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);
    AllData(:, :, :, Indx_D, 1:numel(Chanlocs), 1:numel(Freqs)) = Data;
end

% z-score it
zData = zScoreData(AllData, 'last');
bData = bandData(zData, Freqs, Bands, 'last');


%% plot scales






%% for every session, and every task, topoplot last to first

CLims_Diff = [-1 1];
for Indx_B = 1:numel(BandLabels)
    figure('units','normalized','outerposition',[0 0 1 .75])
    tiledlayout(numel(Sessions.Labels), numel(AllTasks), 'Padding', 'none', 'TileSpacing', 'compact');
    
    for Indx_S = 1:numel(Sessions.Labels)
        for Indx_T = 1:numel(AllTasks)
            Data1 = squeeze(bData(:, Indx_S, Indx_T, 2, :, Indx_B));
            Data2 = squeeze(bData(:, Indx_S, Indx_T, 1, :, Indx_B));
            
            nexttile
            plotTopoDiff(Data1, Data2, Chanlocs, CLims_Diff, StatsP, Format);
            title(strjoin({TaskLabels{Indx_T}, Sessions.Labels{Indx_S}, BandLabels{Indx_B}}, ' '), 'Color', Format.Colors.AllTasks(Indx_T, :), 'FontSize', 20)
        end
    end
    saveFig(strjoin({ TitleTag, 'TopoDiff', BandLabels{Indx_B}}, '_'), Results, Format)
end

