function P = analysisParameters()

% Here is located all the common variables, paths, and parameters that get
% repeatedly called by more than one preprocessing script.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Universal parameters

P.Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', ...
    'P09', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17', 'P19'};

P.AllTasks = {'Match2Sample', 'LAT', 'PVT', 'SpFT', 'Game', 'Music', 'Fixation'};
P.TaskLabels = {'STM', 'LAT', 'PVT', 'Speech', 'Game', 'Music', 'Rest'};
% 
% P.AllTasks = {'Match2Sample', 'LAT', 'PVT', 'SpFT', 'Game', 'Music', 'Standing', 'Oddball', 'Fixation'};
% P.TaskLabels = {'STM', 'LAT', 'PVT', 'Speech', 'Game', 'Music', 'EC', 'Oddball', 'EO'};

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
addpath(fullfile(Paths.Analysis, 'functions','stats'))
run(fullfile(Paths.Analysis, 'functions', 'external', 'addExternalFunctions'))


% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end

P.Paths = Paths;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plotting settings

Format = struct();

Format.FontName = 'Tw Cen MT'; % use something else for papers
Format.TopoRes = 300;


Linear = flip(colorcet('L17'));
Format.Colormap.Linear = reduxColormap(Linear, 20);

Monochrome = colorcet('L1');
Format.Colormap.Monochrome = reduxColormap(Monochrome, 20);

Divergent = colorcet('D1');
Format.Colormap.Divergent = reduxColormap(Divergent, 20);

Rainbow = unirainbow;
Format.Colormap.Rainbow = Rainbow;
Format.Colors.Participants = reduxColormap(Rainbow, numel(P.Participants));

Format.Alpha.Participants = .3;

% basic colors for simple plots
Format.Colors.Dark1 = [99 88 226]/255; % fixation purple
Format.Colors.Red = [228, 104, 90]/255; % M2S red
Format.Colors.Light1 = [244, 204, 32]/255; % PVT yellow

Format.Colors.Tasks.PVT = [244, 204, 32]/255;
Format.Colors.Tasks.LAT = [246, 162, 75]/255;
Format.Colors.Tasks.Match2Sample = [228, 104, 90]/255;

Format.Colors.Tasks.SpFT = [185, 204, 38]/255;
Format.Colors.Tasks.Game = [44, 190, 107]/255;
Format.Colors.Tasks.Music = [22, 144, 167]/255;

Format.Colors.Tasks.Oddball = [222, 122, 184]/255;
Format.Colors.Tasks.Fixation = [172, 86, 224]/255;
Format.Colors.Tasks.Standing = [99, 88, 226]/255;

Format.Colors.SigStar = [0 0 0];

Format.Colors.AllTasks = nan(numel(P.AllTasks), 3);
for Indx_T = 1:numel(P.AllTasks)
    Format.Colors.AllTasks(Indx_T, :) = Format.Colors.Tasks.(P.AllTasks{Indx_T});
end

Bands.Delta = [1 4];
Bands.Theta = [4 8];
Bands.Alpha = [8 12];
Bands.Beta = [15 25];
Bands.Gamma = [25 35];

Format.Labels.Bands = [1 4 8 15 25 35 40];

Channels = struct();
Channels.Sample = [11, 129, 52, 70, 96];
Channels.Sample_Titles = {'Fz', 'Cz', 'P3', 'O1', 'T6'};

Channels.Peaks.Frontspot = [11 12 5 6]; % frontal midline
Channels.Peaks.Extrafront = [18 16 10 15];
Channels.Peaks.LeftWing = [44 43 38]; % fronto-temporal left
% Channels.Peaks.RightWing = [114 120 121]; % fronto-temporal right
Channels.Peaks.BackSpot = [71 76 75]; % occipital-central midline
Channels.Peaks.LeftTail = [57 58 65 64]; % occipital-temporal left
% Channels.Peaks.RightTail = [90 96 100];
Channels.Peaks.LeftDip = [41 40 35 34]; % center left
% Channels.Peaks.RightDip = [103 109 110 116];


Channels.Frontspot = [22 15 9 23 18 16 10 3 24 19 11 4 124 20 12 5 118 13 6 112];

P.Format = Format;
P.Channels = Channels;
P.Bands = Bands;

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

P.Sessions = Sessions;
