% Here is located all the common variables, paths, and parameters that get
% repeatedly called by more than one preprocessing script.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Locations

Paths = struct(); % I make structs of variables so they don't flood the workspace

% get path where these scripts were saved
Paths.Analysis = mfilename('fullpath');
Paths.Analysis = extractBefore(Paths.Analysis, 'Preprocessing');

 Core1 = 'G:\LSM\Data\';
 Core ='E:\Data\';
% if exist( 'D:\Data\Raw', 'dir')
%     Core = 'D:\Data\';
% elseif exist( 'F:\Data\Raw', 'dir')
%     Core = 'F:\Data\';
% elseif exist( 'E:\Data\Raw', 'dir')
%     Core = 'E:\Data\';
% elseif exist('D:\LSM\Data\Raw', 'dir')
%     Core = 'D:\LSM\Data\';
% else
%     error('no data disk!')
% end
Paths.Datasets = fullfile(Core1, 'Raw');
Paths.Preprocessed = fullfile(Core, 'Preprocessed');
Paths.Final = fullfile(Core, 'Final'); % where data gets saved once its been turned into something else

% add location of subfunctions
addpath(fullfile(Paths.Analysis, 'functions','general'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))
run(fullfile(Paths.Analysis, 'functions', 'external', 'addExternalFunctions'))

% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end

% Folders where raw data is located
Folders = struct();
Folders.Template = 'PXX';
Folders.Ignore = {'CSVs', 'other', 'Lazy', 'P00', 'Applicants'};

[Folders.Subfolders, Folders.Datasets] = AllFolderPaths(Paths.Datasets, ...
    Folders.Template, false, Folders.Ignore);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Variables

% EEG channels
EEG_Channels = struct();
EEG_Channels.notEEG = [49, 56, 107, 113, 126, 127];
EEG_Channels.notSourceLoc = [EEG_Channels.notEEG, 48, 119, 17];

allTasks = {'Fixation', 'Oddball', 'Standing', 'MWT', ...
    'Game', 'Match2Sample', 'PVT', 'LAT', 'SpFT', 'Music'}; % which tasks to convert (for now)
% allTasks = {'Fixation', 'Oddball', 'Standing', 'PVT', 'LAT'}; % which tasks to convert (for now)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

% Cleaning: data for quickly scanning data and selecting bad timepoints
Parameters.Cutting.fs = 125; % new sampling rate
Parameters.Cutting.lp = 40; % low pass filter
Parameters.Cutting.hp = 0.5; % high pass filter
Parameters.Cutting.hp_stopband = 0.25; % high pass filter gradual roll-off to this freuqency

% Power: starting data for properly cleaned wake data
Parameters.Power.fs = 250; % new sampling rate
Parameters.Power.lp = 40; % low pass filter
Parameters.Power.hp = 0.5; % high pass filter
Parameters.Power.hp_stopband = 0.25; % high pass filter gradual roll-off

% ICA: heavily filtered data for getting ICA components
Parameters.ICA.fs = 500; % new sampling rate
Parameters.ICA.lp = 100; % low pass filter
Parameters.ICA.hp = 2.5; % high pass filter
Parameters.ICA.hp_stopband = 1.5; % high pass filter gradual roll-off

% Scoring: has special script for running this
Parameters.Scoring.fs = 128;
Parameters.Scoring.SpChannel = 6;
Parameters.Scoring.lp = 40; % low pass filter
Parameters.Scoring.hp = .5; % high pass filter
Parameters.Scoring.hp_stopband = .2; % high pass filter gradual roll-off

% ERP: starting data for properly cleaned ERPs
Parameters.ERP.fs = 250; % new sampling rate
Parameters.ERP.lp = 40; % low pass filter
Parameters.ERP.hp = 0.1; % high pass filter
Parameters.ERP.hp_stopband = 0.05; % high pass filter gradual roll-off

Parameters.Microsleep.fs = 200; % new sampling rate
Parameters.Microsleep.lp = 70; % low pass filter
Parameters.Microsleep.hp = 0.3; % high pass filter
Parameters.Microsleep.hp_stopband = 0.1; % high pass filter gradual roll-off

% Waves: starting data for properly cleaned wake data
Parameters.Waves.fs = 1000; % new sampling rate
Parameters.Waves.lp = 40; % low pass filter
Parameters.Waves.hp = 0.5; % high pass filter
Parameters.Waves.hp_stopband = 0.25; % high pass filter gradual roll-off



% Trigger_Padding = 1; % amount of time in seconds to keep around start and stop triggers


