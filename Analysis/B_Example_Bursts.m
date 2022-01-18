% example data used in paper

clear
clc
close all

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Format = P.Format;
Pixels = P.Pixels;

% preselected snippets of data with good examples of theta bursts
Coordinates = {
        'P10_Game_Baseline_Clean.set', 280, 6,  Format.Colors.Tasks.Game;
    'P10_Game_Session2_Clean.set', 581, 6, Format.Colors.Tasks.Game;
    'P10_LAT_BaselineComp_Clean.set', 536.2, 118, Format.Colors.Tasks.LAT;
    'P10_LAT_Session2Comp_Clean.set', 244, 118,  Format.Colors.Tasks.LAT;
    };

Titles = { 'Baseline Game', 'Sleep Deprivation Game', 'Baseline LAT', 'Sleep Deprivation LAT',};

Results = fullfile(Paths.Results, 'Bursts', 'Final');
if ~exist(Results, 'dir')
    mkdir(Results)
end

% load all EEGs
for Indx_E = 1:size(Coordinates, 1)
    
    Filename = Coordinates{Indx_E, 1};
    Levels = split(Filename, '_');
    Task = Levels{2};
    Participant = Levels{1};
    
    TitleTag = strjoin({'Burst', Participant, Task, Levels{3}}, '_');
    Source = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task);
    
    AllEEG(Indx_E) = pop_loadset('filename', Filename, 'filepath', Source);
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper figure

Pixels.PaddingExterior = 30;

Log = true; % whether to plot on log scale or not
figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.5])

B.Theta = Bands.Theta;

Grid = [2 2];

CornerLocations = [
    1, 1;
    1, 2;
    2, 1;
    2, 2
    ];

ProtoChannel = unique([Coordinates{:, 3}]);
for Indx_E = 1:size(Coordinates, 1)
    Start = Coordinates{Indx_E, 2};
    Stop = Start + 2;

    % make subplots
    Space = subaxis(Grid, CornerLocations(Indx_E, :), [], Pixels.Letters{Indx_E}, Pixels);
        Title = text(.5, 1, Titles{Indx_E}, 'FontSize', Pixels.TitleSize, 'FontName', Format.FontName, ...
        'FontWeight', 'Bold', 'HorizontalAlignment', 'Center');
    
    plotBurstFig(AllEEG(Indx_E), Start, Stop, Coordinates{Indx_E, 3}, B, Space, Log,  Coordinates{Indx_E, 4}, Pixels);
    
    Axis.Units = 'normalized';
    Title.Units = 'normalized';
end

saveFig('ExampleTheta', Paths.Paper, Format)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


