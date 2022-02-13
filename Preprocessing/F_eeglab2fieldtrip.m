% This script converts data to fieldtrip datastructure for source localization.
close all
clc
clear

Prep_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = false;

Data_Type = 'Power';

Destination_Folder = 'SourceLocalization119_Old';
Cuts_Folder = 'Cuts';

Window_seconds = 8; % epoch window in seconds
Minutes = 4; % time in windows to use for epochs

EEG_Triggers.Start = 'S  1';
EEG_Triggers.End = 'S  2';

allTasks = {'Standing', 'Fixation', 'Oddball'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for Indx_T = 1:numel(allTasks)
    
    Task = allTasks{Indx_T};
    
    Source =  fullfile(Paths.Preprocessed, 'Clean_Old', Data_Type, Task);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', Cuts_Folder, Task);
    
    Destination = fullfile(Paths.Preprocessed, Destination_Folder, Task);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.set')) = [];
    
    % randomize files list [???] 
    % --> ElIAS: does this still need to be adjusted?
    nFiles = numel(Files);
    
    for Indx_F = 1:nFiles
        
        Filename = Files{Indx_F};
        NewFilename = [extractBefore(Filename, '_Clean'), '.mat'];
        if ~Refresh && exist(fullfile(Destination, NewFilename), 'file')
            disp(['***********', 'Already did ', Filename, '***********'])
            continue
        end
        EEG = pop_loadset('filepath', Source, 'filename', Filename);
        
        
        %%% Set as nan all noise
        % remove nonEEG channels
        Channels = size(EEG.data, 1);
        fs = EEG.srate;
        Window = 2^nextpow2(Window_seconds*fs); % make window a power of 2
        
        % remove beginning
        if any(strcmpi({EEG.event.type}, EEG_Triggers.Start))
            StartPoint = EEG.event(strcmpi({EEG.event.type}, EEG_Triggers.Start)).latency;
            EEG.data(:, 1:round(StartPoint)) = nan; %this gets removed in rmNoise, which removes anything that's a nan
        else
            warning('not removing beginning data...')
        end
        
        % remove ending
        if any(strcmpi({EEG.event.type},  EEG_Triggers.End))
            EndPoint =  EEG.event(strcmpi({EEG.event.type},  EEG_Triggers.End)).latency;
            EEG.data(:, round(EndPoint):end) = nan; %this gets removed in rmNoise, which removes anything that's a nan
        else
            warning('not removing end data...')
        end
        
        % set to nan all cut data
        Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(Filename, '_Clean'), '_Cuts.mat']);
        try
        EEG = rmNoise(EEG, Cuts_Filepath);
        catch
            continue
        end
        
        EEG = rmNaN(EEG);
        
        % remove non-elena channels
        RmCh = find(ismember({EEG.chanlocs.labels}, [string(EEG_Channels.notSourceLoc), "CZ"]));
        EEG = pop_select(EEG, 'nochannel', RmCh);
        
        %%% epoch data
        EEG = keepEEG(EEG, Minutes);
        Points = size(EEG.data, 2);
        
        Starts = 1:Window:Points;
        Indx = numel(EEG.event)+1;
        for Indx_S = 1:numel(Starts)
            
            EEG.event(Indx).latency = Starts(Indx_S);
            EEG.event(Indx).duration = .5;
            EEG.event(Indx).channel = 0;
            EEG.event(Indx).type = 'Epoch_Start';
            EEG.event(Indx).code = 'edge';
            Indx = Indx+1;
        end
        
        % remove all events that are marked as boundaries
        EEG.event(strcmp({EEG.event.type}, 'boundary')) = [];
        
        % epoch data into the windows
        EEG = pop_epoch(EEG, {'Epoch_Start'}, [0 Window/fs]);
        
        Data = eeglab2fieldtrip(EEG, 'raw', 'none');
        
        save(fullfile(Destination, NewFilename), 'Data', '-v7.3');
        
    end
end