
close all
clear
clc

Analysis_Parameters

Task = 'Match2Sample';
Sessions = {'Baseline', 'Session1', 'Session2'};
Filepath =  fullfile(Paths.Data, 'Locked', Task);

Results = fullfile(Paths.Results, 'SfN');
if ~exist(Results, 'dir')
    mkdir(Results)
end

% load M2S data
AllData = nan(numel(Participants), numel(Sessions), 3);

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        
        Filename = strjoin({Participants{Indx_P},Task, Sessions{Indx_S}, ...
            'Welch_Locked.mat'}, '_');
        
        if ~exist(fullfile(Filepath, Filename), 'file')
            warning(['Missing ', Filename])
            continue
        end
        load(fullfile(Filepath, Filename), 'Baseline', 'Encoding', 'Retention', ...
            'Freqs', 'Chanlocs')
        
        if isempty(Baseline)
            continue
        end
        
        AllData(Indx_P, Indx_S, 1, 1:numel(Chanlocs), 1:numel(Freqs)) = Baseline;
        AllData(Indx_P, Indx_S, 2, 1:numel(Chanlocs), 1:numel(Freqs)) = Encoding;
        AllData(Indx_P, Indx_S, 3, 1:numel(Chanlocs), 1:numel(Freqs)) = Retention;
    
        clear Baseline Encoding Retention
    end
end

% z-score it 
zData = ZscoreData(AllData, 'last');

%%

%%% plots and stats

% N1 vs N3 BL, SD1 and SD2 topoplot (retention)
% identify fmTheta, and how it changes with SD
CLims = [-5 5];
 figure('units','normalized','outerposition',[0 0 .5 .4])
 for Indx = 1:numel(Sessions)
    subplot(1, numel(Sessions), Indx)
    PlotTopoDiff(Matrix1, Matrix2, Chanlocs, CLims, Format)
    title([Sessions{Indx_S}, ' N3vN2'])
 end
 
saveas(gcf,fullfile(Results, [TitleTag,  '_RRT_',ChannelLabels{Indx_Ch}, '.svg']))


% BL vs SD2 for encoding, retention, bl and probe
% identify sdTheta and how it changes with task component


% stats: hotspot theta N1 vs N3 (p value, cohen's d) and bl/ret BL v SD2 and v
% SD1 


% peak frequency: N3 - N1 peak VS SD2 - BL peak (in retention and encoding and bl)