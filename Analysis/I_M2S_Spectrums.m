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
SmoothFactor = 1; % in Hz, range to smooth over
Pixels = P.Pixels;

ROI = 'preROI';
Window = 8;
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
chData = smoothFreqs(chData, Freqs, 'last', SmoothFactor);

spData = splitLevelsEEG(chData, AllTrials.level);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

ChLabels = fieldnames(Channels.(ROI));
CLims_Diff = [-1.7 1.7];
[nParticipants, nSessions, nTrials, nEpochs, nCh, nFreqs] = size(AllData);

Epochs = Format.Labels.Epochs;
Levels = [1 3 6];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure

%% spectrums by level

% format variables
Pixels.xPadding = 10; % smaller distance than default because no labels
Pixels.yPadding = 10;
Indx_E = 2;

Grid = [numel(ChLabels), numel(Sessions.Labels)];
YLim = [-.2 1.5];

Log = true; % whether to plot on log scale or not
figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.47])
Indx = 1; % tally of axes

for Indx_Ch = 1:numel(ChLabels)
    for Indx_S = 1:numel(Sessions.Labels)
        Data = squeeze(spData(:, Indx_S, :, Indx_E, Indx_Ch, :));
        
        Axes(Indx) = subfigure([], Grid, [Indx_Ch, Indx_S], [], '', Pixels);
        Indx = Indx+1;
        
        plotSpectrumDiff(Data, Freqs, 1, {'L1', 'L3', 'L6'}, flip(Format.Colors.Levels), Log, Pixels, StatsP);
ylim(YLim)
 % plot labels/legends only in specific locations
        if Indx_Ch > 1 || Indx_S > 1 % first tile
            legend off
            
        end
        
        if Indx_S == 1 % first column
            ylabel(Format.Labels.zPower)
            X = get(gca, 'XLim');
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


%% plot spectrum: N1, N3 and N6 at BL, SR, and SD

for Indx_E = 1:numel(Epochs)
    
    figure('units','normalized','outerposition',[0 0 .76 1])
    tiledlayout( numel(ChLabels), numel(Sessions.Labels), 'Padding', 'none', 'TileSpacing', 'compact');
    
    for Indx_Ch = 1:numel(ChLabels)
        for Indx_S = 1:numel(Sessions.Labels)
            Data = squeeze(spData(:, Indx_S, :, Indx_E, Indx_Ch, :));
            
            nexttile
            plotSpectrumDiff(Data, Freqs, 1, [], Format.Colors.Levels, Format, StatsP);
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

figure('units','normalized','outerposition',[0 0 .76 1])
tiledlayout( numel(Epochs), numel(ChLabels), 'Padding', 'none', 'TileSpacing', 'compact');
for Indx_Ch = 1:numel(ChLabels)
    for Indx_E = 1:numel(Epochs)
        
        Data = squeeze(nanmean(chData(:, :, :, Indx_E, Indx_Ch, :), 3));
        
        nexttile
        plotSpectrumDiff(Data, Freqs, 1, [], Format.Colors.Sessions, Format, StatsP);
        set(gca,'FontSize', 14)
        legend off
        title(strjoin({ChLabels{Indx_Ch}, Epochs{Indx_E}}, ' '), 'FontSize', Format.TitleSize)
        
    end
    
    
    
end

legend(Sessions.Labels)
setLimsTiles(numel(ChLabels)*numel(Epochs), 'y');
% save
saveFig(strjoin({TitleTag, 'SessionxEpoch'}, '_'), Results, Format)

%% plot fmTheta: N3 vs N1 at BL, SR and SD


%% the above, but individual participants at BL




%% for every epoch, at each ch, plot N3-N1 and SD-BL