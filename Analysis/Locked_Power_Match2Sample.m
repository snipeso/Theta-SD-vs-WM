% Calculates power for the different stages of the match2sample task
% trials. The mat file contains a Ch x Freq x Trial matrix for Baseline,
% Encoding, Retention, and Probe periods.
close all
clear
clc


P = analysisParameters();
Paths = P.Paths;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Match2Sample';
WelchWindow = 2;

% triggers
Stim_Trig = {'S  3'};
Retention_Trig = {'S 10'};
Probe_Trig = { 'S 11',  'S 12'}; % match and not match probe

Levels = 3;
Blocks = 4;
TotTrials = 10*Blocks*Levels;


% get files and paths
Source = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', 'New_Cuts', Task);
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
    
    % epoch trials
    AllTriggerTypes = {EEG.event.type};
    AllTriggerTimes =  [EEG.event.latency];
    
    nfft = 2^nextpow2(WelchWindow*fs);
    
    EndBaselines =  AllTriggerTimes(ismember(AllTriggerTypes, Stim_Trig));
    StartBaselines = EndBaselines - nfft;
    
    StartRetentions =  AllTriggerTimes(ismember(AllTriggerTypes, Retention_Trig));
    MidRetentions = StartRetentions + nfft;
    EndRetentions = MidRetentions +  nfft;
    
    ProbeIndx = find(ismember(AllTriggerTypes, Probe_Trig));
    StartProbes =  AllTriggerTimes(ProbeIndx);
    EndProbes = StartProbes + nfft;
    
    
    if TotTrials ~= numel(EndBaselines) || TotTrials ~= numel(StartRetentions) || TotTrials ~= numel(StartProbes)
        warning(['Something went wrong with triggers for ', EEG_Filename])
        continue
    end
    
    Baseline = PowerTrials(EEG, StartBaselines, EndBaselines, WelchWindow);
    Encoding = PowerTrials(EEG, EndBaselines, StartRetentions, WelchWindow);
    Retention1 = PowerTrials(EEG, StartRetentions, MidRetentions, WelchWindow);
    Retention2 = PowerTrials(EEG, MidRetentions, EndRetentions, WelchWindow);
    [Probe, Freqs] = PowerTrials(EEG, StartProbes, EndProbes, WelchWindow);
    
    Power = cat(4, Baseline, Encoding, Retention1, Retention2, Probe);
    Power = permute(Power, [3, 4, 1, 2]); % data saved as trial x epoch x ch x freq
    

    % get trial information
    Info = split(Filename_Core, '_');
    Trials = Answers(strcmp(Answers.Participant, Info{1})& ...
        strcmp(Answers.Session, Info{3}), :);
    
    if size(Trials, 1) ~= numel(EndBaselines) || size(Trials, 1) ~= numel(StartRetentions)
        warning(['Something went wrong with trials for ', EEG_Filename])
        continue
    end
    
    % get reaction times from triggers
    RTs = nan(TotTrials, 1);
    for Indx_T = 1:TotTrials
        if Trials.missed(Indx_T)
            continue
        else 
            RTs(Indx_T) = abs(diff(AllTriggerTimes([ProbeIndx(Indx_T), ProbeIndx(Indx_T)+1]))/fs);
        end
    end
    Trials.RT = RTs;
    
    
    % save
    save(fullfile(Destination, Filename), 'Power', 'Freqs', 'Chanlocs', 'Trials')
    disp(['*************finished ',Filename '*************'])
end
