function P = spft_Parameters()

% Here is located all the common variables, paths, and parameters that get
% repeatedly called by more than one preprocessing script.


P.Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', ...
    'P09', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17', 'P19'};

P.Sessions = {'Baseline', 'Session1', 'Session2'};

Paths.Datasets = 'G:\LSM\Data\Raw'; 
% Paths.Datasets = 'F:\Data\Raw\';
Core = 'F:\Data\';

Paths.Preprocessed = fullfile(Core, 'Preprocessed'); % where the preprocessed data gets saved (split by task)
Paths.Data  = fullfile(Core, 'Final'); % where data gets saved once its been turned into something else
Paths.Scoring = 'C:\Users\colas\Desktop\';

% get path where these scripts were saved
Paths.Analysis = mfilename('fullpath');
Paths.Analysis = fullfile(extractBefore(Paths.Analysis, 'SpfT_Scoring'));

addpath(fullfile(Paths.Analysis, 'functions','tasks'))

P.Paths = Paths;

P.nTrials = 20;