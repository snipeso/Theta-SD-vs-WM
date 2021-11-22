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



TitleTag = strjoin({'RemovedChannels'}, '_');


Results = fullfile(Paths.Results, 'RemovedChannels');
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
        'Padding', 'none', 'TileSpacing', 'compact');
    
    for Indx_T = 1:numel(AllTasks)
        for Indx_S = 1:numel(Sessions.Labels)
            V = squeeze(ICValues(Indx_P, Indx_S, Indx_T, :, :));
            L = squeeze(ICLabels(Indx_P, Indx_S, Indx_T, :, :));
            nexttile
            plotICLabel(IC, Labels, Format)
            title(strjoin({Participants{Indx_P}, TaskLabels{Indx_T}, Sessions.Labels{Indx_S}}, ' '))
        end
    end
    
    saveFig(strjoin({TitleTag, 'Task'}, '_'), Results, Format)

end

% get percent removed components per task and per session


% Get overall proportion of correct brain, correct noise, FA, MR. Plot all
% values of all recordings (see if a better threshold emerges)