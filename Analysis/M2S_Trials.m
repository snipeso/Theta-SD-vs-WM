% script for plotting individual trials of the STM task

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

Type = 'Zscore';


TitleTag = strjoin({'M2S', Tag, 'Trials', Type}, '_');
BandLabels = fieldnames(Bands);
ChLabels = fieldnames(Channels.(ROI));

Main_Results = fullfile(Paths.Results, 'M2S_Tials', Tag);
if ~exist(Main_Results, 'dir')
    for Indx_B = 1:numel(BandLabels)
        for Indx_E = 1:numel(Epochs)
            mkdir(fullfile(Main_Results, BandLabels{Indx_B}, Epochs{Indx_E}))
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(Paths.Data, 'EEG', 'Locked', Task, Tag);
[AllData, Freqs, Chanlocs, AllTrials] = loadM2Spower(P, Filepath);

switch Type
    case 'Raw'
        % average data into ROIs
        chData = meanChData(AllData, Chanlocs, Channels.(ROI), 5);
        Label = Format.Labels.Power;
    case 'Zscore'
        
        % z-score it
        zData = zScoreData(AllData, 'last');
        
        % average data into ROIs
        chData = meanChData(zData, Chanlocs, Channels.(ROI), 5);
        Label =  Format.Labels.zPower;
    otherwise
        error('invalid type, must be Raw or Zscore')
end


% save it into bands
bchData = bandData(chData, Freqs, Bands, 'last');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

CLims_Diff = [-2 2];
[nParticipants, nSessions, nTrials, nEpochs, nCh, nFreqs] = size(AllData);

Epochs = Format.Labels.Epochs;
Levels = [1 3 6];

Trials = repmat(1:120, 18, 1);
Legend = append('L', string(Levels));

%% scatter plot for each session for each

B_Indx = 2; % theta


LineColors = flip(getColors([1 3], 'rainbow', 'black'));

for Indx_E = 1:nEpochs
    Results = fullfile(Main_Results, BandLabels{B_Indx}, Epochs{Indx_E});
    
    for Indx_Ch = 1:numel(ChLabels)
        figure('units','normalized','outerposition',[0 0 .5 1])
        for Indx_S = 1:nSessions
            
            subplot(1, 3, Indx_S)
            hold on
            for Indx_L = numel(Levels):-1:1
                Data = squeeze(bchData(:, Indx_S, :, Indx_E, Indx_Ch, B_Indx));
                L = squeeze(AllTrials.level(:, Indx_S, :)) == Levels(Indx_L);
                
                D = Data(L);
                T = Trials(L);
                scatter(T, D, 20, ...
                    Format.Colors.Levels(Indx_L, :), 'filled', 'MarkerFaceAlpha', 1)
            end
            
            Lines = lsline;
            for Indx_L = numel(Levels):-1:1
                Lines(Indx_L).Color = LineColors(Indx_L, :);
                Lines(Indx_L).LineWidth = Format.LW;
            end
            
            ylabel([BandLabels{B_Indx}, ' ', Label])
            xlabel('Trial')
            axis tight
            set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize)
            title(strjoin({Sessions.Labels{Indx_S}, Epochs{Indx_E}, ChLabels{Indx_Ch}}, ' '), 'FontSize', Format.TitleSize)
            if Indx_S ==2
                legend(flip(Legend))
            end
        end
        setLims(1, 3, 'y');
        saveFig(strjoin({TitleTag, 'ByLevel', BandLabels{B_Indx}, Epochs{Indx_E}, ChLabels{Indx_Ch}}, '_'), Results, Format)
    end
end


%% Color code by participant

B_Indx = 2; % theta


LineColors = flip(getColors([1 3], 'rainbow', 'black'));

for Indx_E = 1:nEpochs
    Results = fullfile(Main_Results, BandLabels{B_Indx}, Epochs{Indx_E});
    
    for Indx_Ch = 1:numel(ChLabels)
        figure('units','normalized','outerposition',[0 0 .5 1])
        for Indx_S = 1:nSessions
            
            subplot(1, 3, Indx_S)
            hold on
            for Indx_P = 1:nParticipants
                Data = squeeze(bchData(Indx_P, Indx_S, :, Indx_E, Indx_Ch, B_Indx));
                scatter(1:120, Data, 20, ...
                    Format.Colors.Participants(Indx_P, :), 'filled', 'MarkerFaceAlpha', 1)
            end
            
            
            ylabel([BandLabels{B_Indx}, ' ', Label])
            xlabel('Trial')
            axis tight
            set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize)
            title(strjoin({Sessions.Labels{Indx_S}, Epochs{Indx_E}, ChLabels{Indx_Ch}}, ' '), 'FontSize', Format.TitleSize)
        end
        setLims(1, 3, 'y');
        saveFig(strjoin({TitleTag, 'ByParticipant', BandLabels{B_Indx}, Epochs{Indx_E}, ChLabels{Indx_Ch}}, '_'), Results, Format)
    end
end



%% violin plot, each violin is a session, each x axis is an epoch


B_Indx = 2; % theta


LineColors = flip(getColors([1 3], 'rainbow', 'black'));


Results = fullfile(Main_Results, BandLabels{B_Indx});

for Indx_Ch = 1:numel(ChLabels)
    figure('units','normalized','outerposition',[0 0 .5 1])
    
    Data = squeeze(bchData(:, :, :, :, Indx_Ch, B_Indx));
    
    Data = permute(Data, [2, 4, 1, 3]);
    Data = reshape(Data, nSessions, nEpochs, []);
    
    plotFlames(Data, Epochs, getColors(3), .3, Format)
    ylabel([BandLabels{B_Indx}, ' ', Label])
    title([ChLabels{Indx_Ch}, ' distribution change'])
    
    saveFig(strjoin({TitleTag, 'DistributionFlame', BandLabels{B_Indx}, ChLabels{Indx_Ch}}, '_'), Results, Format)
end

%% plot histogram of theta retention1

E_Indx = 2;
Ch_Indx = 1;
B_Indx = 2;
Data = squeeze(bchData(:, :, :, E_Indx, Ch_Indx, B_Indx));

Data = permute(Data, [2, 1, 3]);
Data = reshape(Data, nSessions, []);
figure('units','normalized','outerposition',[0 0 1 .5])
plotHistogram(Data, 0.1, [], Label, [], Sessions.Labels, getColors(3), Format)
title(strjoin({BandLabels{B_Indx}, Epochs{E_Indx}, ChLabels{Ch_Indx}}, ' '), 'FontSize', Format.TitleSize)
saveFig(strjoin({TitleTag, 'Distribution', BandLabels{B_Indx}, ChLabels{Indx_Ch}}, '_'), Results, Format)


%% change in quantiles

Ch_Indx = 1;
B_Indx = 2;

for Indx_E = 1:numel(Epochs)
    Results = fullfile(Main_Results, BandLabels{B_Indx}, Epochs{Indx_E});
    Data = squeeze(bchData(:, :, :, Indx_E, Ch_Indx, B_Indx));
    
    Quants = 0.05:.05:.95;
    Q = quantile(Data, Quants, 3);
    
    Colors = getColors([1, numel(Quants)], 'rainbow', 'red');
    
    figure('units','normalized','outerposition',[0 0 .3 1])
    plotSpaghettiOs(Q, 1, Sessions.Labels, string(Quants), Colors, StatsP, Format)
    title(['Theta increase tensiles', Epochs{Indx_E}])
    saveFig(strjoin({TitleTag, 'QuantileChange', BandLabels{B_Indx}, ChLabels{Indx_Ch}}, '_'), Results, Format)
    
    
    figure('units','normalized','outerposition',[0 0 .66 .5])
    Stats = plotES(squeeze(Q(:, [1 3], :)), 'horizontal', false, Colors, string(Quants), ...
        [], Format, StatsP);
    title(strjoin({BandLabels{B_Indx}, Epochs{Indx_E}, ChLabels{Ch_Indx}}, ' '), 'FontSize', Format.TitleSize)
    saveFig(strjoin({TitleTag, 'QuantileES', BandLabels{B_Indx}, ChLabels{Indx_Ch}}, '_'), Results, Format)
end
