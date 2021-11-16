% plot removed channels as tallies by Participant, Session and task.
% works with a P x S x T x Ch matrix, with nan meaning no data, 0 removed,
% 1 kept.

clear
clc
close all

P = qcParameters();

Paths = P.Paths;
Participants = P.Participants;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
Channels = P.Channels;
StatsP = P.StatsP;

TitleTag = strjoin({'RemovedChannels'}, '_');


Results = fullfile(Paths.Results, 'RemovedChannels');
if ~exist(Results, 'dir')
    mkdir(Results)
end

AllCh = nan(numel(Participants), numel(Sessions.Labels), numel(AllTasks), 129);

% gather info

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions.Labels)
        for Indx_T = 1:numel(AllTasks)
            Filename = strjoin({Participants{Indx_P}, AllTasks{Indx_T}, ...
                Sessions.( AllTasks{Indx_T}){Indx_S}, 'Cuts.mat'}, '_');
            Path = fullfile(Paths.Preprocessed, 'Cutting', 'New_Cuts', AllTasks{Indx_T}, Filename);
            
            if ~exist(Path, 'file')
                continue
            end
            
            load(Path, 'badchans', 'badchans_postICA')
            
            if ~exist('badchans', 'var')
                badchans = [];
            end
            
            if ~exist('badchans_postICA', 'var')
                badchans_postICA = [];
            end
            
            % since file exists, mark all channels as present
            AllCh(Indx_P, Indx_S, Indx_T, :) = 1;
            
            % then indicate which ones were removed
            badchans = [badchans, badchans_postICA]; %#ok<AGROW>
            badchans = unique(badchans);
            AllCh(Indx_P, Indx_S, Indx_T, badchans) = 0;
            
            
            clear badchans badchans_postICA
            
        end
    end
end

%%% plots

%% overall removed channels

figure('units','normalized','outerposition',[0 0 1 .3])
tiledlayout(1, 1, 'Padding', 'none', 'TileSpacing', 'compact');
nexttile
Data = 100*(squeeze(sum(sum(sum(AllCh==0, 3), 2),1))./squeeze(sum(sum(sum(AllCh==1, 3), 2),1)));
drawBars(Data, string(1:129), getColors(1), 'vertical', [], Format)
set(gca, 'FontSize', 10)
ylabel('%')
xticks(1:129)
xticklabels(1:129)
title('Removed Channels from All Recordings', 'FontSize', Format.TitleSize)
saveFig(strjoin({TitleTag, 'allRecordings'}, '_'), Results, Format)

%%
load('StandardChanlocs128.mat', 'StandardChanlocs')
load('Cz.mat', 'CZ')
StandardChanlocs(end+1) = CZ;

figure('units','normalized','outerposition',[0 0 .3 .4])
bubbleTopo(Data, StandardChanlocs, 200, '2D', {StandardChanlocs.labels}, Format)
colormap(flip(Format.Colormap.Monochrome))
saveFig(strjoin({TitleTag, 'allRecordings', 'Topo'}, '_'), Results, Format)


%% removed channels split by session

    figure('units','normalized','outerposition',[0 0 1 1])
    tiledlayout(numel(Sessions.Labels), 1, 'Padding', 'none', 'TileSpacing', 'compact');
    Data = 100*(squeeze(sum(sum(AllCh==0, 3),1))./squeeze(sum(sum(AllCh==1, 3),1)));
    
for Indx_S =1:numel(Sessions.Labels)
   
    D = Data(Indx_S, :);
     nexttile
    drawBars(D, string(1:129), getColors(1), 'vertical', [], Format)
    set(gca, 'FontSize', 10)
    ylabel('%')
    xticks(1:129)
    xticklabels(1:129)
    title(['Removed Channels from ', Sessions.Labels{Indx_S}], 'FontSize', Format.TitleSize)
end

saveFig(strjoin({TitleTag, 'allRecordings'}, '_'), Results, Format)








