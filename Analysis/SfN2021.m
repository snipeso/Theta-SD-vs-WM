
close all
clear
clc

Analysis_Parameters

Task = 'Match2Sample';
WelchWindow = 4;
TitleTag = strjoin({'SfN', 'M2S', 'Abstract', num2str(WelchWindow)}, '_');
Sessions = Sessions.(Task);
Filepath =  fullfile(Paths.Data, 'EEG', ['Locked_', num2str(WelchWindow)], Task);

Results = fullfile(Paths.Results, 'SfN');
if ~exist(Results, 'dir')
    mkdir(Results)
end

% load M2S data
AllData = nan(numel(Participants), numel(Sessions), 3);
AllLevels = nan(numel(Participants), numel(Sessions));

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        
        Filename = strjoin({Participants{Indx_P},Task, Sessions{Indx_S}, ...
            'Welch_Locked.mat'}, '_');
        
        if ~exist(fullfile(Filepath, Filename), 'file')
            warning(['Missing ', Filename])
            continue
        end
        load(fullfile(Filepath, Filename), 'Baseline', 'Encoding', 'Retention', ...
            'Freqs', 'Chanlocs', 'Trials')
        
        if isempty(Baseline)
            continue
        end
        
        AllData(Indx_P, Indx_S, 1, 1:numel(Chanlocs), 1:numel(Freqs), 1:size(Trials, 1)) = Baseline;
        AllData(Indx_P, Indx_S, 2, 1:numel(Chanlocs), 1:numel(Freqs), 1:size(Trials, 1)) = Encoding;
        AllData(Indx_P, Indx_S, 3, 1:numel(Chanlocs), 1:numel(Freqs), 1:size(Trials, 1)) = Retention;
        
        AllLevels(Indx_P, Indx_S, 1:size(Trials, 1)) = Trials.level;
        clear Baseline Encoding Retention Trials
    end
end

% z-score it
zData = ZscoreData(AllData, 'last-1');

Theta = dsearchn(Freqs', Bands.Theta');

%%

%%% plots and stats

% N1 vs N3 BL, SD1 and SD2 topoplot (retention)
% identify fmTheta, and how it changes with SD
CLims = [-6 6];
Levels = [1 3];
figure('units','normalized','outerposition',[0 0 .5 .4])
for Indx_S = 1:numel(Sessions)
    
    Data_Leveled = nan(numel(Participants), numel(Chanlocs), numel(Levels));
    for Indx_P = 1:numel(Participants)
        for Indx_L = 1:numel(Levels)
            Tr = AllLevels(Indx_P, Indx_S, :) == Levels(Indx_L);
            Data_Leveled(Indx_P, :, Indx_L) = ...
                squeeze(nanmean(nanmean(zData(Indx_P, Indx_S, 3, :, Theta(1):Theta(2), Tr), 5), 6));
        end
    end
    
    N1 = squeeze(Data_Leveled(:, :, 1));
    N3 = squeeze(Data_Leveled(:, :, 2));
    
    subplot(1, numel(Sessions), Indx_S)
    plotTopoDiff(N1, N3, Chanlocs, CLims, Format)
    title([Sessions{Indx_S}, ' N3vN1'])
end

saveas(gcf,fullfile(Results, [TitleTag, '_fmTheta_Topography_by_Session.svg']))
saveas(gcf,fullfile(Results, [TitleTag, '_fmTheta_Topography_by_Session.png']))


% BL vs SD2 for encoding, retention, bl and probe
% identify sdTheta and how it changes with task component
Windows = {'Baseline', 'Encoding', 'Retention'};

figure('units','normalized','outerposition',[0 0 .5 .4])
for Indx_W = 1:numel(Windows)
    
    BL = squeeze(nanmean(nanmean(zData(:, 1, Indx_W, :, Theta(1):Theta(2), :), 5), 6));
    SD = squeeze(nanmean(nanmean(zData(:, 3, Indx_W, :, Theta(1):Theta(2), :), 5), 6));
    
    subplot(1, numel(Windows), Indx_W)
    plotTopoDiff(BL, SD, Chanlocs, CLims, Format)
    title([Windows{Indx_W}, ' SD2vBL'])
    
end
saveas(gcf,fullfile(Results, [TitleTag, '_sdTheta_Topography_by_Window.svg']))
saveas(gcf,fullfile(Results, [TitleTag, '_sdTheta_Topography_by_Window.png']))


%%
% plot spectrums of key channels
Ch = Channels.Sample;
Ch = labels2indexes(Ch, Chanlocs);
ChLabels = Channels.Sample_Titles;


for Indx_Ch = 1:numel(Ch)
    figure('units','normalized','outerposition',[0 0 1 1])
    Indx= 1;
    for Indx_W = 1:3
        for Indx_S = 1:numel(Sessions)
            
            Data_Leveled = nan(numel(Participants), numel(Levels),  numel(Freqs));
            for Indx_P = 1:numel(Participants)
                for Indx_L = 1:numel(Levels)
                    Tr = AllLevels(Indx_P, Indx_S, :) == Levels(Indx_L);
                    Data_Leveled(Indx_P, Indx_L, :) = ...
                        squeeze(nanmean(zData(Indx_P, Indx_S, Indx_W, Ch(Indx_Ch), :, Tr), 6));
                end
            end
            
            
            subplot(3, 3, Indx)
            PlotPowerHighlight(Data_Leveled, Freqs, Theta, Format.Colormap.Rainbow([1, 100], :), Format, {'N1', 'N3'})
            title(strjoin({Sessions{Indx_S}, Windows{Indx_W}, ChLabels{Indx_Ch}}, ' '))
            Indx = Indx+1;
        end
        
    end
    
    NewLims = SetLims(3, 3, 'y');
    
    
    saveas(gcf,fullfile(Results, [TitleTag,  ChLabels{Indx_Ch}, '_Spectrum.svg']))
    saveas(gcf,fullfile(Results, [TitleTag,  ChLabels{Indx_Ch}, '_Spectrum.png']))
    
end

% stats: hotspot theta N1 vs N3 (p value, cohen's d) and bl/ret BL v SD2 and v
% SD1



%% show peak difference
% difference between N3 peak and SD2 peak


Hotspot = Channels.Hotspot;
Hotspot = labels2indexes(Hotspot, Chanlocs);

N3_Peak = nan(numel(Participants), 1);

for Indx_P = 1:numel(Participants)
 
    N3 = AllLevels(Indx_P, 1, :) == 3;
    Data_N3 = squeeze(nanmean(nanmean(zData(Indx_P, 1, 3, Hotspot, :, N3), 4),6));
    
    [Peak, Amp] = bandPeak(Data_N3, Freqs, Bands.Theta);
    N3_Peak(Indx_P) = Peak;
end


SD_Peak = nan(numel(Participants), 2);

for Indx_P = 1:numel(Participants)
    
    for Indx_S = [2, 3]
    Data_SD = squeeze(nanmean(nanmean(zData(Indx_P, Indx_S, 3, Hotspot, :, :), 4),6));
    
    [Peak, Amp] = bandPeak(Data_SD, Freqs, Bands.Theta);
    SD_Peak(Indx_P, Indx_S-1) = Peak;
    end
end
figure
PlotConfettiSpaghetti([N3_Peak, SD_Peak], {'N3 Peak', 'SD1 Peak',  'SD2 Peak'}, [], [], [], Format, true);
title('N3 vs SD peak frequency')
ylabel('Peak Frequency')

saveas(gcf,fullfile(Results, [TitleTag,  'N3Peak_vs_SD2Peak.png']))

[~, p, ~, stats] = ttest(N3_Peak, SD_Peak(:, 2));
disp(['SD2 Peak (Mean+-STD): ', num2str(nanmean(SD_Peak(:, 2))), '+-', num2str(nanstd(SD_Peak(:, 2))) ])
disp(['fmTheta (Mean+-STD): ', num2str(nanmean(N3_Peak)), '+-', num2str(nanstd(N3_Peak)) ])
disp(['p-value: ', num2str(p), '; t-value: ', num2str(stats.tstat)])

[~, p, ~, stats] = ttest(N3_Peak, SD_Peak(:, 1));
disp(['SD1 Peak (Mean+-STD): ', num2str(nanmean(SD_Peak(:, 1))), '+-', num2str(nanstd(SD_Peak(:, 1))) ])
disp(['fmTheta (Mean+-STD): ', num2str(nanmean(N3_Peak)), '+-', num2str(nanstd(N3_Peak)) ])
disp(['p-value: ', num2str(p)])


figure
PlotConfettiSpaghetti([N3_Peak, SD_Peak(:, 2)], {'N3 Peak', 'SD2 Peak'}, [], [], [], Format, true);

%% show peak change
% peak frequency: N3 - N1 peak VS SD2 - BL peak (in retention and encoding and bl)

Hotspot = Channels.Hotspot;
Hotspot = labels2indexes(Hotspot, Chanlocs);


fmTheta = nan(numel(Participants), 1);

for Indx_P = 1:numel(Participants)
    
    N1 = AllLevels(Indx_P, 1, :) == 1;
    Data_N1 = squeeze(nanmean(nanmean(zData(Indx_P, 1, 3, Hotspot, :, N1), 4),6));
    
    N3 = AllLevels(Indx_P, 1, :) == 3;
    Data_N3 = squeeze(nanmean(nanmean(zData(Indx_P, 1, 3, Hotspot, :, N3), 4),6));
    
    [Peak, Amp] = bandPeak(Data_N3-Data_N1, Freqs, Bands.Theta);
    fmTheta(Indx_P) = Peak;
end


sdTheta = nan(numel(Participants), 1);

for Indx_P = 1:numel(Participants)
    
    Data_BL = squeeze(nanmean(nanmean(zData(Indx_P, 1, 3, Hotspot, :, :), 4),6));
    
    Data_SD2 = squeeze(nanmean(nanmean(zData(Indx_P, 3, 3, Hotspot, :, :), 4),6));
    
    [Peak, Amp] = bandPeak(Data_SD2-Data_BL, Freqs, Bands.Theta);
    sdTheta(Indx_P) = Peak;
end


figure
PlotConfettiSpaghetti([fmTheta, sdTheta], {'fmTheta', 'sdTheta'}, [], [], [], Format, true);
ylabel('Peak Frequency')
title('N3-N1 Peak vs SD-BL Peak')

saveas(gcf,fullfile(Results, [TitleTag,  'fmThetaPeak_vs_sdThetaPeak.png']))

[~, p, ~, stats] = ttest(fmTheta, sdTheta);


disp(['sdTheta (Mean+-STD): ', num2str(nanmean(sdTheta)), '+-', num2str(nanstd(sdTheta)) ])
disp(['fmTheta (Mean+-STD): ', num2str(nanmean(fmTheta)), '+-', num2str(nanstd(fmTheta)) ])
disp(['p-value: ', num2str(p)])