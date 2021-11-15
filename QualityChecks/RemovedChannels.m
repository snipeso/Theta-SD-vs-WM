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


Results = fullfile(Paths.Results, 'RemovedChannels');
if ~exist(Results, 'dir')
    mkdir(Results)
end


AllCh = nan(numel(Participants), numel(Sessions.Labels), numel(AllTasks), 129);

%% gather info

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions.Labels)
    for Indx_T = 1:numel(AllTasks)
     Filename = strjoin({Participants{Indx_P}, AllTasks{Indx_T}, ...
                Sessions.( AllTasks{Indx_T}){Indx_S}, 'Cuts.mat'}, '_');
    Path = fullfile(Paths.Preprocessed, 'Cutting', 'New_Cuts', AllTasks{Indx_T}, Filename);
    
    load(Path, 'badchans', 'badchans_postICA')

        if ~exist('badchans', 'var')
        badchans = [];
        end
    
    if ~exist('badchans_postICA', 'var')
        badchans_postICA = []; 
    end
    
    
OldChannels = 1:128;
OldChannels(badchans) = [];

Ch = find(ismember(OldChannels, badchans_postICA)); % get new location
    



    clear badchans badchans_postICA
    
    end
    end
end