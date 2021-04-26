
close all
clc
clear

Prep_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Fixation';
Refresh = false;

Data_Type = 'Power';

Source_Folder = 'Elena'; % 'Deblinked'
Destination_Folder = 'SourceLocalization';
Cuts_Folder = 'New_Cuts';

Window = 4; % epoch window in seconds

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Source =  fullfile(Paths.Preprocessed, 'Clean', Data_Type, Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', Cuts_Folder, Task);

Destination = fullfile(Paths.Preprocessed, Destination_Folder, Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end



Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];

% randomize files list
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
    [Channels, Points] = size(EEG.data);
    fs = EEG.srate;
    
    try % lazy programming; if all the events needed to specify stop and start are present, use
        % remove start and stop
        StartPoint = EEG.event(strcmpi({EEG.event.type}, EEG_Triggers.Start)).latency;
        EndPoint =  EEG.event(strcmpi({EEG.event.type},  EEG_Triggers.End)).latency;
        EEG.data(:, [1:round(StartPoint),  round(EndPoint):end]) = nan;
    end
    
    
    % set to nan all cut data
    Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(Filename, '_Clean'), '_Cuts.mat']);
    EEG = nanNoise(EEG, Cuts_Filepath);
    
    % remove non-elena channels
    RmCh = find(ismember({EEG.chanlocs.labels}, [string(EEG_Channels.notSourceLoc), "CZ"]));
    EEG = pop_select(EEG, 'nochannel', RmCh);
    
    % epoch data
    Starts = 1:Window*fs:Points;
    Starts(end) = [];
    Indx = numel(EEG.event)+1;
    for Indx_S = 1:numel(Starts)
        
        EEG.event(Indx).latency = Starts(Indx_S);
        EEG.event(Indx).duration = .5;
        EEG.event(Indx).channel = 0;
        EEG.event(Indx).type = 'Epoch_Start';
        EEG.event(Indx).code = 'edge';
        Indx = Indx+1;
    end
    
    EEG = pop_epoch(EEG, {'Epoch_Start'}, [0 Window]);
    
    
    % remove epochs with noises
    hasNan = [];
    for Indx_S = 1:size(EEG.data, 3)
        Data = EEG.data(:, :, Indx_S);
        if any(isnan(Data(:)))
            hasNan = [hasNan, Indx_S];
        end
    end
    
    EEG = pop_select(EEG, 'notrial', hasNan);
    
    Data = eeglab2fieldtrip(EEG, 'raw', 'none');
    
    
    save(fullfile(Destination, NewFilename), 'Data', '-v7.3');
    
end