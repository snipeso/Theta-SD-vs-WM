% get microsleep data, identify best channels, 



close all
clc
clear
Prep_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = { 'Game', 'Match2Sample', 'PVT', 'LAT', 'SpFT', 'Music', 'MWT'}; % select this if you only need to filter one folder
Refresh = false;

Source_Cuts_Folder = 'New_Cuts'; % 'Cuts'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EEG_Channels = struct();
EEG_Channels.O1 = [70, 65, 66, 69, 71, 74, 59, 60, 67]; % first is preferred o1, the others are decreasing next best options
EEG_Channels.O2 = [83, 90, 84, 89, 76, 82, 91, 85, 77];
EEG_Channels.M1 = [57, 56, 63,  50, 64];
EEG_Channels.M2 = [100, 49, 99, 101, 95];
EEG_Channels.EOG1 = [8, 125,   1, 125,   2, 125,  1, 120,  1,  32];
EEG_Channels.EOG2 = [128,  25, 128,  32, 128,  26, 43,  32, 38, 121];


load('Cz.mat', 'CZ')

if ~exist('Tasks', 'var')
    Tasks = allTasks;
end

for Indx_T = 1:numel(Tasks)
    
    Task = Tasks{Indx_T};
    
    % get files and paths
    Source = fullfile(Paths.Preprocessed, 'Microsleep', 'SET', Task);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', Source_Cuts_Folder, Task);
    Destination = fullfile(Paths.Preprocessed, 'Microsleep', 'MAT', Task);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files) % loop through files in target folder
        
        % get filenames
        Filename_Source = Files{Indx_F};
        Filename_Cuts =  [extractBefore(Filename_Source,'_Microsleep'), '_Cuts.mat'];
        Filename_Destination = [extractBefore(Filename_Source,'.set'), '.mat'];
        
        % skip if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['***********', 'Already did ', Filename_Destination, '***********'])
            continue
        elseif ~exist(fullfile(Source_Cuts, Filename_Cuts), 'file')
            disp(['***********', 'No cuts for ', Filename_Destination, '***********'])
            continue
        end
        
        % load dataset
        EEG = pop_loadset('filepath', Source, 'filename', Filename_Source);
        
        % convert to double
        EEG.data = double(EEG.data);
        
     
        Data = struct();
        ChosenChannels = struct();
        
        % select best channel available
        Channels =  getBestElectrode(EEG, [EEG_Channels.O1', EEG_Channels.O2']);
        Data.EEG.O1 = EEG.data(Channels(1), :);
        Data.EEG.O2  = EEG.data(Channels(2), :);
        ChosenChannels.O = {EEG.chanlocs(Channels).labels};
        
        Channels =  getBestElectrode(EEG, [EEG_Channels.M1', EEG_Channels.M2']);
        Data.EEG.M1 = EEG.data(Channels(1), :);
        Data.EEG.M2  = EEG.data(Channels(2), :);
        ChosenChannels.M = {EEG.chanlocs(Channels).labels};
        
        Channels =  getBestElectrode(EEG, [EEG_Channels.EOG1', EEG_Channels.EOG2']);
        Data.EEG.EOG1 = EEG.data(Channels(1), :);
        Data.EEG.EOG2  = EEG.data(Channels(2), :);
        ChosenChannels.EOG = {EEG.chanlocs(Channels).labels};
        
        Data.srate = EEG.srate;
        
        save(fullfile(Destination, Filename_Destination), 'Data', 'ChosenChannels')
        
        disp(['***********', 'Finished ', Filename_Destination, '***********'])
    end
end