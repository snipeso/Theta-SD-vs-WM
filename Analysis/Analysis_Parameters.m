% Here is located all the common variables, paths, and parameters that get
% repeatedly called by more than one preprocessing script.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Universal parameters

Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', ...
    'P09', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17', 'P19'};

AllTasks = {'Match2Sample', 'LAT', 'PVT', 'SpFT', 'Game', 'Music', 'Fixation'};
TaskLabels = {'STM', 'LAT', 'PVT', 'Speech', 'Game', 'Music', 'Rest'};
% 
% AllTasks = {'Match2Sample', 'LAT', 'PVT', 'SpFT', 'Game', 'Music', 'Standing', 'Oddball', 'Fixation'};
% TaskLabels = {'STM', 'LAT', 'PVT', 'Speech', 'Game', 'Music', 'EC', 'Oddball', 'EO'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Locations

Core = 'D:\Data\';
Paths.Preprocessed = fullfile(Core, 'Preprocessed'); % where the preprocessed data gets saved (split by task)
Paths.Datasets = 'G:\LSM\Data\Raw'; 
Paths.Data  = fullfile(Core, 'Final'); % where data gets saved once its been turned into something else
Paths.Results = fullfile(Core, 'Results', 'Theta-SD-vs-WM'); % where figures and tables end up

% get path where these scripts were saved
Paths.Analysis = mfilename('fullpath');
Paths.Analysis = fullfile(extractBefore(Paths.Analysis, 'Analysis'));

% add location of subfunctions
addpath(fullfile(Paths.Analysis, 'functions','general'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))
addpath(fullfile(Paths.Analysis, 'functions','plots'))
addpath(fullfile(Paths.Analysis, 'functions','tasks'))
run(fullfile(Paths.Analysis, 'functions', 'external', 'addExternalFunctions'))


% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plotting settings

Format = struct();

Format.FontName = 'Tw Cen MT'; % use something else for papers
Format.TopoRes = 300;

Format.Colormap.Linear = flip(colorcet('L17'));
Keep = round(linspace(1, size(Format.Colormap.Linear, 1), 20));
Format.Colormap.Linear = Format.Colormap.Linear(Keep, :);

Format.Colormap.Divergent = colorcet('D1');
Keep = round(linspace(1, size(Format.Colormap.Divergent, 1), 20));
Format.Colormap.Divergent = Format.Colormap.Divergent(Keep, :);


Format.Colormap.Rainbow = unirainbow;

Format.Colors.Participants = Format.Colormap.Rainbow(floor(linspace(1, ...
    size(Format.Colormap.Rainbow, 1), numel(Participants))), :);
Format.Alpha.Participants = .3;

Bands.Delta = [1 4];
Bands.Theta = [4 8];
Bands.Alpha = [8 12];
Bands.Beta = [15 25];

Channels = struct();
Channels.Sample = [11, 129, 52, 70, 96];
Channels.Sample_Titles = {'Fz', 'Cz', 'P3', 'O1', 'T6'};

Channels.Peaks.fm = [11 12 5 6];
Channels.Peaks.ftl = [44 43 38];
Channels.Peaks.ftr = [114 120 121];
Channels.Peaks.ocm = [71 76 75];
Channels.Peaks.otl = [57 58 65];
Channels.Peaks.otr = [90 96 100];
Channels.Troughs.cl = [41 40 35 34];
Channels.Troughs.cr = [103 109 110 116];
Channels.Troughs.om = [74 82 81];

Channels.Hotspot = [2:6, 9:13, 15, 16, 18:20, 23, 24, 26:29, 111, 112, 117, 118, 123, 124];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Labels

Sessions.Match2Sample = {'Baseline', 'Session1', 'Session2'};
Sessions.LAT = {'BaselineComp', 'Session1Comp', 'Session2Comp'};
Sessions.PVT = {'BaselineComp', 'Session1Comp', 'Session2Comp'};
Sessions.SpFT = {'Baseline', 'Session1', 'Session2'};
Sessions.Game = {'Baseline', 'Session1', 'Session2'};
Sessions.Music = {'Baseline', 'Session1', 'Session2'};
Sessions.Fixation = {'BaselinePost', 'Main3', 'Main7'};
Sessions.Standing = {'BaselinePost', 'Main3', 'Main7'};
Sessions.Oddball = {'BaselinePost', 'Main3', 'Main7'};
Sessions.Labels = {'BL', 'SR', 'SD'};