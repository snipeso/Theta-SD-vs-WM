% example data used in paper

clear
clc
close all

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
PlotProps = P.Manuscript;
Labels = P.Labels;

% preselected snippets of data with good examples of theta bursts
Coordinates = {
        'P10_Game_Baseline_Clean.set', 280, 6,  PlotProps.Color.Tasks.Game;
    'P10_Game_Session2_Clean.set', 581, 6, PlotProps.Color.Tasks.Game;
    'P10_LAT_BaselineComp_Clean.set', 536.2, 118, PlotProps.Color.Tasks.LAT;
    'P10_LAT_Session2Comp_Clean.set', 244, 118,  PlotProps.Color.Tasks.LAT;
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
PlotProps = P.Manuscript;
PlotProps.Axes.yPadding = 40;
PlotProps.Axes.xPadding = 30;
PlotProps.Axes.labelPadding = 45;
Log = true; % whether to plot on log scale or not
figure('units','centimeters','position',[0 0 PlotProps.Figure.Width PlotProps.Figure.Height*.6])

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
    Space = subaxis(Grid, CornerLocations(Indx_E, :), [], PlotProps.Indexes.Letters{Indx_E}, PlotProps);
        Title = text(.5, 1, Titles{Indx_E}, 'FontSize', PlotProps.Text.TitleSize, 'FontName', PlotProps.Text.FontName, ...
        'FontWeight', 'Bold', 'HorizontalAlignment', 'Center');
    
    plotBurstFig(AllEEG(Indx_E), Start, Stop, Coordinates{Indx_E, 3}, B, Space, Log,  Coordinates{Indx_E, 4}, PlotProps, Labels);
    
    Axis.Units = 'normalized';
    Title.Units = 'normalized';
end

saveFig('ExampleTheta', Paths.Paper, PlotProps)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Presentation

%% 

% preselected snippets of data with good examples of theta bursts
Coordinates = {
    'EO.set', 308.3, 22, PlotProps.Color.Tasks.PVT, 'Beta';
    'EC2.set', 324, 90,  PlotProps.Color.Tasks.Match2Sample, 'Alpha';
    'fmTheta.set', 581.3, 6,  PlotProps.Color.Tasks.Music, 'Theta';
    'N3_clean.set', 343.15, 11, PlotProps.Color.Tasks.Game, 'Delta';
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
PlotProps = P.Powerpoint;

for Indx_B = 1:size(Coordinates, 1)
    Fig = figure('units','centimeters','position',[0 0 30 10]);
    
    Start = Coordinates{Indx_B, 2};
    plotWaves(AllEEG(Indx_B), Start, Start+2, Coordinates{Indx_B, 3}, ...
        Coordinates{Indx_B, 4}, PlotProps);
    ylim(YLims)
    
    saveFig(Coordinates{Indx_B, end}, Results, PlotProps)
    
end
