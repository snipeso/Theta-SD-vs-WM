function P = analysisParameters()
% Here is located all the common variables, paths, and parameters that get
% repeatedly called by more than one preprocessing script.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Labels

P.Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', ...
    'P09', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17', 'P19'};

P.AllTasks = {'Match2Sample', 'LAT', 'PVT', 'SpFT', 'Game', 'Music'};
P.TaskLabels = {'STM', 'LAT', 'PVT', 'Speech', 'Game', 'Music'};

% Task labels for each session; different because of PVT and LAT
Sessions.Match2Sample = {'Baseline', 'Session1', 'Session2'};
Sessions.LAT = {'BaselineComp', 'Session1Comp', 'Session2Comp'};
Sessions.PVT = {'BaselineComp', 'Session1Comp', 'Session2Comp'};
Sessions.SpFT = {'Baseline', 'Session1', 'Session2'};
Sessions.Game = {'Baseline', 'Session1', 'Session2'};
Sessions.Music = {'Baseline', 'Session1', 'Session2'};
Sessions.Labels = {'BL', 'SR', 'SD'};
P.Sessions = Sessions;

P.Nights = {'Baseline', 'NightPre', 'NightPost'};


Labels.logBands = [1 2 4 8 16 32]; % x markers for plot on log scale
Labels.Bands = [1 4 8 15 25 35 40]; % normal scale
Labels.FreqLimits = [1 40];
Labels.zPower = 'PSD z-scored';
Labels.Power = 'PSD Amplitude (\muV^2/Hz)';
Labels.Frequency = 'Frequency (Hz)';
Labels.Epochs = {'Encoding', 'Retention1', 'Retention2', 'Probe'}; % for M2S task
Labels.Amplitude = 'Amplitude (\muV)';
Labels.Time = 'Time (s)';
Labels.ES = "Hedge's G";
Labels.t = 't-values';
Labels.r = 'r-values';
Labels.Correct = '% Correct';
Labels.RT = 'RT (s)';
P.Labels = Labels;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Locations

% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end

% same for plotting scripts, saved to a different repo (https://github.com/snipeso/chart)
if ~exist('addchARTpaths.m', 'file')
    addpath('C:\Users\colas\Projects\chART')
    addchARTpaths()
end

if ~exist('ft_sourceinterpolate', 'file')
    addpath('C:\Users\colas\Documents\MATLAB\fieldtrip-20210606')
    addpath('C:\Users\colas\Documents\MATLAB\fieldtrip-20210606\plotting\private')
end

if exist( 'D:\Data\Raw', 'dir')
    Core = 'D:\Data\';
elseif exist( 'F:\Data\Raw', 'dir')
    Core = 'F:\Data\';
elseif exist( 'E:\Data\Raw', 'dir')
    Core = 'E:\Data\';
else
    error('no data disk!')
end

Paths.Preprocessed = fullfile(Core, 'Preprocessed');


Paths.Datasets = 'G:\LSM\Data\Raw';
Paths.Data  = fullfile(Core, 'Final'); % where data gets saved once its been turned into something else
Paths.PaperResults = fullfile(Core, 'Results', 'Theta-SD-vs-WM'); % where figures and tables end up
Paths.Paper = 'C:\Users\colas\Dropbox\Research\Publications and Presentations\Sleep\Paper1\Figures';
Paths.Poster = 'C:\Users\colas\Dropbox\Research\Publications and Presentations\Sleep\Gordon2022\Figures';
Paths.Powerpoint = 'C:\Users\colas\Dropbox\Research\Projects\HuberSleepLab\LSM\Repeat Figures\MatlabFigures';
Paths.PaperStats =  'C:\Users\colas\Dropbox\Research\Publications and Presentations\Sleep\Paper1\Stats';
Paths.Scoring = fullfile(Core, 'Scoring');
Paths.Results = fullfile(Core, 'Results\Theta-SD-vs-WM');

% get path where these scripts were saved
Paths.Analysis = mfilename('fullpath');
Paths.Analysis = fullfile(extractBefore(Paths.Analysis, '\Analysis\'));

% add location of subfunctions
addpath(fullfile(Paths.Analysis, 'functions','general'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))
addpath(fullfile(Paths.Analysis, 'functions','plots'))
addpath(fullfile(Paths.Analysis, 'functions','tasks'))
addpath(fullfile(Paths.Analysis, 'functions','stats'))
addpath(fullfile(Paths.Analysis, 'functions','source_localization'))
addpath(fullfile(Paths.Analysis, 'functions','questionnaires'))
run(fullfile(Paths.Analysis, 'functions', 'external', 'addExternalFunctions'))


P.Paths = Paths;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plotting settings
% These use chART (https://github.com/snipeso/chART) plots. Each figure
% takes a struct that holds all the parameters for plotting (e.g. font
% names, sizes, etc). These are premade in chART, but can be customized.


% plot sizes depending on which screen being used
Pix = get(0,'screensize');
if Pix(3) < 2000
    Format = getProperties({'LSM', 'SmallScreen'});
else
    Format = getProperties({'LSM', 'LargeScreen'});
end

Manuscript = getProperties({'LSM', 'Manuscript'});
Powerpoint =  getProperties({'LSM', 'Powerpoint'});
Poster =  getProperties({'LSM', 'Poster'});

% journal specific page sizes
Manuscript.Figure.W1 = 8.5; % one column
Manuscript.Figure.W2 = 11.6; % column and a half
Manuscript.Figure.W3 = 17.6;
Manuscript.Figure.Height = 25;

P.Manuscript = Manuscript; % for papers
P.Powerpoint = Powerpoint; % for presentations
P.Poster = Poster;
P.Format = Format; % plots just to view data


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Power/EEG information

Bands.Delta = [1 4];
Bands.Theta = [4 8];
Bands.Alpha = [8 12];
Bands.Beta = [15 25];
Bands.Gamma = [25 35];

%%% Channels and Regions of Interest (ROI)
Channels = struct();

Channels.Remove = [17, 48, 119]; % channels to remove before FFT

% ROIs selected independently of data
Frontspot = [22 15 9 23 18 16 10 3 24 19 11 4 124 20 12 5 118 13 6 112];
Backspot = [66 71 76 84 65 70 75 83 90 69 74 82 89];
Centerspot = [129 7 106 80 55 31 30 37 54 79 87 105 36 42 53 61 62 78 86 93 104 35 41 47  52 92 98 103 110, 60 85 51 97];

Channels.preROI.Front = Frontspot;
Channels.preROI.Center = Centerspot;
Channels.preROI.Back = Backspot;

Format.Colors.preROI = getColors(numel(fieldnames(Channels.preROI)));

% small ROIs based on data
Channels.Peaks.Frontspot = [11 12 5 6]; % frontal midline
Channels.Peaks.Extrafront = [18 16 10 15];
Channels.Peaks.LeftWing = [44 43 38 39]; % fronto-temporal left
Channels.Peaks.RightWing = [114 120 121 115]; % fronto-temporal right
Channels.Peaks.BackSpot = [71 76 75 70 83]; % occipital-central midline
Channels.Peaks.LeftTail = [58 50 64 65 66]; % occipital-temporal left
Channels.Peaks.RightTail = [96 101 95 90 84];
Channels.Peaks.LeftDip = [31 54 30 37 53 36 42]; % center left
Channels.Peaks.RightDip = [103 109 110 116];

% ROI channels based on 10-20 system, pooled
Channels.Standard.F = [11, 6, 5, 12];
Channels.Standard.O = [70 83];
Channels.Standard.P = [58 52 92 96];
Channels.Standard.C = [36 104 129];
Channels.Standard.T = [45 108];
Format.Colors.Standard = getColors(5);

% % 10-20 ROIs
% Channels.Standard_10_20.Fz = 11;
% Channels.Standard_10_20.Fp1 = 22;
% Channels.Standard_10_20.Fp2 = 9;
% Channels.Standard_10_20.F3 = 24;
% Channels.Standard_10_20.F4 = 124;
% Channels.Standard_10_20.F7 = 33;
% Channels.Standard_10_20.F8 = 122;
% Channels.Standard_10_20.Cz = 129; % TEMP
% Channels.Standard_10_20.C3 = 36;
% Channels.Standard_10_20.C4 = 104;
% Channels.Standard_10_20.T7 = 45;
% Channels.Standard_10_20.T8 = 108;
% Channels.Standard_10_20.Pz = 62;
% Channels.Standard_10_20.P3 = 52;
% Channels.Standard_10_20.P4 = 92;
% Channels.Standard_10_20.P7 = 58;
% Channels.Standard_10_20.P8 = 96;
% Channels.Standard_10_20.Oz = 75;
% Channels.Standard_10_20.O1 = 70;
% Channels.Standard_10_20.O2 = 83;
% 
% Titles = fieldnames(Channels.Standard_10_20);
% Channels.Standard_10_20_All = {};
% for Indx = 1:numel(Titles)
%     Channels.Standard_10_20_All{Indx, 2} = Channels.Standard_10_20.(Titles{Indx});
%     Channels.Standard_10_20_All{Indx, 1} = Titles{Indx};
% end

P.Channels = Channels;
P.Bands = Bands;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Stats parameters

StatsP = struct();

StatsP.ANOVA.ES = 'eta2';
StatsP.ANOVA.ES_lims = [0 1];
StatsP.ANOVA.nBoot = 2000;
StatsP.ANOVA.pValue = 'pValueGG';
StatsP.ttest.nBoot = 2000;
StatsP.ttest.dep = 'pdep'; % use 'dep' for ERPs, pdep for power
StatsP.Alpha = .05;
StatsP.Trend = .1;
StatsP.Paired.ES = 'hedgesg';
StatsP.Paired.Benchmarks = -2:.5:2;
StatsP.Correlation = 'Spearman';
StatsP.FreqBin = 1; % # of frequencies to bool in spectrums stats
StatsP.minProminence = .1; % minimum prominence for when finding clusters of g values
P.StatsP = StatsP;


