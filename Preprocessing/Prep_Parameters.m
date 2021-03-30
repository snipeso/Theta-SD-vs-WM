% Here is located all the common variables, paths, and parameters that get
% repeatedly called by more than one preprocessing script.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Locations
Paths = struct(); % I make structs of variables so they don't flood the workspace

% get path where these scripts were saved
Paths.Analysis = mfilename('fullpath');
Paths.Analysis = extractBefore(Paths.Analysis, 'General_Parameters');

Paths.Datasets ='D:\LSM\Raw'; % where the raw data is saved (split by participant)
Paths.Preprocessed = 'D:\LSM\Preprocessed'; % where the preprocessed data gets saved (split by task)

% Folders where raw data is located
Folders = struct();
Folders.Template = 'PXX';
Folders.Ignore = {'CSVs', 'other', 'Lazy', 'P00', 'Applicants'};

[Folders.Subfolders, Folders.Datasets] = AllFolderPaths(Paths.Datasets, ...
    Folders.Template, false, Folders.Ignore);


% add location of subfunctions
addpath(fullfile(Paths.Analysis, 'functions','general'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))

% add external functions
run(fullfile(Paths.Analysis, 'functions', 'external', 'addExternalFunctions'))

% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Variables

% EEG channels
EEG_Channels = struct();
EEG_Channels.notEEG = [49, 56, 107, 113, 126, 127];
EEG_Channels.notSourceLoc = [EEG_Channels.notEEG, 48, 119, 125, 128];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

% Cleaning: data for quickly scanning data and selecting bad timepoints
Parameters(2).Format = 'Cleaning'; % reference name
Parameters(2).fs = 125; % new sampling rate
Parameters(2).lp = 40; % low pass filter
Parameters(2).hp = 0.5; % high pass filter
Parameters(2).hp_stopband = 0.25; % high pass filter

% Wake: starting data for properly cleaned wake data
Parameters(3).Format = 'Wake'; % reference name
Parameters(3).fs = 500; % new sampling rate
Parameters(3).lp = 40; % low pass filter
Parameters(3).hp = 0.5; % high pass filter
Parameters(3).hp_stopband = 0.25; % high pass filter


% ICA: heavily filtered data for getting ICA components
Parameters(4).Format = 'ICA'; % reference name
Parameters(4).fs = 500; % new sampling rate
Parameters(4).lp = 100; % low pass filter
Parameters(4).hp = 2.5; % high pass filter
Parameters(4).hp_stopband = .5; % high pass filter

% Scoring: has special script for running this
Parameters(5).Format = 'Scoring';
Parameters(5).fs = 128;
Parameters(5).SpChannel = 6;
Parameters(5).lp = 40; % low pass filter
Parameters(5).hp = .5; % high pass filter
Parameters(5).hp_stopband = .2; % high pass filter

% Wake: starting data for properly cleaned wake data
Parameters(6).Format = 'ERP'; % reference name
Parameters(6).fs = 500; % new sampling rate
Parameters(6).lp = 40; % low pass filter
Parameters(6).hp = 0.1; % high pass filter
Parameters(6).hp_stopband = 0.05; % high pass filter

% Trigger_Padding = 1; % amount of time in seconds to keep around start and stop triggers
