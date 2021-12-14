% script for plotting topoplots of the different trial epochs from the
% match2sample (short term memory) task. Compares 3 Items vs 1 and SD vs
% BL, and correct responses vs lapses


% Predictions:
% If theta is higher during incorrect answers (but only following SD) then
% this is evidence of local sleep impairing performance. If frontal theta is lower
% during incorrect answers, this is a sign that theta is a form of
% compensation and helps with performance.

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

% z-score it
zData = zScoreData(AllData, 'last');

% save it into bands
bData = bandData(zData, Freqs, Bands, 'last');

tData = trialData(bData, AllTrials.level);

% average data into ROIs
chData = meanChData(zData, Chanlocs, Channels.(ROI), 5);

% save it into bands
bchData = bandData(chData, Freqs, Bands, 'last');

% split levels
tchData = trialData(bchData, AllTrials.level);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

CLims_Diff = [-2 2];
[nParticipants, nSessions, nTrials, nEpochs, nCh, nFreqs] = size(AllData);

Epochs = Format.Labels.Epochs;
Levels = [1 3 6];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure

%% M2S theta changes

CLims_Diff = [-2 2];
Pixels.PaddingExterior = 30; % reduce because of subplots
Grid = [1 5];
Indx_E = 2; % retention 1 period
Indx_B = 2; % theta

Legend = append('L', string(Levels));

figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.35])
Indx = 1; % tally of axes


%%% mean changes in ROIs
miniGrid = [4, 1];
YLims = [-.075; -.21; -.05];
YLims = [YLims, YLims + [.8; .3; .3]];

Space = subaxis(Grid, [1, 1], [], Pixels.Letters{Indx}, Pixels);
Indx = Indx+1;

for Indx_Ch = 1:numel(ChLabels)
    Data = squeeze(tchData(:, :, :, Indx_E, Indx_Ch, Indx_B));
    
    if Indx_Ch==1 % make only first plot twice as long
        Height = 2;
    else
        Height = 1;
    end
    
    A = subfigure(Space, miniGrid, [Indx_Ch+1, 1], [Height, 1], {}, Pixels);
    shiftaxis(A, [], Pixels.PaddingLabels/2)
    A.TickLength = [0 0];

    Stats = plotSpaghettiOs(Data, 1, Sessions.Labels, Legend, ...
        flip(Format.Colors.Levels), StatsP, Pixels);
    ylim(YLims(Indx_Ch, :))
    yticks(-.4:.1:1)
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


%%% N3 vs N2 by session
miniGrid = [2 3];

Axis = subfigure([], Grid, [1, 2], [1, 3], Pixels.Letters{Indx}, Pixels);
Indx = Indx+1;
Axis.Units = 'pixels';
Space = Axis.Position;
axis off

for Indx_L =  2:numel(Levels)
    
    for Indx_S = 1:nSessions
        
                N1 = squeeze(tData(:, Indx_S, 1, Indx_E, :, Indx_B));
        N3 = squeeze(tData(:, Indx_S, Indx_L, Indx_E, :, Indx_B));
        
        A = subfigure(Space, miniGrid, [Indx_L-1 Indx_S], [], {}, Pixels);
         shiftaxis(A, Pixels.PaddingLabels, [])

        Stats = plotTopoDiff(N1, N3, Chanlocs, CLims_Diff, StatsP, Pixels);
          Title = strjoin({'M2S_Topo',Sessions.Labels{Indx_S}, Legend{Indx_L}, 'vs', 'BL'}, '_');
         saveStats(Stats, 'Paired', Paths.PaperStats, Title, StatsP)
         
        set(A.Children, 'LineWidth', 1)
        
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
    end
end

Axis.Units = 'normalized';



%%% SD vs BL by level
miniGrid = [3 2];

Space = subaxis(Grid, [1 5], [], Pixels.Letters{Indx}, Pixels);

for Indx_L =  1:numel(Levels)
    
    A = subfigure(Space, miniGrid, [Indx_L 1], [], {}, Pixels);
    BL = squeeze(tData(:, 1, Indx_L, Indx_E, :, Indx_B));
    SD = squeeze(tData(:, 3, Indx_L, Indx_E, :, Indx_B));
    
    shiftaxis(A, Pixels.PaddingLabels*2, Pixels.PaddingLabels)

    Stats = plotTopoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Pixels);
    Title = strjoin({Legend{Indx_L}, 'SDvsBL', 'Topo'}, '_');
    saveStats(Stats, 'Paired', Paths.PaperStats, Title, StatsP)
    
    set(A.Children, 'LineWidth', 1)
    
    title(Legend{Indx_L}, 'FontName', Format.FontName, 'FontSize', Pixels.TitleSize)
end

% plot colorbar
A = subfigure(Space, miniGrid, [3 2], [3, 1], {}, Pixels);
    shiftaxis(A, Pixels.PaddingLabels*2, Pixels.PaddingLabels)
A.Position(1) = .93;
plotColorbar('Divergent', CLims_Diff, Pixels.Labels.ES, Pixels)

colormap(reduxColormap(Format.Colormap.Divergent, Format.Steps.Divergent))


% save
saveFig(strjoin({TitleTag, 'M2S_Topographies'}, '_'), Paths.Paper, Format)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



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
