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

AllCh(:, :, :, Channels.Removed) = [];

%%% plots

%% overall removed channels

figure('units','normalized','outerposition',[0 0 1 .3])
tiledlayout(1, 1, 'Padding', 'none', 'TileSpacing', 'compact');
nexttile
Data = 100*(squeeze(sum(sum(sum(AllCh==0, 3), 2),1))./squeeze(sum(sum(sum(~isnan(AllCh), 3), 2),1)));
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
StandardChanlocs(Channels.Removed) = [];

figure('units','normalized','outerposition',[0 0 .3 .4])
bubbleTopo(Data, StandardChanlocs, 200, '2D', {StandardChanlocs.labels}, Format)
colormap(flip(Format.Colormap.Monochrome))
saveFig(strjoin({TitleTag, 'allRecordings', 'Topo'}, '_'), Results, Format)


%% removed channels split by session
Data = 100*(squeeze(sum(sum(AllCh==0, 3),1))./squeeze(sum(sum(~isnan(AllCh)==1, 3),1)));


figure('units','normalized','outerposition',[0 0 1 1])
tiledlayout(numel(Sessions.Labels), 1, 'Padding', 'none', 'TileSpacing', 'compact');
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

saveFig(strjoin({TitleTag, 'Sessions'}, '_'), Results, Format)

%%
figure('units','normalized','outerposition',[0 0 .6 .4])
tiledlayout(1, numel(Sessions.Labels), 'Padding', 'none', 'TileSpacing', 'compact');
for Indx_S =1:numel(Sessions.Labels)
    
    D = Data(Indx_S, :);
    nexttile
    bubbleTopo(D, StandardChanlocs, 200, '2D',  string(round(D)), Format)
    colormap(flip(Format.Colormap.Monochrome))
    colorbar off
    title([Sessions.Labels{Indx_S}], 'FontSize', Format.TitleSize)
end
setLimsTiles( numel(Sessions.Labels), 'c')

saveFig(strjoin({TitleTag, 'Sessions', 'Topos'}, '_'), Results, Format)


%% removed channels split by task

Data = 100*(squeeze(sum(sum(AllCh==0, 2),1))./squeeze(sum(sum(~isnan(AllCh), 2),1)));


figure('units','normalized','outerposition',[0 0 1 1])
tiledlayout(numel(AllTasks), 1, 'Padding', 'none', 'TileSpacing', 'compact');
for Indx_T =1:numel(AllTasks)
    
    D = Data(Indx_T, :);
    nexttile
    drawBars(D, string(1:129), getColors(1), 'vertical', [], Format)
    set(gca, 'FontSize', 10)
    ylabel('%')
    xticks(1:129)
    xticklabels(1:129)
    title(['Removed Channels from ', TaskLabels{Indx_T}], 'FontSize', Format.TitleSize)
end

saveFig(strjoin({TitleTag, 'Tasks'}, '_'), Results, Format)

%%
figure('units','normalized','outerposition',[0 0 1 .4])
tiledlayout(1, numel(TaskLabels), 'Padding', 'none', 'TileSpacing', 'compact');
for Indx_T =1:numel(AllTasks)
    
    D = Data(Indx_T, :);
    nexttile
    bubbleTopo(D, StandardChanlocs, 200, '2D', string(round(D)), Format)
    colormap(flip(Format.Colormap.Monochrome))
    colorbar off
    title([TaskLabels{Indx_T}], 'FontSize', Format.TitleSize)
end
setLimsTiles(numel(AllTasks), 'c')

saveFig(strjoin({TitleTag, 'Tasks', 'Topos'}, '_'), Results, Format)



%% removed channels split by participant

Data = 100*(squeeze(sum(sum(AllCh==0, 2),3))./squeeze(sum(sum(~isnan(AllCh), 2),3)));


for Indx_P =1:numel(Participants)
    if ismember(Indx_P, [1 5 9 13 17])
        if Indx_P ~= 1
            
            saveFig(strjoin({TitleTag, 'Participants', num2str(Indx_P)}, '_'), Results, Format)
        end
        figure('units','normalized','outerposition',[0 0 1 1])
        tiledlayout(4, 1, 'Padding', 'none', 'TileSpacing', 'compact');
    end
    D = Data(Indx_P, :);
    nexttile
    drawBars(D, string(1:129), getColors(1), 'vertical', [], Format)
    set(gca, 'FontSize', 10)
    ylabel('%')
    xticks(1:129)
    xticklabels(1:129)
    title(['Removed Channels from ', Participants{Indx_P}], 'FontSize', Format.TitleSize)
end


%%
figure('units','normalized','outerposition',[0 0 1 1])
tiledlayout(3,6, 'Padding', 'none', 'TileSpacing', 'compact');
for Indx_P =1:numel(Participants)
    
    D = Data(Indx_P, :);
    nexttile
    bubbleTopo(D, StandardChanlocs, 200, '2D', string(round(D)), Format)
    colormap(flip(Format.Colormap.Monochrome))
    colorbar off
    title([Participants{Indx_P}], 'FontSize', Format.TitleSize)
end
setLimsTiles(numel(Participants), 'c')

saveFig(strjoin({TitleTag, 'Participants', 'Topos'}, '_'), Results, Format)


