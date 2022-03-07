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
%%% Paper Figure EXAZ

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
%%% Presentation

%% 
% preselected snippets of data with good examples of theta bursts
Coordinates = {
    'EO.set', 308.3, 22, Format.Colors.Tasks.PVT, 'Beta';
    'EC2.set', 324, 90,  Format.Colors.Tasks.Match2Sample, 'Alpha';
    'fmTheta.set', 581.3, 6,  Format.Colors.Tasks.Music, 'Theta';
    'N3_clean.set', 343.15, 11, Format.Colors.Tasks.Game, 'Delta';
    };

Results = fullfile(Paths.Results, 'Bursts', 'Presentation');
if ~exist(Results, 'dir')
    mkdir(Results)
end

% load all EEGs
for Indx_E = 1:size(Coordinates, 1)
    
    Filename = Coordinates{Indx_E, 1};
    EEG = pop_loadset('filename', Filename, 'filepath', Path);
    try
        AllEEG(Indx_E) = EEG;
    catch
        AllEEG(Indx_E).data = EEG.data;
        AllEEG(Indx_E).chanlocs = EEG.chanlocs;
        AllEEG(Indx_E).srate = EEG.srate;
    end
end



%%
YLims = [-160 110];

for Indx_B = 1:size(Coordinates, 1)
    Fig = figure('units','centimeters','position',[0 0 30 10]);
    
    Start = Coordinates{Indx_B, 2};
    plotWaves(AllEEG(Indx_B), Start, Start+2, Coordinates{Indx_B, 3}, ...
        Coordinates{Indx_B, 4}, Format);
    ylim(YLims)
    
    saveFig(Coordinates{Indx_B, end}, Results, Format)
    
end
