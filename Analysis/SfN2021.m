
close all
clear
clc

Analysis_Parameters

Task = 'Match2Sample';
TitleTag = strjoin({'SfN', 'M2S', 'Abstract'}, '_');
Sessions = {'Baseline', 'Session1', 'Session2'};
Filepath =  fullfile(Paths.Data, 'EEG', 'Locked', Task);

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
zData = ZscoreData(AllData, 'last');

Theta = dsearchn(Freqs', Bands.Theta');
Theta = Theta(1):Theta(2); % bleah
%%

%%% plots and stats

% N1 vs N3 BL, SD1 and SD2 topoplot (retention)
% identify fmTheta, and how it changes with SD
CLims = [-5 5];
Levels = [1 3];
figure('units','normalized','outerposition',[0 0 .5 .4])
for Indx_S = 1:numel(Sessions)

    Data_Leveled = nan(numel(Participants), numel(Chanlocs), numel(Levels));
    for Indx_P = 1:numel(Participants)
        for Indx_L = 1:numel(Levels)
            Tr = AllLevels(Indx_P, Indx_S, :) == Levels(Indx_L);
            Data_Leveled(Indx_P, :, Indx_L) = ...
                squeeze(nanmean(nanmean(zData(Indx_P, Indx_S, 3, :, Theta, Tr), 5), 6));
        end
    end
    
    N1 = squeeze(Data_Leveled(:, :, 1));
    N3 = squeeze(Data_Leveled(:, :, 2));
  
    subplot(1, numel(Sessions), Indx_S)
    PlotTopoDiff(N1, N3, Chanlocs, CLims, Format)
    title([Sessions{Indx_S}, ' N3vN1'])
end

saveas(gcf,fullfile(Results, [TitleTag, '_fmTheta_Topography_by_Session.svg']))



% BL vs SD2 for encoding, retention, bl and probe
% identify sdTheta and how it changes with task component
Windows = {'Baseline', 'Encoding', 'Retention'};

figure('units','normalized','outerposition',[0 0 .5 .4])
for Indx_W = 1:numel(Windows)
    
    BL = squeeze(nanmean(nanmean(zData(:, 1, Indx_W, :, Theta, :), 5), 6));
    SD = squeeze(nanmean(nanmean(zData(:, 3, Indx_W, :, Theta, :), 5), 6));
    
    subplot(1, numel(Windows), Indx_W)
    PlotTopoDiff(BL, SD, Chanlocs, CLims, Format)
    title([Windows{Indx_W}, ' SD2vBL'])
    
end
saveas(gcf,fullfile(Results, [TitleTag, '_sdTheta_Topography_by_Window.svg']))


% stats: hotspot theta N1 vs N3 (p value, cohen's d) and bl/ret BL v SD2 and v
% SD1


% peak frequency: N3 - N1 peak VS SD2 - BL peak (in retention and encoding and bl)