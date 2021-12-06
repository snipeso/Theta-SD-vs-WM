% This script plots all the tasks' change from baseline

clear
close all
clc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
StatsP = P.StatsP;
Channels = P.Channels;
Pixels = P.Pixels;

Duration = 2;
WelchWindow = 8;
Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = strjoin({'Task', 'Topos', 'Welch', num2str(WelchWindow), 'zscored'}, '_');

Results = fullfile(Paths.Results, 'Task_Topographies', Tag);
if ~exist(Results, 'dir')
    mkdir(Results)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data
Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);



% z-score it
zData = zScoreData(AllData, 'last');

% save it into bands
bData = bandData(zData, Freqs, Bands, 'last');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

BandLabels = fieldnames(Bands);
BL_CLabel = 'z-score';
CLims_Diff = [-2 2];
CLims = [-1 2];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure
%% All topographies

Grid = [7 3];
Indx_B = 2; % theta
Sessions.Labels = {'Baseline', 'Sleep Restriction', 'Sleep Deprivation'};
figure('units','centimeters','position',[0 0 Pixels.W*.8 Pixels.H])

Indx = 1; % tally of axes

% just baseline
for Indx_T = 1:numel(AllTasks)
    BL = squeeze(bData(:, 1, Indx_T, :, Indx_B));
    
    A = subfigure([], Grid, [Indx_T, 1], [], '', Pixels);
    Indx = Indx+1;
    shiftaxis(A, Pixels.PaddingLabels, Pixels.PaddingLabels)
    
    plotTopo(nanmean(BL, 1), Chanlocs, CLims, '', 'Linear', Pixels);
    set(A.Children, 'LineWidth', 1)
    colorbar off
    
    if Indx_T == 1
        title(Sessions.Labels{1}, 'FontSize', Pixels.LetterSize)
    end
    
    
    X = get(gca, 'XLim');
    Y = get(gca, 'YLim');
    text(X(1)-diff(X)*.25, Y(1)+diff(Y)*.5, TaskLabels{Indx_T}, ...
        'FontSize', Pixels.LetterSize, 'FontName', Pixels.FontName, ...
        'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'Rotation', 90);
    
end

% colorbar
A = subfigure([], Grid, [Indx_T+1, 1], [], '', Pixels);
shiftaxis(A, Pixels.PaddingLabels, Pixels.PaddingLabels)
Pixels.Colorbar = 'north';
Pixels.BarSize = Pixels.FontSize;
plotColorbar('Linear', CLims, Pixels.Labels.zPower, Pixels)

% Change from baseline
for Indx_S = [2,3]
    for Indx_T = 1:numel(AllTasks)
        BL = squeeze(bData(:, 1, Indx_T, :, Indx_B));
        SD = squeeze(bData(:, Indx_S, Indx_T, :, Indx_B));
        
        A = subfigure([], Grid, [Indx_T, Indx_S], [], '', Pixels);
        Indx = Indx+1;
        
        shiftaxis(A, Pixels.PaddingLabels, Pixels.PaddingLabels)
        
        Stats = plotTopoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Pixels);
        set(A.Children, 'LineWidth', 1)
        colormap(gca, Format.Colormap.Divergent)
        colorbar off
        
        if Indx_T == 1
            title(Sessions.Labels{Indx_S}, 'FontSize', Pixels.LetterSize)
        end
    end
end


% colorbar
A = subfigure([], Grid, [numel(AllTasks)+1, 2], [1, 2], '', Pixels);
shiftaxis(A, Pixels.PaddingLabels, Pixels.PaddingLabels)

plotColorbar('Divergent', CLims_Diff, Format.Labels.ES, Pixels)


% se color by row
Fig = gcf;
Pos = [];
for Indx_Ch = 1:numel(Fig.Children)
    Pos = [Pos, Fig.Children(Indx_Ch).Position(2)];
    if Indx_Ch < 15
        Fig.Children(Indx_Ch).Colormap = reduxColormap(Format.Colormap.Divergent, Format.Steps.Divergent);
    else
        Fig.Children(Indx_Ch).Colormap = reduxColormap(Format.Colormap.Linear, Format.Steps.Linear);
    end
end


% save
saveFig(strjoin({TitleTag, 'All_Topographies'}, '_'), Paths.Paper, Format)
