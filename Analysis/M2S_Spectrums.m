% plot spectrums of fmTheta and sdTheta
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
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
StatsP = P.StatsP;
Channels = P.Channels;

ROI = 'preROI';
Window = 2;
Task = 'Match2Sample';
Tag = ['w', num2str(Window)];

Results = fullfile(Paths.Results, 'M2S_Spectrum', Tag, ROI);
if ~exist(Results, 'dir')
    mkdir(Results)
end


TitleTag = strjoin({'M2S', Tag, 'Spectrum'}, '_');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Locked', Task, Tag);
[AllData, Freqs, Chanlocs, AllTrials] = loadM2Spower(P, Filepath);

% z-score it
zData = zScoreData(AllData, 'last');

chData = meanChData(zData, Chanlocs, Channels.(ROI), 5);

spData = splitLevelsEEG(chData, AllTrials.level);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

ChLabels = fieldnames(Channels.(ROI));
CLims_Diff = [-1.7 1.7];
[nParticipants, nSessions, nTrials, nEpochs, nCh, nFreqs] = size(AllData);

Epochs = Format.Labels.Epochs;
Levels = [1 3 6];


%% Plot map of clusters

Colors = reduxColormap(Format.Colormap.Rainbow, numel(ChLabels));
PlotChannelMap(Chanlocs,Channels.(ROI), Colors, Format)
saveFig(strjoin({TitleTag, 'Channel', 'Map'}, '_'), Results, Format)


%% plot spectrum: N1, N3 and N6 at BL, SR, and SD

for Indx_E = 1:numel(Epochs)
    
    figure('units','normalized','outerposition',[0 0 .76 1])
    tiledlayout( numel(ChLabels), numel(Sessions.Labels), 'Padding', 'none', 'TileSpacing', 'compact');
    
    for Indx_Ch = 1:numel(ChLabels)
        for Indx_S = 1:numel(Sessions.Labels)
            Data = squeeze(spData(:, Indx_S, :, Indx_E, Indx_Ch, :));
            
            nexttile
            plotSpectrumDiff(Data, Freqs, 1, [], Format.Colors.Levels, Format)
            set(gca,'FontSize', 14)
            legend off
            title(strjoin({Sessions.Labels{Indx_S}, ChLabels{Indx_Ch}, Epochs{Indx_E}}, ' '), 'FontSize', Format.TitleSize)
            
        end
    end
    legend(string(Levels))
    setLimsTiles(numel(ChLabels)*numel(Sessions.Labels), 'y');
    
    % save
    saveFig(strjoin({TitleTag, 'TrialxSession', Epochs{Indx_E}}, '_'), Results, Format)
end

%% plot sdtheta: spectrum all trials at BL, SR and SD


%% plot fmTheta: N3 vs N1 at BL, SR and SD


%% the above, but individual participants at BL




%% for every epoch, at each ch, plot N3-N1 and SD-BL