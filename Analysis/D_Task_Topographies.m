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
Sessions = P.Sessions;
StatsP = P.StatsP;
Channels = P.Channels;
Format = P.Format;
Manuscript = P.Manuscript;
Poster = P.Poster;
Powerpoint = P.Powerpoint;
Labels = P.Labels;


Duration = 4;
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

% % % TEMP QUALITY CHECK RAW DATA
% bData = bandData(AllData, Freqs, Bands, 'last');
% CLims_Diff = [-1 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot data

BandLabels = fieldnames(Bands);
BL_CLabel = 'z-score';
CLims_Diff = [-7 7];
CLims = [-1 2];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure
%% All topographies

Grid = [7 3];
Indx_B = 2; % theta
Manuscript.PaddingExterior = 90;
Sessions.Labels = {'Baseline', 'Sleep Restriction', 'Sleep Deprivation'};
figure('units','centimeters','position',[0 4 Manuscript.W*.7 Manuscript.H])

Indx = 1; % tally of axes

% Baseline averages
for Indx_T = 1:numel(AllTasks)
    BL = squeeze(bData(:, 1, Indx_T, :, Indx_B));
    
    % plot
    A = subfigure([], Grid, [Indx_T, 1], [], false, '', Manuscript); Indx = Indx+1;
    shiftaxis(A, Manuscript.xPadding, Manuscript.yPadding)
    
    plotTopoplot(nanmean(BL, 1), [], Chanlocs, CLims, Labels.zPower, 'Linear', Manuscript)
    colorbar off
    
    if Indx_T == 1
        title(Sessions.Labels{1}, 'FontSize', Manuscript.LetterSize)
    end
    
    X = get(gca, 'XLim');
    Y = get(gca, 'YLim');
    text(X(1)-diff(X)*.15, Y(1)+diff(Y)*.5, TaskLabels{Indx_T}, ...
        'FontSize', Manuscript.LetterSize, 'FontName', Manuscript.FontName, ...
        'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'Rotation', 90);
end

% colorbar
A = subfigure([], Grid, [Indx_T+1, 1], [], false, '', Manuscript);
Manuscript.Colorbar = 'north';
Manuscript.BarSize = Manuscript.FontSize;
plotColorbar('Linear', CLims, Manuscript.Labels.zPower, Manuscript)


%%% Change from baseline
for Indx_S = [2,3]
    for Indx_T = 1:numel(AllTasks)
        BL = squeeze(bData(:, 1, Indx_T, :, Indx_B));
        SD = squeeze(bData(:, Indx_S, Indx_T, :, Indx_B));
        
        % plot
        A = subfigure([], Grid, [Indx_T, Indx_S], [], false, '', Manuscript); Indx = Indx+1;
        shiftaxis(A, Manuscript.xPadding, Manuscript.yPadding)
        
        Stats = topoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Manuscript, Labels);
        set(A.Children, 'LineWidth', 1)
        colormap(gca, Format.Colormap.Divergent)
        
        if Indx_T == 1
            title(Sessions.Labels{Indx_S}, 'FontSize', Manuscript.LetterSize)
        end
        
        % save stats
        Title = strjoin({'Task_Topo', TaskLabels{Indx_T}, Sessions.Labels{Indx_S}, 'vs', 'BL'}, '_');
        saveStats(Stats, 'Paired', Paths.PaperStats, Title, StatsP)
    end
end

% colorbar
A = subfigure([], Grid, [numel(AllTasks)+1, 2], [1, 2], false, '', Manuscript);
plotColorbar('Divergent', CLims_Diff, Format.Labels.t, Manuscript)

% fix colormaps
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




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Presentation figures

%%
Indx_B = 2;

for Indx_T = 1:numel(AllTasks)
    figure('units','centimeters','position',[0 0 20 15])
    BL = squeeze(bData(:, 1, Indx_T, :, Indx_B));
    SD = squeeze(bData(:, 3, Indx_T, :, Indx_B));
    topoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Powerpoint, Labels);
    saveFig(strjoin({TitleTag, AllTasks{Indx_T}, 'sdTheta'}, '_'), Results, Format)
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure for GRC conference poster

%%



Indx_B = 2;

for Indx_T = 1:numel(AllTasks)
    figure('units','centimeters','position',[0 0 20 20])
    BL = squeeze(bData(:, 1, Indx_T, :, Indx_B));
    SD = squeeze(bData(:, 3, Indx_T, :, Indx_B));
    topoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Poster, Labels);
    colorbar off
    saveFig(strjoin({'Topoplot', AllTasks{Indx_T}, 'sdTheta'}, '_'), Paths.Poster, Poster)
end






