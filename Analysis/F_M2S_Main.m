% Scripts for plotting figures based on trial data of the Short Term Memory
% (STM, aka Match2Sample aka M2S task). 

clear
close all
clc


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
Pixels = P.Pixels;

SmoothFactor = 1; % in Hz, range to smooth over

Window = 2;
ROI = 'preROI';
Task = 'Match2Sample';
Tag = ['w', num2str(Window)];

TitleTag = strjoin({'M2S', Tag, 'Topos'}, '_');
BandLabels = fieldnames(Bands);
ChLabels = fieldnames(Channels.(ROI));

Main_Results = fullfile(Paths.Results, 'M2S_Topographies', Tag);
if ~exist(Main_Results, 'dir')
    for Indx_B = 1:numel(BandLabels)
        
        mkdir(fullfile(Main_Results, BandLabels{Indx_B}))
        
    end
end

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


%%
Folder = fullfile(Paths.Data, 'EEG', 'Source', 'Figure');

% source space fmTheta
load(fullfile(Folder, 'stat_M2S_lvl3_vs_lvl1.mat'), 'stat')
fmTheta_Map = interpolateSources(stat);



% source space sdTheta
load(fullfile(Folder, 'stat_M2S_BS_vs_S2_lvl1.mat'), 'stat')
sdTheta_Map = interpolateSources(stat);


%%

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

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

CLims_Diff = [-2 2];
[nParticipants, nSessions, nTrials, nEpochs, nCh, nFreqs] = size(AllData);

Epochs = Format.Labels.Epochs;
Levels = [1 3 6];
Legend = append('L', string(Levels));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure


%% fmTheta vs sdTheta

Pixels = P.Pixels;

Pixels.yPadding = 15;
Pixels.xPadding = 15;
Indx_E = 2; % retention 1 period
Indx_B = 2; % theta
CLims_Diff = [-7 7];
PlotPatch = true;
Grid  = [5 4];

Order = {'left-outside', 'right-outside',  'left-inside',  'right-inside'};

figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.5])
Indx = 1; % tally of axes

%%% fmTheta
N1 = squeeze(bData(:, 1, 1, Indx_E, :, Indx_B));
N3 = squeeze(bData(:, 1, 2, Indx_E, :, Indx_B));

Axes = subfigure([], Grid, [1 1], [], false, Pixels.Letters{Indx}, Pixels); Indx = Indx+1;
shiftaxis(Axes, [], Pixels.yPadding)
plotTopoDiff(N1, N3, Chanlocs, CLims_Diff, StatsP, Pixels);
title('fmTheta', 'FontSize', Pixels.TitleSize)

% balloon brains fmTheta
for Indx_F = 1:4
    Space = subaxis(Grid, [Indx_F+1 1], [], [], Pixels);
    Axes = subfigure(Space, [1 1], [1 1], [], false, Pixels.Numerals{Indx_F}, Pixels);
    shiftaxis(Axes, Pixels.xPadding/2, Pixels.yPadding)
    plotBalloonBrain(fmTheta_Map, Order{Indx_F}, CLims_Diff, PlotPatch, Pixels)
end


%%% sdTheta
BL = squeeze(bData(:, 1, 1, Indx_E, :, Indx_B));
SD = squeeze(bData(:, 3, 1, Indx_E, :, Indx_B));

Axes = subfigure([], Grid, [1 2], [], false, Pixels.Letters{Indx}, Pixels); Indx = Indx+1;
shiftaxis(Axes, [], Pixels.yPadding)
Stats = plotTopoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Pixels);
title('sdTheta', 'FontSize', Pixels.TitleSize)

% balloon sdTheta
for Indx_F = 1:4
    Space = subaxis(Grid, [Indx_F+1 2], [], [], Pixels);
    Axes = subfigure(Space, [1 1], [1 1], [], false, Pixels.Numerals{Indx_F}, Pixels);
    shiftaxis(Axes, Pixels.xPadding/2, Pixels.yPadding)
    plotBalloonBrain(sdTheta_Map, Order{Indx_F}, CLims_Diff, PlotPatch, Pixels)
end


% colorbar
subfigure([], Grid, [5 3], [5, 1], false, '', Pixels);
Pixels.BarSize = Pixels.FontSize;
plotColorbar('Divergent', CLims_Diff, Format.Labels.ES, Pixels)


%%% plot change based on table data

% decide which labels to show
KeepAreaLabels = {'Frontal Sup R', 'Cingulum Ant L', 'Precuneus R',  ...
    'Frontal Sup Medial L', 'Supp Motor Area L' , 'Cuneus R', 'Frontal Med Orb L',  ...
    'Hippocampus R', 'Frontal Mid Orb L', 'Frontal Mid R','Frontal Inf Tri L', ...
    'Cingulum Mid L', 'Cingulum Post R', 'Occipital Sup R'   };

Labels = Areas;
Labels(~(ismember(Areas, KeepAreaLabels))) = {''};

% colors depends on sig status
Colors = repmat([.7 .7 .7], size(t_fmTheta, 1), 1); % non significant in gray
Colors(sig_fmTheta, :) = repmat(getColors([1 1], 'rainbow', 'blue'), nnz(sig_fmTheta), 1);
Colors(sig_sdTheta, :) = repmat(getColors([1 1], 'rainbow', 'red'), nnz(sig_sdTheta), 1);
Both =  sig_sdTheta & sig_fmTheta;
Colors(Both, :) = repmat(getColors([1 1], 'rainbow', 'purple'), nnz(Both), 1);

subfigure([], [5 3], [5 3], [5, 1], false, Pixels.Letters{Indx}, Pixels);
    shiftaxis(Axes, [], Pixels.yPadding)

plotRankChange([t_fmTheta, t_sdTheta], {'fmTheta', 'sdTheta'}, Labels, Colors, ...
    { 'Both signficant','Neither significant', 'sdTheta significant'}, 'northwest', Pixels)
set(legend, 'position', [ 0.7144    0.8449    0.1317    0.0566])
ylim([-3.5 7.15])
xlim([.5 2.2])

% save
saveFig(strjoin({TitleTag, 'fmTheta_vs_sdTheta_topographies'}, '_'), Paths.Paper, Format)


%% M2S theta changes for each session

Pixels = P.Pixels;

CLims_Diff = [-7 7];
Grid = [1 5];
Indx_E = 2; % retention 1 period
Indx_B = 2; % theta

figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.35])
Indx = 1; % tally of axes

%%% fmTheta by session
miniGrid = [2 3];

Space = subaxis(Grid, [1, 1], [1 3], Pixels.Letters{Indx}, Pixels); Indx = Indx+1;

for Indx_L =  2:numel(Levels)
    
    for Indx_S = 1:nSessions
        
        N1 = squeeze(bData(:, Indx_S, 1, Indx_E, :, Indx_B));
        N3 = squeeze(bData(:, Indx_S, Indx_L, Indx_E, :, Indx_B));
        
        % plot
        A = subfigure(Space, miniGrid, [Indx_L-1 Indx_S], [], false, {}, Pixels);
        shiftaxis(A, Pixels.PaddingLabels/2, [])
        Stats = plotTopoDiff(N1, N3, Chanlocs, CLims_Diff, StatsP, Pixels);
        
        if Indx_L == 2 % only title for top row
            title(Sessions.Labels{Indx_S}, 'FontName', Format.FontName, 'FontSize', Pixels.TitleSize)
        end
        
        if Indx_S ==1 % left labels of rows
            X = get(gca, 'XLim');
            Y = get(gca, 'YLim');
            text(X(1)-diff(X)*.15, Y(1)+diff(Y)*.5, [Legend{Indx_L}; 'vs'; 'L1'], ...
                'FontSize', Pixels.TitleSize, 'FontName', Format.FontName, ...
                'FontWeight', 'Bold', 'HorizontalAlignment', 'Center');
        end
        
        % save stats
        Title = strjoin({'M2S_Topo',Sessions.Labels{Indx_S}, Legend{Indx_L}, 'vs', 'L1'}, '_');
        saveStats(Stats, 'Paired', Paths.PaperStats, Title, StatsP)
    end
end


%%% mean changes in ROIs
miniGrid = [4, 1];
YLims = [-.2; -.5; -.2];
YLims = [YLims, YLims + [1.4; .7; .7]];

Space = subaxis(Grid, [1, 4], [], Pixels.Letters{Indx}, Pixels);
Indx = Indx+1;

for Indx_Ch = 1:numel(ChLabels)
    Data = squeeze(bchData(:, :, :, Indx_E, Indx_Ch, Indx_B));
    
    if Indx_Ch==1 % make only first plot twice as long
        Height = 2;
    else
        Height = 1;
    end
    
    % plot
    A = subfigure(Space, miniGrid, [Indx_Ch+1, 1], [Height, 1], true, {}, Pixels);
    shiftaxis(A, [], Pixels.PaddingLabels/2)
    Stats = plotSpaghettiOs(Data, 1, Sessions.Labels, Legend, ...
        Format.Colors.Levels, StatsP, Pixels);
    A.TickLength = [0 0];
    ylim(YLims(Indx_Ch, :))
    yticks(-1:.2:2)
    ylabel(Format.Labels.zPower)
    
    if Indx_Ch >1
        legend off
    else
        legend(Legend)
    end
    
    if Indx_Ch ~= numel(ChLabels)
        xticklabels('')
    end
    
    title(ChLabels{Indx_Ch}, 'FontName', Format.FontName, 'FontSize', Pixels.TitleSize)
end


%%% SD vs BL by level
miniGrid = [3 1];
Pixels.Topo.Sig = 2;
Space = subaxis(Grid, [1 5], [], Pixels.Letters{Indx}, Pixels);

Space(1) = Space(1) - Pixels.xPadding;
for Indx_L =  1:numel(Levels)
    
    BL = squeeze(bData(:, 1, Indx_L, Indx_E, :, Indx_B));
    SD = squeeze(bData(:, 3, Indx_L, Indx_E, :, Indx_B));
    
    % plot
    A = subfigure(Space, miniGrid, [Indx_L 1], [], false, {}, Pixels);
    Stats = plotTopoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Pixels);
    title(Legend{Indx_L}, 'FontName', Format.FontName, 'FontSize', Pixels.TitleSize)
    
    % save stats
    Title = strjoin({Legend{Indx_L}, 'SDvsBL', 'Topo'}, '_');
    saveStats(Stats, 'Paired', Paths.PaperStats, Title, StatsP)
end

%%% plot colorbar
A = subfigure(Space, miniGrid, [3 2], [3, 1], false, {}, Pixels);
plotColorbar('Divergent', CLims_Diff, Pixels.Labels.ES, Pixels)
shiftaxis(A, Pixels.PaddingLabels, [])
colormap(reduxColormap(Format.Colormap.Divergent, Format.Steps.Divergent))


% save
saveFig(strjoin({TitleTag, 'M2S_Topographies'}, '_'), Paths.Paper, Format)




%% plot spectrum

Pixels = P.Pixels;
Pixels.PaddingExterior = 90;
Grid = [numel(ChLabels), nSessions];
YLim = [-.8 3.1];

Log = true; % whether to plot on log scale or not
figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.47])
Indx = 1; % tally of axes


for Indx_Ch = 1:numel(ChLabels)
    for Indx_S = 1:nSessions
        Data = squeeze(chData(:, Indx_S, :, Indx_E, Indx_Ch, :));
        
        % plot
        subfigure([], Grid, [Indx_Ch, Indx_S], [], true, '', Pixels); Indx = Indx+1;
        plotSpectrumDiff(Data, Freqs, 1, {'L1', 'L3', 'L6'}, Format.Colors.Levels, Log, Pixels, StatsP);
        ylim(YLim)
        xlim(log([1 40]))
        
        % plot labels/legends only in specific locations
        if Indx_Ch > 1 || Indx_S > 1 % first tile
            legend off
            
        end
        
        if Indx_S == 1 % first column
            ylabel(Format.Labels.zPower)
            X = double(get(gca, 'XLim'));
            Txt= text(X(1)-diff(X)*.25, YLim(1)+diff(YLim)*.5, ChLabels{Indx_Ch}, ...
                'FontSize', Pixels.LetterSize, 'FontName', Format.FontName, ...
                'FontWeight', 'Bold', 'Rotation', 90, 'HorizontalAlignment', 'Center'); 
        else
            ylabel ''
        end
        
        if Indx_Ch == 1 % first row
            title(Sessions.Labels{Indx_S}, 'FontSize', Pixels.LetterSize, 'Color', 'k')
        end
        
        if Indx_Ch == numel(ChLabels) % last row
            xlabel(Format.Labels.Frequency)
        else
            xlabel ''
        end
    end
end

% save
saveFig(strjoin({'M2S_Spectrums', Epochs{Indx_E}}, '_'), Paths.Paper, Format)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% plot confetti spaghetti of fmTheta vs sdTheta

yLims = [-.5 1.5];


Data = squeeze(chData(:, 1, :, 2, 1, 2));
figure('units','normalized','outerposition',[0 0 .5 .5])
subplot(1, 2, 1)
plotConfettiSpaghetti(Data, Legend, [], yLims, Format.Colors.Participants, StatsP, Format);
title('fmTheta')

Data = squeeze(chData(:, :, 1, 2, 1, 2));
subplot(1, 2, 2)
plotConfettiSpaghetti(Data, Sessions.Labels, [], yLims, Format.Colors.Participants, StatsP, Format);
title('sdTheta')




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Presentation figures

%%

Format_PPT = P.Format_PPT;
CLims_Diff = [-1.6 1.6];

Indx_E = 2;
Indx_B = 2;
figure('units','centimeters','position',[0 0 20 15])
BL = squeeze(tData(:, 1, 1, Indx_E, :, Indx_B));
SD = squeeze(tData(:, 1, 2, Indx_E, :, Indx_B));
plotTopoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Format_PPT);
h = colorbar;
ylabel(h,  Pixels.Labels.ES, 'FontName', Format_PPT.FontName, 'FontSize', Format_PPT.BarSize)
h.TickLength = 0;
caxis(CLims_Diff)

set(gca, 'FontName', Format.FontName, 'FontSize', Format_PPT.BarSize)

saveFig(strjoin({TitleTag, 'fmTheta'}, '_'), Main_Results, Format)


figure('units','centimeters','position',[0 0 20 15])
BL = squeeze(nanmean(bData(:, 1, :, Indx_E, :, Indx_B), 3));
SD = squeeze(nanmean(bData(:, 3, :, Indx_E, :, Indx_B), 3));
plotTopoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Format_PPT);
h = colorbar;
ylabel(h,  Pixels.Labels.ES, 'FontName', Format_PPT.FontName, 'FontSize', Format_PPT.BarSize)
h.TickLength = 0;
caxis(CLims_Diff)

set(gca, 'FontName', Format.FontName, 'FontSize', Format_PPT.BarSize)

saveFig(strjoin({TitleTag, 'sdTheta'}, '_'), Main_Results, Format)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% For baseline, determine if there's an ANOVA of time on task (first vs last 20%)

B_Indx = 2; % theta
Legend = append('L', string(Levels));

Results = fullfile(Main_Results, BandLabels{B_Indx});

for Indx_E = 1:nEpochs
    
    figure('units','normalized','outerposition',[0 0 1 .5])
    for Indx_S = 1:nSessions
        
        Start = squeeze(nanmean(bData(:, Indx_S, 1:50, Indx_E, :, B_Indx), 3));
        End = squeeze(nanmean(bData(:, Indx_S, end-50:end, Indx_E, :, B_Indx), 3));
        
        subplot(1, nSessions, Indx_S)
        Stats = plotTopoDiff(Start, End, Chanlocs, CLims_Diff, StatsP, Format);
        title(strjoin({Sessions.Labels{Indx_S}, Epochs{Indx_E}, 'Fatigue'}, ' '), 'FontSize', Format.TitleSize)
    end
    saveFig(strjoin({ TitleTag,BandLabels{B_Indx}, Epochs{Indx_E}}, '_'), Results, Format)
end


%% plot N3 vs N1 for every epoch

for Indx_S = 1:nSessions
    for Indx_B = 1:numel(BandLabels)
        Results = fullfile(Main_Results, BandLabels{Indx_B});
        
        
        figure('units','normalized','outerposition',[0 0 .66 .6])
        %         tiledlayout(1, nEpochs, 'Padding', 'none', 'TileSpacing', 'compact');
        Indx = 1;
        for Indx_L = 2:numel(Levels)
            for Indx_E = 1:nEpochs
                Data = squeeze(bData(:, Indx_S, :, Indx_E, :, Indx_B));
                
                N1 = averageTrials(Data, squeeze(AllTrials.level(:, Indx_S, :)) == 1);
                N3 = averageTrials(Data, squeeze(AllTrials.level(:, Indx_S, :)) == Levels(Indx_L));
                
                % nexttile
                subplot(2, nEpochs, Indx)
                plotTopoDiff(N1, N3, Chanlocs, CLims_Diff, StatsP, Format);
                title([Epochs{Indx_E}, ' L', num2str(Levels(Indx_L))], 'FontSize', Format.TitleSize)
                colorbar off
                Indx = Indx+1;
            end
        end
        saveFig(strjoin({ TitleTag, 'classic', BandLabels{Indx_B}, Sessions.Labels{Indx_S}}, '_'), Results, Format)
    end
    close all
end


figure('units','normalized','outerposition',[0 0 .25 .35])
plotColorbar('Divergent', CLims_Diff, 'hedges g', Format)
saveFig(strjoin({TitleTag, 'Diff_Colorbar'}, '_'), Main_Results, Format)


%% plot SD - BL for each level

for Indx_S = 2:nSessions
    for Indx_B = 1:numel(BandLabels)
        Results = fullfile(Main_Results, BandLabels{Indx_B});
        
        for Indx_L = 1:3
            figure('units','normalized','outerposition',[0 0 .66 .35])
            %         tiledlayout(1, nEpochs, 'Padding', 'none', 'TileSpacing', 'compact');
            
            for Indx_E = 1:nEpochs
                BL = squeeze(bData(:, 1, :, Indx_E, :, Indx_B));
                SD = squeeze(bData(:, Indx_S, :, Indx_E, :, Indx_B));
                
                L_BL = averageTrials(BL, squeeze(AllTrials.level(:, Indx_S, :)) == Levels(Indx_L));
                L_SD = averageTrials(SD, squeeze(AllTrials.level(:, Indx_S, :)) == Levels(Indx_L));
                
                %             nexttile
                subplot(1, nEpochs, Indx_E)
                plotTopoDiff(L_BL, L_SD, Chanlocs, CLims_Diff, StatsP, Format);
                title(strjoin({Epochs{Indx_E}, Sessions.Labels{Indx_S}, ['L', num2str(Levels(Indx_L))]}, ' '), 'FontSize', Format.TitleSize)
                colorbar off
                
            end
            saveFig(strjoin({ TitleTag, 'SDEffect_xLevel', BandLabels{Indx_B}, Sessions.Labels{Indx_S}, num2str(Levels(Indx_L))}, '_'), Results, Format)
        end
    end
    close all
end



%% plot for each session first block vs last block s x e

for Indx_B = 1:numel(BandLabels)
    figure('units','normalized','outerposition',[0 0 .66 .66])
    Indx = 1;
    for Indx_S = 1:nSessions
        for Indx_E = 1:nEpochs
            Start = squeeze(nanmean(bData(:, Indx_S, 1:30, Indx_E, :, Indx_B), 3));
            End = squeeze(nanmean(bData(:, Indx_S, end-30:end, Indx_E, :, Indx_B), 3));
            subplot(nSessions, nEpochs, Indx)
            Indx = Indx+1;
            
            plotTopoDiff(Start, End, Chanlocs, CLims_Diff, StatsP, Format);
            title(strjoin({Epochs{Indx_E}, Sessions.Labels{Indx_S}, BandLabels{Indx_B}}, ' '), 'FontSize', Format.TitleSize)
            
        end
    end
    saveFig(strjoin({ TitleTag, 'Duration_Effect', BandLabels{Indx_B}}, '_'), Results, Format)
    
end

%% plot SD - BL for every epoch


for Indx_B = 1:numel(BandLabels)
    Results = fullfile(Main_Results, BandLabels{Indx_B});
    
    figure('units','normalized','outerposition',[0 0 .66 .35])
    %         tiledlayout(1, nEpochs, 'Padding', 'none', 'TileSpacing', 'compact');
    
    for Indx_E = 1:nEpochs
        
        BL = squeeze(nanmean(bData(:, 1, :, Indx_E, :, Indx_B), 3));
        SD = squeeze(nanmean(bData(:, Indx_S, :, Indx_E, :, Indx_B), 3));
        
        %             nexttile
        subplot(1, nEpochs, Indx_E)
        plotTopoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Format);
        title(Epochs{Indx_E}, 'FontSize', Format.TitleSize)
        colorbar off
        
    end
    saveFig(strjoin({ TitleTag, 'SDEffect', BandLabels{Indx_B}, Sessions.Labels{Indx_S}}, '_'), Results, Format)
end
close all


%% for N3 trials, plot correct vs incorrect topos



for Indx_S = 1:nSessions
    for Indx_B = 1:numel(BandLabels)
        Results = fullfile(Main_Results, BandLabels{Indx_B});
        
        figure('units','normalized','outerposition',[0 0 .66 .7])
        Indx = 1;
        %         tiledlayout(1, nEpochs, 'Padding', 'none', 'TileSpacing', 'compact');
        for Indx_L = 1:3
            for Indx_E = 1:nEpochs
                Data = squeeze(bData(:, Indx_S, :, Indx_E, :, Indx_B));
                
                T = squeeze(AllTrials.level(:, Indx_S, :)) == Levels(Indx_L) & squeeze(AllTrials.correct(:, Indx_S, :)) == 1;
                Correct = averageTrials(Data, T);
                
                T = squeeze(AllTrials.level(:, Indx_S, :)) == Levels(Indx_L) & squeeze(AllTrials.correct(:, Indx_S, :)) == 0;
                Incorrect = averageTrials(Data, T);
                
                %             nexttile
                subplot(numel(Levels), nEpochs, Indx)
                plotTopoDiff(Correct, Incorrect, Chanlocs, CLims_Diff, StatsP, Format);
                title([Epochs{Indx_E}, ' N', num2str(Levels(Indx_L)) ], 'FontSize', Format.TitleSize)
                colorbar off
                Indx = Indx+1;
            end
            
        end
        saveFig(strjoin({ TitleTag, 'CorrectvsIncorrect', BandLabels{Indx_B}, Sessions.Labels{Indx_S}, }, '_'), Results, Format)
    end
    close all
end
