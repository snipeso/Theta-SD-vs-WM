% Scripts for plotting figures based on trial data of the Short Term Memory
% (STM, aka Match2Sample aka M2S task).

clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Sessions = P.Sessions;
StatsP = P.StatsP;
Channels = P.Channels;
Labels = P.Labels;

SmoothFactor = 1; % in Hz, range to smooth over for spectrums

Window = 2;
ROI = 'preROI';
Task = 'Match2Sample';
Tag = ['w', num2str(Window)];

TitleTag = 'D_fmTheta_vs_sdTheta';
BandLabels = fieldnames(Bands);
ChLabels = fieldnames(Channels.(ROI));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Locked', Task, Tag);
[AllData, Freqs, Chanlocs, AllTrials] = loadM2Spower(P, Filepath);

% trial data
tData = trialData(AllData, AllTrials.level);

% z-score it
zData = zScoreData(tData, 'last');

% save it into bands
bData = bandData(zData, Freqs, Bands, 'last');

% average data into ROIs
chData = meanChData(zData, Chanlocs, Channels.(ROI), 5);

% save it into bands
bchData = bandData(chData, Freqs, Bands, 'last');

% smooth ch data for plotting
chData = smoothFreqs(chData, Freqs, 'last', SmoothFactor);


%%% load source localization files

Folder = fullfile(Paths.Data, 'EEG', 'Source', 'Figure');

%%

% source space fmTheta
load(fullfile(Folder, 'stat_M2S_lvl3_vs_lvl1.mat'), 'stat')
fmTheta_Map = interpolateSources(stat);

% source space sdTheta
load(fullfile(Folder, 'stat_M2S_BS_vs_S2_lvl1.mat'), 'stat')
sdTheta_Map = interpolateSources(stat);

TablePath = fullfile(Paths.Data, 'EEG', 'Source', 'Table');
File_fmTheta = 'mtrx_M2S_levels_median.mat';
File_sdTheta = 'mtrx_M2S_BS_vs_S2_lvl1_median.mat';

% theta in L3vsL1
load(fullfile(TablePath, File_fmTheta), 'mtrx_cortex', 'cortical_areas')
fmTheta_Table = nanmean(mtrx_cortex, 4);
Data1 = squeeze(fmTheta_Table(:, 1, :));
Data2 = squeeze(fmTheta_Table (:, 2, :));
Stats = pairedttest(Data1, Data2, P.StatsP);
t_fmTheta = Stats.t;
sig_fmTheta = Stats.sig;

% theta in BL vs SD of L1
load(fullfile(TablePath, File_sdTheta), 'mtrx_cortex')
sdTheta_Table = nanmean(mtrx_cortex, 4);
Data1 = squeeze(sdTheta_Table(:, 1, :));
Data2 = squeeze(sdTheta_Table (:, 2, :));
Stats = pairedttest(Data1, Data2, P.StatsP);
t_sdTheta = Stats.t;
sig_sdTheta = Stats.sig;

Areas = cortical_areas;
Areas = replace(Areas, '_', ' ');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

[nParticipants, nSessions, nTrials, nEpochs, nCh, nFreqs] = size(AllData);

Epochs = Labels.Epochs;
Levels = [1 3 6];
Legend = append('L', string(Levels));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure


%% Figure LOCZ showing fmTheta vs sdTheta

PlotProps = P.Manuscript;
% Format.Axes.yPadding = 15;
% Format.Axes.xPadding = 20;
Indx_E = 2; % retention 1 period
Indx_B = 2; % theta
CLims_Diff = [-7 7];
PlotPatch = true;
Grid  = [1 4];
miniGrid = [5, 1];

Order = {'left-outside', 'right-outside',  'left-inside',  'right-inside'};

figure('units','centimeters','position',[0 0 PlotProps.Figure.W3 PlotProps.Figure.Height*.6])

%%% fmTheta
N1 = squeeze(bData(:, 1, 1, Indx_E, :, Indx_B));
N3 = squeeze(bData(:, 1, 2, Indx_E, :, Indx_B));

Space = subaxis(Grid, [1 1], [],  PlotProps.Indexes.Letters{1}, PlotProps);
Indx = 1; % tally of axes
Axes = subfigure(Space, miniGrid, [1 1], [], false, PlotProps.Indexes.Numerals{Indx}, PlotProps); Indx = Indx+1;
shiftaxis(Axes, [], PlotProps.Axes.yPadding)
topoDiff(N1, N3, Chanlocs, CLims_Diff, StatsP, PlotProps, Labels);
colorbar off
title('fmTheta', 'FontSize', PlotProps.Text.TitleSize)

% balloon brains fmTheta
for Indx_F = 1:4
    subfigure(Space, miniGrid, [Indx_F+1 1], [], false, PlotProps.Indexes.Numerals{Indx}, PlotProps); Indx = Indx+1;
    plotBalloonBrain(fmTheta_Map, Order{Indx_F}, CLims_Diff, PlotPatch, PlotProps)
    title ''
end


%%% sdTheta
BL = squeeze(bData(:, 1, 1, Indx_E, :, Indx_B));
SD = squeeze(bData(:, 3, 1, Indx_E, :, Indx_B));

Space = subaxis(Grid, [1 2], [],  PlotProps.Indexes.Letters{2}, PlotProps);
Indx = 1; % tally of axes
Axes = subfigure(Space, miniGrid, [1 1], [], false, PlotProps.Indexes.Numerals{Indx}, PlotProps); Indx = Indx+1;
shiftaxis(Axes, [], PlotProps.Axes.yPadding)
Stats = topoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, PlotProps, Labels);
colorbar off
title('sdTheta', 'FontSize', PlotProps.Text.TitleSize)

% balloon sdTheta
for Indx_F = 1:4
    Axes = subfigure(Space, miniGrid, [Indx_F+1 1], [], false, PlotProps.Indexes.Numerals{Indx}, PlotProps); Indx = Indx+1;
    plotBalloonBrain(sdTheta_Map, Order{Indx_F}, CLims_Diff, PlotPatch, PlotProps)
    title ''
end

% colorbar
subfigure([], Grid, [1 3], [], false, '', PlotProps);
plotColorbar('Divergent', CLims_Diff, Labels.t, PlotProps)
Pos = get(gca, 'Position');
Pos(1) = Pos(1)-Pos(1)*.05;
set(gca, 'position', Pos)

%%% plot change based on table data

% decide which labels to show
KeepAreaLabels = {'Frontal Sup R', 'Cingulum Ant L', 'Precuneus R',  ...
    'Frontal Sup Medial L', 'Supp Motor Area L' , 'Cuneus R', 'Frontal Med Orb L',  ...
    'Hippocampus R', 'Frontal Mid Orb L', 'Frontal Mid R','Frontal Inf Tri L', ...
    'Cingulum Mid L', 'Cingulum Post R', 'Occipital Sup R'   };

AreaLabels = Areas;
AreaLabels(~(ismember(Areas, KeepAreaLabels))) = {''};

% colors depends on sig status
Colors = repmat([.7 .7 .7], size(t_fmTheta, 1), 1); % non significant in gray
Colors(sig_fmTheta, :) = repmat(getColors([1 1], 'rainbow', 'blue'), nnz(sig_fmTheta), 1);
Colors(sig_sdTheta, :) = repmat(getColors([1 1], 'rainbow', 'red'), nnz(sig_sdTheta), 1);
Both =  sig_sdTheta & sig_fmTheta;
Colors(Both, :) = repmat(getColors([1 1], 'rainbow', 'purple'), nnz(Both), 1);

subfigure([], [5 3], [5 3], [5, 1], false, PlotProps.Indexes.Letters{3}, PlotProps);
plotLadder([t_fmTheta, t_sdTheta], {'fmTheta', 'sdTheta'}, AreaLabels, Colors, ...
    {'Neither significant',  'Both signficant', 'sdTheta significant'}, 'northwest', PlotProps)
set(legend, 'position', [0.6302    0.8123    0.2219    0.0865])
ylim([-3.5 7.25])
xlim([.65 2.2])
Pos = get(gca, 'position');
Pos(1) = Pos(1)+Pos(1)*.05;
set(gca, 'position', Pos)

% save
saveFig(strjoin({TitleTag, 'sources'}, '_'), Paths.Paper, PlotProps)


%% Figure M2SZ theta changes for each session

PlotProps = P.Manuscript;

CLims_Diff = [-7 7];
Grid = [1 5];
Indx_E = 2; % retention 1 period
Indx_B = 2; % theta

figure('units','centimeters','position',[0 0 PlotProps.Figure.Width PlotProps.Figure.Height*.4])
Indx = 1; % tally of axes

%%% fmTheta by session
miniGrid = [2 3];

Space = subaxis(Grid, [1, 1], [1 3], PlotProps.Indexes.Letters{Indx}, PlotProps); Indx = Indx+1;

for Indx_L =  2:numel(Levels)
    for Indx_S = 1:nSessions
        
        N1 = squeeze(bData(:, Indx_S, 1, Indx_E, :, Indx_B));
        N3 = squeeze(bData(:, Indx_S, Indx_L, Indx_E, :, Indx_B));
        
        % plot
        A = subfigure(Space, miniGrid, [Indx_L-1 Indx_S], [], false, {}, PlotProps);
        shiftaxis(A, PlotProps.Axes.xPadding/2, [])
        Stats = topoDiff(N1, N3, Chanlocs, CLims_Diff, StatsP, PlotProps, Labels);
        colorbar off
        
        if Indx_L == 2 % only title for top row
            title(Sessions.Labels{Indx_S}, 'FontName', PlotProps.Text.FontName, 'FontSize', PlotProps.Text.TitleSize)
        end
        
        if Indx_S ==1 % left labels of rows
            X = get(gca, 'XLim');
            Y = get(gca, 'YLim');
            text(X(1)-diff(X)*.15, Y(1)+diff(Y)*.5, [Legend{Indx_L}; 'vs'; 'L1'], ...
                'FontSize', PlotProps.Text.TitleSize, 'FontName', PlotProps.Text.FontName, ...
                'FontWeight', 'Bold', 'HorizontalAlignment', 'Center');
        end
        
        % save stats
        Title = strjoin({TitleTag, Sessions.Labels{Indx_S}, Legend{Indx_L}, 'vs', 'L1'}, '_');
        saveStats(Stats, 'Paired', Paths.PaperStats, Title, StatsP)
    end
end


%%% mean changes in ROIs
miniGrid = [4, 1];
YLims = [-.2; -.5; -.2];
YLims = [YLims, YLims + [1.8; .8; .8]];

Space = subaxis(Grid, [1, 4], [], PlotProps.Indexes.Letters{Indx}, PlotProps);
Indx = Indx+1;

for Indx_Ch = 1:numel(ChLabels)
    Data = squeeze(bchData(:, :, :, Indx_E, Indx_Ch, Indx_B));
    
    if Indx_Ch==1 % make only first plot twice as long
        Height = 2;
    else
        Height = 1;
    end
    
    if Indx_Ch >1
        L = '';
    else
        L = Legend;
    end
    
    
    % plot
    A = subfigure(Space, miniGrid, [Indx_Ch+1, 1], [Height, 1], true, {}, PlotProps);
    shiftaxis(A, [], PlotProps.Axes.yPadding/2)
    Stats = data3D(Data, 1, Sessions.Labels, L, ...
        PlotProps.Color.Levels, StatsP, PlotProps);
    A.TickLength = [0 0];
    ylim(YLims(Indx_Ch, :))
    yticks(-1:.2:2)
    ylabel(Labels.zPower)
    if Indx_Ch >1
        legend off
    end
    
    if Indx_Ch ~= numel(ChLabels)
        xticklabels('')
    end
    
    title(ChLabels{Indx_Ch}, 'FontSize', PlotProps.Text.TitleSize)
end



%%% SD vs BL by level
miniGrid = [3 1];
PlotProps.External.EEGLAB.MarkerSize = 2;
Space = subaxis(Grid, [1 5], [], PlotProps.Indexes.Letters{Indx}, PlotProps);

% Space(1) = Space(1) - Format.Axes.xPadding;
for Indx_L =  1:numel(Levels)
    
    BL = squeeze(bData(:, 1, Indx_L, Indx_E, :, Indx_B));
    SD = squeeze(bData(:, 3, Indx_L, Indx_E, :, Indx_B));
    
    % plot
    A = subfigure(Space, miniGrid, [Indx_L 1], [], false, {}, PlotProps);
    Stats = topoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, PlotProps, Labels);
    shiftaxis(A, PlotProps.Axes.xPadding, [])
    colorbar off
    title(Legend{Indx_L}, 'FontSize', PlotProps.Text.TitleSize)
    
    % save stats
    Title = strjoin({TitleTag, Legend{Indx_L}, 'SDvsBL'}, '_');
    saveStats(Stats, 'Paired', Paths.PaperStats, Title, StatsP)
end


%%% plot colorbar
Space(1) = Space(1) - PlotProps.Axes.xPadding*1.55;
A = subfigure(Space, miniGrid, [3 2], [3, 1], false, {}, PlotProps);
plotColorbar('Divergent', CLims_Diff, Labels.t, PlotProps)
shiftaxis(A, PlotProps.Axes.xPadding, [])
colormap(reduxColormap(PlotProps.Color.Maps.Divergent, PlotProps.Color.Steps.Divergent))


% save
saveFig(strjoin({TitleTag, '_sessions'}, '_'), Paths.Paper, PlotProps)



%% ANOVA for each ROI

Indx_E = 2; % retention
Indx_B = 2; % theta

FactorLabels = {'Session', 'Task'};

DispStats = {};

for Indx_Ch = 1:numel(ChLabels)
 Data = squeeze(bchData(:, :, :, Indx_E, Indx_Ch, Indx_B));
 
  % 2 way repeated measures anova with factors Session and Level
        Stats = anova2way(Data, FactorLabels, Sessions.Labels, Legend, StatsP);
        TitleStats = strjoin({TitleTag, 'rmANOVA', ChLabels{Indx_Ch}}, '_');
        saveStats(Stats, 'rmANOVA', Paths.PaperStats, TitleStats, StatsP)
         DispStats = [DispStats, Stats];
        
end

clc

for Indx_Ch = 1:numel(ChLabels)
    
    dispStat(DispStats{Indx_Ch}, [], ChLabels{Indx_Ch})
    
end


%% Suppl. Figure SUP_M2SSPEC

PlotProps = P.Manuscript;
% Format.PaddingExterior = 90;
Grid = [numel(ChLabels), nSessions];
YLim = [-.8 3.1];

Log = true; % whether to plot on log scale or not
figure('units','centimeters','position',[0 0 PlotProps.Figure.Width PlotProps.Figure.Height*.47])
Indx = 1; % tally of axes


for Indx_Ch = 1:numel(ChLabels)
    for Indx_S = 1:nSessions
        Data = squeeze(chData(:, Indx_S, :, Indx_E, Indx_Ch, :));
        
        % plot
        subfigure([], Grid, [Indx_Ch, Indx_S], [], true, '', PlotProps); Indx = Indx+1;
        spectrumDiff(Data, Freqs, 1, Legend, PlotProps.Color.Levels, Log, PlotProps, StatsP, Labels);
        ylim(YLim)
        xlim(log([1 40]))
        
        % plot labels/legends only in specific locations
        if Indx_Ch > 1 || Indx_S > 1 % first tile
            legend off
            
        end
        
        if Indx_S == 1 % first column
            ylabel(Labels.zPower)
            X = double(get(gca, 'XLim'));
            Txt= text(X(1)-diff(X)*.25, YLim(1)+diff(YLim)*.5, ChLabels{Indx_Ch}, ...
                'FontSize', PlotProps.Text.TitleSize, 'FontName', PlotProps.Text.FontName, ...
                'FontWeight', 'Bold', 'Rotation', 90, 'HorizontalAlignment', 'Center');
        else
            ylabel ''
        end
        
        if Indx_Ch == 1 % first row
            title(Sessions.Labels{Indx_S}, 'FontSize', PlotProps.Text.TitleSize, 'Color', 'k')
        end
        
        if Indx_Ch == numel(ChLabels) % last row
            xlabel(Labels.Frequency)
        else
            xlabel ''
        end
    end
end

% save
saveFig(strjoin({TitleTag, 'Spectrums', Epochs{Indx_E}}, '_'), Paths.Paper, PlotProps)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% grant figures

%%
CLims = [2 7];
Grid = [1, 2];
PlotProps = P.Manuscript;

figure('units','centimeters','position',[0 0 PlotProps.Figure.Width*.5 PlotProps.Figure.Height*.2])

% plot percent change theta
BL =  squeeze(bData(:, 1, 1, 2, :, 2));
Cond =  squeeze(bData(:, 1, 2, 2, :, 2));
Data = (Cond-BL)./BL;
Axes = subfigure([], Grid, [1 1], [], false, PlotProps.Indexes.Letters{1}, PlotProps); 
Stats = topoDiff(BL, Cond, Chanlocs, [1 5.5], StatsP, PlotProps, Labels);
colormap(reduxColormap(bone, 15))
title('Cognition Theta', 'FontSize',PlotProps.Text.TitleSize)
colorbar off


BL =  squeeze(bData(:, 1, 1, 2, :, 2));
Cond =  squeeze(bData(:, 3, 1, 2, :, 2));
Data = (Cond-BL)./BL;
Axes = subfigure([], Grid, [1 2], [], false, PlotProps.Indexes.Letters{2}, PlotProps); 
Stats = topoDiff(BL, Cond, Chanlocs, CLims, StatsP, PlotProps, Labels);
colormap(reduxColormap(bone, 15))
title('Drowsiness Theta',  'FontSize',PlotProps.Text.TitleSize)
colorbar off
saveFig('Topos', 'C:\Users\colas\Dropbox\Research\Projects\HuberSleepLab\CRC grant', PlotProps)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% powerpoint figures

%% plot grid

Grid = [2 2];
CLims_Diff = [-7 7];
PlotPatch = true;
Powerpoint = P.Powerpoint;
Powerpoint.Figure.Padding = 5;

Order = {'left-outside', 'right-outside',  'left-inside',  'right-inside'};
Locations = [1 1; 1 2; 2 1; 2 2];

figure('units','centimeters','position',[0 0 35 30])
for Indx_F = 1:4
    subfigure([], Grid, Locations(Indx_F, :), [], false, '', Powerpoint);
    plotBalloonBrain(fmTheta_Map, Order{Indx_F}, CLims_Diff, PlotPatch, Powerpoint)
    padAxis('x', .75)
end

saveFig('fmTheta_square', Paths.Powerpoint, PlotProps)


figure('units','centimeters','position',[0 0 35 30])
for Indx_F = 1:4
    subfigure([], Grid, Locations(Indx_F, :), [], false, '', Powerpoint);
    plotBalloonBrain(sdTheta_Map, Order{Indx_F}, CLims_Diff, PlotPatch, Powerpoint)
    padAxis('x', .75)
end

saveFig('sdTheta_square', Paths.Powerpoint, PlotProps)



%% plot vertical

Grid = [4 1];
CLims_Diff = [-7 7];
PlotPatch = true;
Powerpoint = P.Powerpoint;
Powerpoint.Figure.Padding = 5;
Powerpoint.Axes.yPadding = 5;
Order = {'left-outside', 'right-outside',  'left-inside',  'right-inside'};

figure('units','centimeters','position',[0 0 15 40])
for Indx_F = 1:4
    subfigure([], Grid, [Indx_F, 1], [], false, '', Powerpoint);
    plotBalloonBrain(fmTheta_Map, Order{Indx_F}, CLims_Diff, PlotPatch, Powerpoint)
end

saveFig('fmTheta_vertical', Paths.Powerpoint, PlotProps)


figure('units','centimeters','position',[0 0 15 40])
for Indx_F = 1:4
    subfigure([], Grid, [Indx_F, 1], [], false, '', Powerpoint);
    plotBalloonBrain(sdTheta_Map, Order{Indx_F}, CLims_Diff, PlotPatch, Powerpoint)
end

saveFig('sdTheta_vertical', Paths.Powerpoint, PlotProps)



%% plot horizontal

Grid = [1 4];
CLims_Diff = [-7 7];
PlotPatch = true;
Powerpoint = P.Powerpoint;
Powerpoint.Figure.Padding = 5;
Powerpoint.Axes.xPadding = 5;
Powerpoint.Axes.yPadding = 15;
Order = {'left-outside', 'right-outside',  'left-inside',  'right-inside'};

figure('units','centimeters','position',[0 0 50 10])
for Indx_F = 1:4
    subfigure([], Grid, [1, Indx_F], [], false, '', Powerpoint);
    plotBalloonBrain(fmTheta_Map, Order{Indx_F}, CLims_Diff, PlotPatch, Powerpoint)
    
end

saveFig('fmTheta_horizontal', Paths.Powerpoint, PlotProps)


figure('units','centimeters','position',[0 0 50 10])
for Indx_F = 1:4
    subfigure([], Grid, [1, Indx_F], [], false, '', Powerpoint);
    plotBalloonBrain(sdTheta_Map, Order{Indx_F}, CLims_Diff, PlotPatch, Powerpoint)
    
end

saveFig('sdTheta_horizontal', Paths.Powerpoint, PlotProps)
