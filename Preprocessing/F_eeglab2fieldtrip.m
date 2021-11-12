
close all
clc
clear

Prep_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Match2Sample';
Refresh = false;

Data_Type = 'Power';

Destination_Folder = 'SourceLocalization';
Cuts_Folder = 'New_Cuts';

Window = 8; % epoch window in seconds

EEG_Triggers.Start = 'S  1';
EEG_Triggers.End = 'S  2';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Source =  fullfile(Paths.Preprocessed, 'Clean', Data_Type, Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', Cuts_Folder, Task);

Destination = fullfile(Paths.Preprocessed, Destination_Folder, Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];

% randomize files list [???]
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
     EEG = rmNoise(EEG, Cuts_Filepath);
    
      EEG = rmNaN(EEG);
      
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
    
    Data = eeglab2fieldtrip(EEG, 'raw', 'none');

    save(fullfile(Destination, NewFilename), 'Data', '-v7.3');

end