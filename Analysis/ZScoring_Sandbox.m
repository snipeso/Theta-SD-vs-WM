% check z-scoring across all frequencies


clear
clc
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
% Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
StatsP = P.StatsP;
Channels = P.Channels;
AllTasks = P.AllTasks;
Pixels = P.Pixels;

Duration = 4;
WelchWindow = 8;
Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = strjoin({'ChannelSpace', num2str(WelchWindow)}, '_');

Results = fullfile(Paths.Results, 'ZTest', Tag);
if ~exist(Results, 'dir')
    mkdir(Results)
end

Bands = struct();
Bands.Delta = P.Bands.Delta;
Bands.Theta = P.Bands.Theta;
Bands.Beta = P.Bands.Beta;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);

AllData(:, 2, :, :, :) = []; % remove SR

% z-score it
% zData = zScoreData(AllData, 'last');



% save it into bands
bzData = bandData(AllData, Freqs, Bands, 'last');

zData = nan(size(bzData));

for Indx_P = 1:numel(Participants)
    D = bzData(Indx_P, :, :, :, :);
    MEAN = nanmean(D(:));
    STD = nanstd(D(:));
    zData(Indx_P, :, :, :, :) = (D-MEAN)./STD;
end


ChannelLabels = 'preROI';

ChannelStruct =  Channels.(ChannelLabels);
ChLabels = fieldnames(ChannelStruct);
chData = meanChData(zData, Chanlocs, ChannelStruct, 4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

BandLabels = fieldnames(Bands);
BL_CLabel = 'z-score';
CLims_Diff = [-1.5 1.5];


%% z-score SD effect

figure('units','normalized','outerposition',[0 0 1 1])
tiledlayout(numel(BandLabels), numel(AllTasks), 'Padding', 'none', 'TileSpacing', 'compact');

for Indx_B = 1:numel(BandLabels)
    for Indx_T = 1:numel(AllTasks)
        BL = squeeze(zData(:, 1, Indx_T, :, Indx_B));
        
        % Sleep deprivation vs baseline
        SD = squeeze(zData(:, 2, Indx_T, :, Indx_B));
        
        nexttile
        plotTopoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Pixels);
        title(strjoin({BandLabels{Indx_B}, AllTasks{Indx_T}}, ' '), 'FontSize', Format.FontSize)
    end
    
end
saveFig(strjoin({ TitleTag, 'zscore'}, '_'), Results, Format)


%% spectrums

Log = true;

S = {'BL', 'SD'};

for Indx_Ch = 1 % 1:numel(ChLabels)
    for Indx_T = 1:numel(AllTasks)
        figure('units','normalized','outerposition',[0 0 .24 1])
        for Indx_S = 1:size(chData, 2)
            
            Data = squeeze(chData(:, Indx_S, Indx_T, Indx_Ch, :));
            
            subplot(size(chData, 2), 1, Indx_S)
            % TODO: plot peaks! so can inspect where peak came from
            plotSpectrum(Data, Freqs, Participants, Format.Colors.Participants, ...
                Format.Alpha.Participants, Format.LW, Log, Format)
            legend off
            title(strjoin({AllTasks{Indx_T}, S{Indx_S}, ChLabels{Indx_Ch}}, ' '))
        end
        setLims(size(chData, 2), 1, 'y');
        
        saveFig(strjoin({TitleTag, 'Channel', 'AllP', ChLabels{Indx_Ch}, AllTasks{Indx_T}}, '_'), Results, Format)
    end
end
