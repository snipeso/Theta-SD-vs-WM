% This script plots all the tasks' change from baseline

clear
close all
clc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

Paths = P.Paths;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Bands = P.Bands;
Sessions = P.Sessions;
StatsP = P.StatsP;
Labels = P.Labels;

Duration = 4;
WelchWindow = 8;
Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = 'E_TaskTheta_Channels';


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

CLims_Diff = [-7 7];
CLims = [-1 2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure
%% Figure 7: All topographies

Format = P.Manuscript;
Grid = [7 3];
Indx_B = 2; % theta
Format.Figure.Padding = 20;
Sessions.Labels = {'Baseline', 'Sleep Restriction', 'Sleep Deprivation'};
figure('units','centimeters','position',[0 0 Format.Figure.W3*.8 Format.Figure.Height])

Indx = 1; % tally of axes

% Baseline averages
for Indx_T = 1:numel(AllTasks)
    BL = squeeze(bData(:, 1, Indx_T, :, Indx_B));
    
    % plot
    A = subfigure([], Grid, [Indx_T, 1], [], false, '', Format); Indx = Indx+1;
    shiftaxis(A, Format.Axes.xPadding, Format.Axes.yPadding)
    
    plotTopoplot(nanmean(BL, 1), [], Chanlocs, CLims, Labels.zPower, 'Linear', Format)
    colorbar off
    
    if Indx_T == 1
        title(Sessions.Labels{1}, 'FontSize', Format.Text.TitleSize)
    end
    
    X = get(gca, 'XLim');
    Y = get(gca, 'YLim');
    text(X(1)-diff(X)*.15, Y(1)+diff(Y)*.5, TaskLabels{Indx_T}, ...
        'FontSize', Format.Text.TitleSize, 'FontName', Format.Text.FontName, ...
        'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'Rotation', 90);
end

% colorbar
subfigure([], Grid, [Indx_T+1, 1], [], false, '', Format);
Format.Colorbar.Location = 'north';
Format.Text.LegendSize = Format.Text.AxisSize;
plotColorbar('Linear', CLims, Labels.zPower, Format)


%%% Change from baseline
for Indx_S = [2,3]
    for Indx_T = 1:numel(AllTasks)
        BL = squeeze(bData(:, 1, Indx_T, :, Indx_B));
        SD = squeeze(bData(:, Indx_S, Indx_T, :, Indx_B));
        
        % plot
        A = subfigure([], Grid, [Indx_T, Indx_S], [], false, '', Format); Indx = Indx+1;
        shiftaxis(A, Format.Axes.xPadding, Format.Axes.yPadding)
        
        Stats = topoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Format, Labels);
        colorbar off
        colormap(gca, Format.Color.Maps.Divergent)
        
        if Indx_T == 1
            title(Sessions.Labels{Indx_S}, 'FontSize', Format.Text.TitleSize)
        end
        
        % save stats
        Title = strjoin({'Task_Topo', TaskLabels{Indx_T}, Sessions.Labels{Indx_S}, 'vs', 'BL'}, '_');
        saveStats(Stats, 'Paired', Paths.PaperStats, Title, StatsP)
    end
end

% colorbar
A = subfigure([], Grid, [numel(AllTasks)+1, 2], [1, 2], false, '', Format);
plotColorbar('Divergent', CLims_Diff, Labels.t, Format)

% fix colormaps
Fig = gcf;
Pos = [];
for Indx_Ch = 1:numel(Fig.Children)
    Pos = [Pos, Fig.Children(Indx_Ch).Position(2)];
    if Indx_Ch < 15
        Fig.Children(Indx_Ch).Colormap = reduxColormap(Format.Color.Maps.Divergent, Format.Color.Steps.Divergent);
    else
        Fig.Children(Indx_Ch).Colormap = reduxColormap(Format.Color.Maps.Linear, Format.Color.Steps.Linear);
    end
end

% save
saveFig(strjoin({TitleTag, 'All_Topographies'}, '_'), Paths.Paper, Format)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Presentation figures

%%
Indx_B = 2;
Format = P.Powerpoint;

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
Format = P.Poster;


Indx_B = 2;

for Indx_T = 1:numel(AllTasks)
    figure('units','centimeters','position',[0 0 20 20])
    BL = squeeze(bData(:, 1, Indx_T, :, Indx_B));
    SD = squeeze(bData(:, 3, Indx_T, :, Indx_B));
    topoDiff(BL, SD, Chanlocs, CLims_Diff, StatsP, Format, Labels);
    colorbar off
    saveFig(strjoin({'Topoplot', AllTasks{Indx_T}, 'sdTheta'}, '_'), Paths.Poster, Format)
end






