% example data used in paper

clear
clc
close all

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Format = P.Format;


Coordinates = {
    'P10_LAT_BaselineComp_Clean.set', 536, 118;
    'P10_LAT_Session2Comp_Clean.set', 244, 118;
    'P10_Game_Baseline_Clean.set', 565, 6;
    'P10_Game_Session2_Clean.set', 580, 6;
    };


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

Log = true; % whether to plot on log scale or not
figure('units','centimeters','position',[0 0 Format.Pixels.W*.5 Format.Pixels.H]) 

B.Theta = Bands.Theta;

Grid = [4 1];
Fig = figure('units','normalized','position',[0 0 .3 1]);

ProtoChannel = unique([Coordinates{:, 3}]);
for Indx_E = 1:size(Coordinates, 1)
    Start = Coordinates{Indx_E, 2};
    Stop = Start +3;
    
    Axes(Indx) = subfigure([], Grid, [Indx_E, 1], [], '', Format);

    Title = PlotBurst2(AllEEG(Indx_E), Start, Stop, ProtoChannel, B, Format);
    saveFig([TitleTag, '_', Title], Results, Format)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


