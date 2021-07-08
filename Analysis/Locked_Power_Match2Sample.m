% Calculates power for the different stages of the match2sample task
% trials. The mat file contains a Ch x Freq x Trial matrix for Baseline,
% Encoding, Retention, and Probe periods.


close all
clear
clc

Analysis_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Match2Sample';
WelchWindow = 2;
Freqs = 0.5:(1/WelchWindow):40;

% triggers
Trigger.Baseline.Trigger = 'S  3';
Trigger.Baseline.Window = [-2 0];

Trigger.Encoding.Trigger = 'S  3';
Trigger.Encoding.Window = [0 2];

Trigger.Retention.Trigger = 'S 10';
Trigger.Retention.Window = [0 2]; % could be as long as 4s

% todo:probe

Levels = 3;
Blocks = 4;
Trials = 10*Blocks*Levels;


% get files and paths
Source = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', 'New_Cuts', Task);
Destination = fullfile(Paths.Data, 'Locked', Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source)));
Files(~contains(Files, '.set')) = [];

for Indx_F = 1:numel(Files)
    
    File = Files{Indx_F};
    Filename_Core = extractBefore(File, '_Clean.set');
    Filename = [Filename_Core, '_Welch_Locked.mat'];
    
    % skip if already done
    if ~Refresh && exist(fullfile(Destination, Filename), 'file')
        disp(['**************already did ',Filename, '*************'])
        continue
    end
    
    % load EEG
    EEG = pop_loadset('filename', File, 'filepath', Source);
    
    
    %%% Set as nan all noise
    
    [Channels, Points] = size(EEG.data);
    fs = EEG.srate;
    Chanlocs = EEG.chanlocs;
    
    
    % set to nan all cut data
    Cuts_Filepath = fullfile(Source_Cuts, [Filename_Core, '_Cuts.mat']);
    
    EEG = nanNoise(EEG, Cuts_Filepath);
    
    
    %%% get power
    
    
    % epoch times
    AllTriggerTypes = {EEG.event.type};
    AllTriggerTimes =  [EEG.event.latency];
    EndBaselines =  AllTriggerTimes(strcmp(AllTriggerTypes, Trigger.Baseline.Trigger));
    StartRetentions =  AllTriggerTimes(strcmp(AllTriggerTypes, Trigger.Retention.Trigger));
    StartBaselines = EndBaselines - round(Trigger.Baseline.Window*fs);
    EndRetentions = StartRetentions + round(Trigger.Retention.Window*fs);
    
    
    if Trials ~= numel(EndBaselines) || size(Trials, 1) ~= numel(StartRetentions)
        warning(['Something went wrong with triggers for ', EEG_Filename])
        continue
    end
    
    Retention = PowerTrials(EEG, Freqs, StartRetentions, EndRetentions);
    Baseline = PowerTrials(EEG, Freqs, StartBaselines, EndBaselines);
    Encoding = PowerTrials(EEG, Freqs, EndBaselines, StartRetentions);
    
    % TODO: get trial information
    % TODO: run for probe
    
    % save
    save(fname, 'Baseline', 'Encoding', 'Retention',  'Freqs', 'Chanlocs', 'Trials')
    disp(['*************finished ',Filename '*************'])
end
