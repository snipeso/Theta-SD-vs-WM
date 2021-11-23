% Script that plots ICLabel values as scatter plot (split by ICLabel type,
% in order of component number, with gray being kept component, red removed
% component).
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



TitleTag = strjoin({'RemovedComponents'}, '_');


Results = fullfile(Paths.Results, 'RemovedComponents');
if ~exist(Results, 'dir')
    mkdir(Results)
end

%%% load all components

%  classes: {'Brain'  'Muscle'  'Eye'  'Heart'  'Line Noise'  'Channel Noise'  'Other'}
ICValues = nan(numel(Participants), numel(Sessions.Labels), numel(AllTasks), 128, 7);
ICLabels = nan(numel(Participants), numel(Sessions.Labels), numel(AllTasks), 128);


for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions.Labels)
        for Indx_T = 1:numel(AllTasks)
            Task = AllTasks{Indx_T};
            Filename = strjoin({Participants{Indx_P}, Task, ...
                Sessions.( AllTasks{Indx_T}){Indx_S},  'ICA', 'Components.set'}, '_');
            
            Path_EEG = fullfile(Paths.Preprocessed, 'ICA', 'Components', Task);
            
            if ~exist(fullfile(Path_EEG, Filename), 'file')
                continue
            end
            
            EEG = pop_loadset('filename', Filename, 'filepath', Path_EEG);
            
            IC = EEG.etc.ic_classification.ICLabel.classifications;
            ICValues(Indx_P, Indx_S, Indx_T, 1:size(IC, 1), :) = IC;
            ICLabels(Indx_P, Indx_S, Indx_T, 1:size(IC, 1)) = EEG.reject.gcompreject;
        end
    end
end


%%% Plots

%% Plot participant per figure, task x session

for Indx_P = 1:numel(Participants)
    
    figure('units','normalized','outerposition',[0 0 1 1])
    tiledlayout(numel(AllTasks), numel(Sessions.Labels), ...
        'Padding', 'none', 'TileSpacing', 'none');
    
    for Indx_T = 1:numel(AllTasks)
        for Indx_S = 1:numel(Sessions.Labels)
            V = squeeze(ICValues(Indx_P, Indx_S, Indx_T, :, :));
            L = squeeze(ICLabels(Indx_P, Indx_S, Indx_T, :, :));
            nexttile
            plotICLabel(V, L, '', Format)
            title(strjoin({Participants{Indx_P}, TaskLabels{Indx_T}, Sessions.Labels{Indx_S}}, ' '))
        end
    end
    
    saveFig(strjoin({TitleTag, 'ByParticipant', Participants{Indx_P}}, '_'), Results, Format)
    
end

%% get percent removed components per task and per session

Data = reshape(ICLabels, [numel(Participants), numel(Sessions.Labels), numel(AllTasks)*128]);
figure('units','normalized','outerposition',[0 0 .4 .5])
plotTally(Data, Sessions.Labels, {'keep', 'not keep'}, getColors(2), [], Format)
saveFig(strjoin({TitleTag, 'BySession'}, '_'), Results, Format)

Data = permute(ICLabels, [1 3 2 4]);
Data = reshape(Data, [numel(Participants), numel(AllTasks), numel(Sessions.Labels)*128]);
figure('units','normalized','outerposition',[0 0 .4 .5])
plotTally(Data, TaskLabels, {'keep', 'not keep'}, getColors(2), [], Format)
saveFig(strjoin({TitleTag, 'ByTask'}, '_'), Results, Format)


% same but for top 60
Data = reshape(ICLabels(:, :, :, 1:60), [numel(Participants), numel(Sessions.Labels), numel(AllTasks)*60]);
figure('units','normalized','outerposition',[0 0 .4 .5])
plotTally(Data, Sessions.Labels, {'keep', 'not keep'}, getColors(2), [], Format)
title('Top60 kept components')
saveFig(strjoin({TitleTag, 'BySession60'}, '_'), Results, Format)

Data = permute(ICLabels(:, :, :, 1:60), [1 3 2 4]);
Data = reshape(Data, [numel(Participants), numel(AllTasks), numel(Sessions.Labels)*60]);
figure('units','normalized','outerposition',[0 0 .4 .5])
plotTally(Data, TaskLabels, {'keep', 'not keep'}, getColors(2), [], Format)
title('Top60 kept components')
saveFig(strjoin({TitleTag, 'ByTask60'}, '_'), Results, Format)


%% Get overall proportion of correct brain, correct noise, FA, MR. Plot all


%% values of all recordings (see if a better threshold emerges)

figure('units','normalized','outerposition',[0 0 1 1])
Data = permute(ICValues, [5 1 2 3 4]);
Data(:, :, :, :, 60:end) = [];
L = ICLabels;
L(:, :, :, 60:end) = [];
V = reshape(Data, 7, []);
plotICLabel(V', L(:), 'max', Format)
saveFig(strjoin({TitleTag, 'All'}, '_'), Results, Format)


%% plot all by task

for Indx_T = 1:numel(AllTasks)
    figure('units','normalized','outerposition',[0 0 .7 .5])
    
    Data = permute(squeeze(ICValues(:, :, Indx_T, :, :)), [4 1 2 3]);
    L = ICLabels(:, :, Indx_T, :);
    V = reshape(Data, 7, []);
    plotICLabel(V', L(:), 'max', Format)
    title(TaskLabels{Indx_T})
    saveFig(strjoin({TitleTag, 'All', TaskLabels{Indx_T}}, '_'), Results, Format)
end


%% Plot participant per figure, task x session

for Indx_P = 1:numel(Participants)
    
    figure('units','normalized','outerposition',[0 0 1 1])
    tiledlayout(numel(AllTasks), numel(Sessions.Labels), ...
        'Padding', 'none', 'TileSpacing', 'none');
    
    for Indx_T = 1:numel(AllTasks)
        for Indx_S = 1:numel(Sessions.Labels)
            V = squeeze(ICValues(Indx_P, Indx_S, Indx_T, 1:60, :));
            L = squeeze(ICLabels(Indx_P, Indx_S, Indx_T, 1:60));
            nexttile
            plotICLabel(V, L, 'max', Format)
            title(strjoin({Participants{Indx_P}, TaskLabels{Indx_T}, Sessions.Labels{Indx_S}}, ' '))
        end
    end
    
    saveFig(strjoin({TitleTag, 'ByParticipant', Participants{Indx_P}, 'Top60'}, '_'), Results, Format)
    
end