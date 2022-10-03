% little script comparing theta changes before and after z-scoring, to be
% used in comparison with approach in source space

clear
clc
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

Task = 'PVT';

Paths = P.Paths;
Participants = P.Participants;
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
StatsP = P.StatsP;
Channels = P.Channels;


Duration = 4;
WelchWindow = 8;
Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = strjoin({'ChannelSpace', Task, num2str(WelchWindow)}, '_');

Results = fullfile(Paths.Results, 'ZTest', Tag);
if ~exist(Results, 'dir')
    mkdir(Results)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, {Task});

% z-score it
zData = zScoreData(AllData, 'last');

% save it into bands

bData = bandData(AllData, Freqs, Bands, 'last');
bzData = bandData(zData, Freqs, Bands, 'last');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

BandLabels = fieldnames(Bands);
BL_CLabel = 'z-score';
CLims_Diff = [-2 2];


%% z-score SD effect

figure('units','normalized','outerposition',[0 0 1 1])
tiledlayout(2,numel(BandLabels), 'Padding', 'none', 'TileSpacing', 'compact');
for Indx_S = 2:3
    for Indx_B = 1:numel(BandLabels)
        
        BL = squeeze(bzData(:, 1, :, :, Indx_B));
        
        % Sleep deprivation vs baseline
        SD = squeeze(bzData(:, Indx_S, :, :, Indx_B));
        
        nexttile
        plotTopoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Format);
        title(strjoin({BandLabels{Indx_B}, Sessions.Labels{Indx_S}}, ' '), 'FontSize', Format.FontSize)
    end
    
end
 saveFig(strjoin({ TitleTag, 'zscore'}, '_'), Results, Format)
    

%% raw SD effect

figure('units','normalized','outerposition',[0 0 1 1])
tiledlayout(2,numel(BandLabels), 'Padding', 'none', 'TileSpacing', 'compact');
for Indx_S = 2:3
    for Indx_B = 1:numel(BandLabels)
        
        BL = squeeze(bData(:, 1, :, :, Indx_B));
        
        % Sleep deprivation vs baseline
        SD = squeeze(bData(:, Indx_S, :, :, Indx_B));
        
        nexttile
        plotTopoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Format);
        title(strjoin({BandLabels{Indx_B}, Sessions.Labels{Indx_S}}, ' '), 'FontSize', Format.FontSize)
    end
    
end
 saveFig(strjoin({ TitleTag, 'raw'}, '_'), Results, Format)
