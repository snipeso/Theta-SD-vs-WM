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
TotTrials = 10*Blocks*Levels;


% get files and paths
Source = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', 'New_Cuts', Task);
Source_Tables = fullfile(Paths.Data, 'Behavior');
Destination = fullfile(Paths.Data, 'EEG', ['Locked_', num2str(Window)], Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end


% get trial information
% get response times
Answers_Path = fullfile(Source_Tables, [Task, '_AllAnswers.mat']);
if  ~Refresh &&  exist(Answers_Path, 'file')
    load(Answers_Path, 'Answers')
else
    if ~exist(Source_Tables, 'dir')
        mkdir(Source_Tables)
    end
    
    AllAnswers = importTask(Paths.Datasets, Task, Source_Tables); % needs to have access to raw data folder
    Answers = cleanupMatch2Sample(AllAnswers);
    
    save(Answers_Path, 'Answers');
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
    StartBaselines = EndBaselines - round(WelchWindow*fs);
    EndRetentions = StartRetentions + round(WelchWindow*fs);
    
    
    if TotTrials ~= numel(EndBaselines) || TotTrials ~= numel(StartRetentions)
        warning(['Something went wrong with triggers for ', EEG_Filename])
        continue
    end
    
    Retention = PowerTrials(EEG, Freqs, StartRetentions, EndRetentions, WelchWindow);
    Baseline = PowerTrials(EEG, Freqs, StartBaselines, EndBaselines, WelchWindow);
    Encoding = PowerTrials(EEG, Freqs, EndBaselines, StartRetentions, WelchWindow);
    
    
    % TODO: run for probe
    
    % get trial information
    Info = split(Filename_Core, '_');
    Trials = Answers(strcmp(Answers.Participant, Info{1})& ...
        strcmp(Answers.Session, Info{3}), :);
    
    if size(Trials, 1) ~= numel(EndBaselines) || size(Trials, 1) ~= numel(StartRetentions)
        warning(['Something went wrong with triggers for ', EEG_Filename])
        continue
    end
    
    
    % save
    save(fullfile(Destination, Filename), 'Baseline', 'Encoding', 'Retention',  'Freqs', 'Chanlocs', 'Trials')
    disp(['*************finished ',Filename '*************'])
end
