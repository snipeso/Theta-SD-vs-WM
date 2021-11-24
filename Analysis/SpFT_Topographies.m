% Topographies during the speech task


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
StatsP = P.StatsP;
Channels = P.Channels;

Window = 2;
Task = 'SpFT';
Tag = ['w', num2str(Window)];

Results = fullfile(Paths.Results, 'SpFT_Topographies', Tag);
if ~exist(Results, 'dir')
    mkdir(Results)
end


TitleTag = strjoin({'SpFT', Tag, 'Topos'}, '_');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Locked', Task, Tag);
[AllData, Freqs, Chanlocs, AllTrials] = loadSpFTpower(P, Filepath);

% z-score it
zData = zScoreData(AllData, 'last');

% save it into bands
bData = bandData(zData, Freqs, Bands, 'last');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data
BandLabels = fieldnames(Bands);
CLims_Diff = [-2 2];

Epochs = {'Read', 'Speak'};



%% compare speech vs reading at each session

for Indx_B = 1:numel(BandLabels)
    
    figure('units','normalized','outerposition',[0 0 .4 .3])
    tiledlayout(1, numel(Sessions.Labels), 'Padding', 'none', 'TileSpacing', 'compact');
    Indx = 1;
    
    for Indx_S = 1:numel(Sessions.Labels)
        Data1 = squeeze(nanmean(bData(:, Indx_S, :, 1, :, Indx_B), 3));
        Data2 = squeeze(nanmean(bData(:, Indx_S, :, 2, :, Indx_B), 3));
        
        nexttile
        plotTopoDiff(Data1, Data2, Chanlocs, CLims_Diff, StatsP, Format);
        title([Sessions.Labels{Indx_S}, BandLabels{Indx_B}], 'FontSize', Format.TitleSize)
        colorbar off
        Indx = Indx+1;
        
        saveFig(strjoin({ TitleTag, 'SpeakvsRead', BandLabels{Indx_B}}, '_'), Results, Format)
    end
    
end


figure('units','normalized','outerposition',[0 0 .25 .35])
plotColorbar('Divergent', CLims_Diff, 'hedges g', Format)
saveFig(strjoin({TitleTag, 'Diff_Colorbar'}, '_'), Results, Format)



%% compare speech and reading at SD to baseline (see if topo is different)


for Indx_B = 1:numel(BandLabels)
    
    figure('units','normalized','outerposition',[0 0 .3 .6])
    tiledlayout(2, numel(Epochs), 'Padding', 'none', 'TileSpacing', 'compact');
    
    for Indx_S = 2:numel(Sessions.Labels)
        for Indx_E = 1:2
            Data1 = squeeze(nanmean(bData(:, 1, :, Indx_E, :, Indx_B), 3));
            Data2 = squeeze(nanmean(bData(:, Indx_S, :, Indx_E, :, Indx_B), 3));
            
            nexttile
            plotTopoDiff(Data1, Data2, Chanlocs, CLims_Diff, StatsP, Format);
            title(strjoin({Epochs{Indx_E}, Sessions.Labels{Indx_S}, BandLabels{Indx_B}}, ' '), 'FontSize', Format.TitleSize)
            colorbar off
        end
    end
    saveFig(strjoin({ TitleTag, 'SDvsBL', BandLabels{Indx_B}}, '_'), Results, Format)
end
