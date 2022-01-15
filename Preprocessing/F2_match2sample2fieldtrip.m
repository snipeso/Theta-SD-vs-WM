
close all
clc
clear

Prep_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = true;

Data_Type = 'Power';

Destination_Folder = 'SourceLocalization_Trials119';
Cuts_Folder = 'Cuts';

Window = 2; % epoch window in seconds

EEG_Triggers.Stim = {'S  3'};
EEG_Triggers.Retent = {'S 10'};
EEG_Triggers.Probe = { 'S 11',  'S 12'}; % match and not match probe

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Match2Sample';

Epoch_Names = {'Encoding', 'Retention1', 'Retention2', 'Probe'};

Source =  fullfile(Paths.Preprocessed, 'Clean', Data_Type, Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', Cuts_Folder, Task);
Source_Tables = fullfile(Paths.Final, 'Behavior');

Destination_Core = fullfile(Paths.Preprocessed, Destination_Folder, Task);

for Indx_E = 1:numel(Epoch_Names)
    Destination = fullfile(Destination_Core, Epoch_Names{Indx_E});
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
end

% get filenames
Files = getContent(Source);
nFiles = numel(Files);

% get trial information
Answers_Path = fullfile(Source_Tables, [Task, '_AllAnswers.mat']);
if  exist(Answers_Path, 'file')
    load(Answers_Path, 'Answers')
else
    if ~exist(Source_Tables, 'dir')
        mkdir(Source_Tables)
    end
    
    AllAnswers = importTask(Paths.Datasets, Task, Source_Tables); % needs to have access to raw data folder
    Answers = cleanupMatch2Sample(AllAnswers);
    
    save(Answers_Path, 'Answers');
end

%%%%%%%%%%%%%%
%%% Assemble data

for Indx_F = 1:nFiles
    
    % load data
    Filename = Files{Indx_F};
    Filename_Core = extractBefore(Filename, '_Clean');
    if ~Refresh && exist(fullfile(Destination, [Filename_Core, '_', Epoch_Names{end}, '.mat']), 'file') % Hack, checks if the last epoch is present, not all of them
        disp(['***********', 'Already did ', Filename, '***********'])
        continue
    end
    EEG = pop_loadset('filepath', Source, 'filename', Filename);
    
    
    %%% Set as nan all noise
    % remove nonEEG channels
    [Channels, Points] = size(EEG.data);
    fs = EEG.srate;
    
    % set to nan all cut data
    Cuts_Filepath = fullfile(Source_Cuts, [extractBefore(Filename, '_Clean'), '_Cuts.mat']);
    EEG = nanNoise(EEG, Cuts_Filepath);
    
    % remove non-elena channels
    RmCh = find(ismember({EEG.chanlocs.labels}, [string(EEG_Channels.notSourceLoc), "CZ"]));
    EEG = pop_select(EEG, 'nochannel', RmCh);
    
    
    %%% get trial information
    Info = split(Filename_Core, '_');
    Trials = Answers(strcmp(Answers.Participant, Info{1})& ...
        strcmp(Answers.Session, Info{3}), {'block', 'trial', 'level', 'response', 'probe', 'correct', 'missed'});
    
    
    %%% Epoch data
    
    % Encoding
    EEG_Epoch = pop_epoch(EEG, EEG_Triggers.Stim, [0 Window]-.1); % slight shift to make sure not in retention window
    Data = eeglab2fieldtrip(EEG_Epoch, 'raw', 'none');
    Data.trialinfo = [Data.trialinfo, Trials]; % update table of trial info
    save(fullfile(Destination_Core, 'Encoding', [Filename_Core, '_Encoding.mat']), 'Data', '-v7.3');
    
    % Retention1
    EEG_Epoch = pop_epoch(EEG, EEG_Triggers.Retent, [0 Window]);
    epoch_struct = EEG_Epoch; % hack for later
    Data = eeglab2fieldtrip(EEG_Epoch, 'raw', 'none');
    Data.trialinfo = [Data.trialinfo, Trials]; % update table of trial info
    save(fullfile(Destination_Core, 'Retention1', [Filename_Core, '_Retention1.mat']), 'Data', '-v7.3');
    
    % Retention2
    EEG_Epoch = pop_epoch(EEG, EEG_Triggers.Retent, [Window, Window*2]);
    epoch_struct.data = EEG_Epoch.data; % because window does not include trigger, I pretend the data has the same EEG struct as above
    EEG_Epoch = epoch_struct;
    Data = eeglab2fieldtrip(EEG_Epoch, 'raw', 'none');
    Data.trialinfo = [Data.trialinfo, Trials]; % update table of trial info
    save(fullfile(Destination_Core, 'Retention2', [Filename_Core, '_Retention2.mat']), 'Data', '-v7.3');
    
    % Probe
    EEG_Epoch = pop_epoch(EEG, EEG_Triggers.Probe, [0, Window]);
    Data = eeglab2fieldtrip(EEG_Epoch, 'raw', 'none');
    Data.trialinfo = [Data.trialinfo, Trials]; % update table of trial info
    save(fullfile(Destination_Core, 'Probe', [Filename_Core, '_Probe.mat']), 'Data', '-v7.3');
    
end