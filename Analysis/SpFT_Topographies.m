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
Pixels = P.Pixels;

Window = 2;
Task = 'SpFT';
ROI = 'preROI';
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


chData = meanChData(zData, Chanlocs, Channels.(ROI), 5);

% save it into bands
bchData = bandData(chData, Freqs, Bands, 'last');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data
BandLabels = fieldnames(Bands);
ChLabels = fieldnames(Channels.(ROI));
CLims_Diff = [-2 2];

Epochs = {'Read', 'Speak'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure
%% Speech theta changes

Pixels.PaddingExterior = 30; % reduce because of subplots
Grid = [2, 4];
Indx_B = 2; % theta
Indx = 1;
YLims = [-.3 1];

figure('units','centimeters','position',[0 0 Pixels.W*.5 Pixels.H*.3])

%%% ROI changes with epoch and SD
miniGrid = [1 3];
Space = subaxis(Grid, [1 1], [1 4], Pixels.Letters{Indx}, Pixels);
Indx= Indx+1;

for Indx_Ch = 1:numel(ChLabels)
    Data = squeeze(nanmean(bchData(:, :, :, :, Indx_Ch, Indx_B), 3));
    
    A = subfigure(Space, miniGrid, [1, Indx_Ch], [], {}, Pixels);
     shiftaxis(A, [], Pixels.PaddingLabels)
    Stats = plotSpaghettiOs(Data, 1, Sessions.Labels, Epochs, ...
        Format.Colors.spEpochs, StatsP, Pixels);
    ylim(YLims)
    yticks(-.6:.2:2)
    title(ChLabels{Indx_Ch}, 'FontName', Format.FontName, 'FontSize', Pixels.TitleSize)
    if Indx_Ch ~= 2
        legend off
    end
    if Indx_Ch == 1
        ylabel(Format.Labels.zPower)
    end
end

%%% SD effects by epoch topo
for Indx_E = 1:numel(Epochs)
    
    BL = squeeze(nanmean(bData(:, 1, :, Indx_E, :, Indx_B), 3));
    SD = squeeze(nanmean(bData(:, 3, :, Indx_E, :, Indx_B), 3));
    
    if Indx_E ==1
        Letter = Pixels.Letters{Indx};
        Indx = Indx+1;
    else
        Letter = {};
    end
    
    A = subfigure([], Grid, [2 Indx_E], [], Letter, Pixels);
    shiftaxis(A, Pixels.PaddingLabels, Pixels.PaddingLabels)
    
    plotTopoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Pixels);
    set(A.Children, 'LineWidth', 1)
    title(Epochs{Indx_E}, 'FontSize', Pixels.TitleSize)
end

% plot SD read vs speak

Read = squeeze(nanmean(bData(:, 3, :, 1, :, Indx_B), 3));
Speak = squeeze(nanmean(bData(:, 3, :, 2, :, Indx_B), 3));

A = subfigure([], Grid, [2 Indx_E+1], [], {}, Pixels);
shiftaxis(A, Pixels.PaddingLabels, Pixels.PaddingLabels)

plotTopoDiff(Read, Speak, Chanlocs, CLims_Diff, StatsP, Pixels);
set(A.Children, 'LineWidth', 1)
title('Speak vs Read SD', 'FontSize', Pixels.TitleSize)


% plot colorbar
A = subfigure([], Grid, [2 Grid(2)], [], {}, Pixels);
%      shiftaxis(A, Pixels.PaddingLabels, Pixels.PaddingLabels)
plotColorbar('Divergent', CLims_Diff, Pixels.Labels.ES, Pixels)

saveFig(strjoin({TitleTag, 'SpFT_Topographies'}, '_'), Paths.Paper, Format)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



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
