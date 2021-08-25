% plots effect sizes for each task taking data of different durations


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
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;

Duration = 4;
WelchWindow = 8;

TitleTag = strjoin({'Task', 'ES'}, '_');

Results = fullfile(Paths.Results, 'Task_ES');
if ~exist(Results, 'dir')
    mkdir(Results)
end

ChLabels = fieldnames(Channels.(ROI));
BandLabels = fieldnames(Bands);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%

Durations = [1 2 4 6 8 10 15 20];

ES = nan(2, numel(AllTasks), numel(ChLabels), numel(BandLabels), numel(Durations));
CI = nan(2, numel(AllTasks), numel(ChLabels), numel(BandLabels), numel(Durations), 2);

for Indx_D = 1:numel(Durations)
    Duration = Durations(Indx_D);
    
    disp(['Gathering data for ', num2str(Duration)])
    
    Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
    Filepath =  fullfile(P.Paths.Data, 'EEG', ['Unlocked_' Tag]);
    [AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);
    
    % z-score it
    zData = zScoreData(AllData, 'last');
    
    % average channel data into 2 spots
    chData = meanChData(zData, Chanlocs, Channels.(ROI), 4);
    
    % average frequencies into bands
    bData = bandData(chData, Freqs, Bands, 'last');
    
    
    for Indx_B = 1:numel(BandLabels)
        Data1 = squeeze(bData(:, 1, :, :, Indx_B));
        for Indx_S = [2, 3]
            
            Data2 = squeeze(bData(:, Indx_S, :, :, Indx_B));
            
            Stats = hedgesG(Data1, Data2, StatsP);
            ES(Indx_S-1, :, :, Indx_B, Indx_D) = Stats.(StatsP.Paired.ES);
            CI(Indx_S-1, :, :, Indx_B, Indx_D, :) = Stats.([StatsP.Paired.ES, 'CI']);
        end
    end
end


%% plot effect sizes

SessionLabels = Sessions.Labels(2:3);

for Indx_B = 1:numel(BandLabels)
    for Indx_Ch = 1:numel(ChLabels)
        for Indx_S = 1:2
            figure('units','normalized','outerposition',[0 0 1 .5])
            
            Data = squeeze(ES(Indx_S, :, Indx_Ch, Indx_B, :));
            DataCI = squeeze(CI(Indx_S, :, Indx_Ch, Indx_B, :, :));
            
            plotUFO(Data, DataCI, TaskLabels, string(Durations), ...
                Format.Colors.AllTasks, 'horizontal', Format)
            title(strjoin({BandLabels{Indx_B}, ChLabels{Indx_Ch}, SessionLabels{Indx_S}, 'Hedges g'}, ' '))
            saveFig(strjoin({TitleTag, StatsP.Paired.ES, ...
                BandLabels{Indx_B}, ChLabels{Indx_Ch}, SessionLabels{Indx_S}}, '_'), Results, Format)
        end
    end
end
