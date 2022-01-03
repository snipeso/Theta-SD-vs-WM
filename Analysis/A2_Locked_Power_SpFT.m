% calculates power for the different epochs of the speech task (reading vs
% speaking). This is mostly a quality check on whether speech artifacts are
% still present, but also in the off chance there's a difference, would be
% cool.
clear
clc
close all

P = analysisParameters();
Paths = P.Paths;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'SpFT';
WelchWindow = 2;

% triggers
Stim_Trig = {'S  3'};
Resp_Trig =  {'S  4'};
Start_Trig = {'S 10'};
End_Trig =  {'S 11'};

TotTrials = 20;

% get files and paths
Source = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', 'Cuts', Task);
Source_Tables = fullfile(Paths.Data, 'Behavior');
Destination = fullfile(Paths.Data, 'EEG', 'Locked', Task, ['w', num2str(WelchWindow)]);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

% get trial information
Answers_Path = fullfile(Source_Tables, [Task, '_AllAnswers.mat']);
if  ~Refresh &&  exist(Answers_Path, 'file')
    load(Answers_Path, 'Answers')
else
    error('Missing AllAnswers.mat file. To get it, run scripts inside /SpFT_Scoring/')
    
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
    
        
    % get trial information
    Info = split(Filename_Core, '_');
    Trials = Answers(strcmp(Answers.Participant, Info{1})& ...
        strcmp(Answers.Session, Info{3}), :);
    
    if size(Trials, 1) ~= TotTrials
        warning(['Something went wrong with trials for ', Filename])
        continue
    end
    
    % sort trials
    Trials = sortrows(Trials, 'Trial');
    
    % load EEG
    EEG = pop_loadset('filename', File, 'filepath', Source);
    
    
    %%% Set as nan all noise
    [Channels, Points] = size(EEG.data);
    fs = EEG.srate;
    
    
    % set to nan all cut data
    Cuts_Filepath = fullfile(Source_Cuts, [Filename_Core, '_Cuts.mat']);
    EEG = nanNoise(EEG, Cuts_Filepath);
    
    % remove nonEEG channels
    EEG = pop_select(EEG, 'nochannel', labels2indexes(P.Channels.Remove, EEG.chanlocs));
    
    Chanlocs = EEG.chanlocs;
    
    %%% get power
    
    % epoch trials
    AllTriggerTypes = {EEG.event.type};
    AllTriggerTimes =  [EEG.event.latency];
    
    nfft = 2^nextpow2(WelchWindow*fs);
    
    StartReading =  AllTriggerTimes(ismember(AllTriggerTypes, Stim_Trig));
    EndReading =  AllTriggerTimes(ismember(AllTriggerTypes, Resp_Trig));
    
        StartSpeaking =  AllTriggerTimes(ismember(AllTriggerTypes, Start_Trig));
    EndSpeaking =  AllTriggerTimes(ismember(AllTriggerTypes, End_Trig));
    
    if TotTrials ~= numel(StartReading) || TotTrials ~= numel(EndReading) || TotTrials ~= numel(StartSpeaking) || TotTrials ~= numel(EndSpeaking) 
        warning(['Something went wrong with triggers for ', File])
        continue
    end
    
    Reading = PowerTrials(EEG, StartReading, EndReading, WelchWindow);
    [Speaking, Freqs] = PowerTrials(EEG, StartSpeaking, EndSpeaking, WelchWindow);
    
    Power = cat(4, Reading, Speaking);
    Power = permute(Power, [3, 4, 1, 2]); % data saved as trial x epoch x ch x freq

    
    % get reading times from triggers
    Trials.RT = (EndReading' - StartReading')/fs;
    
    
    % save
    save(fullfile(Destination, Filename), 'Power', 'Freqs', 'Chanlocs', 'Trials')
    disp(['*************finished ',Filename '*************'])
end

