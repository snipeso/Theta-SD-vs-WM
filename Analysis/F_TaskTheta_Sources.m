% script plots inflated brains source localization for all the tasks with
% SD. Written with Elena Krugliakova.
clear
clc
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters


Refresh = false; % needs to be true for first time (I'm lazy)


P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Labels = P.Labels;

Folder = fullfile(Paths.Data, 'EEG', 'Source', 'Figure');

load(fullfile(Folder, 'stat_all_tasks_sess2_vs_base.mat'), 'stat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Project to source space (based on fieldtrip)

Source = fullfile(Folder, 'Figures');
if ~exist(Source, 'dir')
    mkdir(Source)
end

Maps = struct();

for Indx_T = 1:numel(TaskLabels)
    if Refresh
        Map = interpolateSources(stat.(AllTasks{Indx_T}));
        
        save(fullfile(Source, [AllTasks{Indx_T}, '.mat']), 'Map');
    else
        load(fullfile(Source, [AllTasks{Indx_T}, '.mat']), 'Map')
    end
    
    Maps(Indx_T).left = Map.left;
    Maps(Indx_T).right = Map.right;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot


%% Figure SORZ plot inflated hemispheres for all tasks

Format = P.Manuscript;

Grid = [7, 4];
CLims = [-7 7];
Format.Figure.Padding = 90;
plotPatch = true;
figure('units','centimeters','position',[0 0 Format.Figure.Width Format.Figure.Height])


for Indx_T = 1:numel(AllTasks)
    
    % plot each face
    subfigure([], Grid, [Indx_T, 1], [], false, '', Format);
    plotBalloonBrain(Maps(Indx_T), 'left-outside', CLims, false, Format)
    if Indx_T ~=1; title ''; end
    
    % plot task labels
    Z = get(gca, 'ZLim');
    text(0, 150, diff(Z)/2 + Z(1), TaskLabels{Indx_T}, ...
        'FontSize', Format.Text.TitleSize, 'FontName', Format.Text.FontName, ...
        'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'Rotation', 90);
    
    % plot all other balloon sides
    subfigure([], Grid, [Indx_T, 2], [], false, '', Format);
    plotBalloonBrain(Maps(Indx_T), 'right-outside', CLims, false, Format)
    if Indx_T ~=1; title ''; end
    
    subfigure([], Grid, [Indx_T, 3], [], false, '', Format);
    plotBalloonBrain(Maps(Indx_T), 'left-inside', CLims, plotPatch, Format)
    if Indx_T ~=1; title ''; end
    
    subfigure([], Grid, [Indx_T, 4], [], false, '', Format);
    plotBalloonBrain(Maps(Indx_T), 'right-inside', CLims, plotPatch, Format)
    if Indx_T ~=1; title ''; end
end

% colorbar
A = subfigure([], Grid, [numel(AllTasks)+1, 1], [1, 4], false, '', Format);

Format.Colorbar.Location = 'north';
Format.Text.LegendSize = Format.Text.AxisSize;
plotColorbar('Divergent', CLims, Labels.t, Format)

% save
saveFig('All_Sources', Paths.Paper, Format)



%% display amount of voxels significant

clc

load(fullfile(Folder, 'stat_all_tasks_sess2_vs_base.mat'), 'stat')


for Indx_T = 1:numel(AllTasks)
    Mask = stat.(AllTasks{Indx_T}).mask;
    disp([AllTasks{Indx_T}, ' significant voxels: ', num2str(round(100*nansum(Mask)/nnz(~isnan(Mask)))), '%'])
    
end



% same for fmTheta and sdTheta
load(fullfile(Folder, 'stat_M2S_lvl3_vs_lvl1.mat'), 'stat')
Mask = stat.mask;
disp(['fmTheta significant voxels: ', num2str(round(100*nansum(Mask)/nnz(~isnan(Mask)))), '%'])

load(fullfile(Folder, 'stat_M2S_BS_vs_S2_lvl1.mat'), 'stat')

Mask = stat.mask;
disp(['sdTheta significant voxels: ', num2str(round(100*nansum(Mask)/nnz(~isnan(Mask)))), '%'])




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GRC poster

%%

Format = P.Poster;

Grid = [1, 4];
CLims = [-7 7];
Format.Figure.Padding = 0;
plotPatch = true;
figure('units','centimeters','position',[0 4 44 10])
% figure('units','centimeters','position',[0 4 20 30])

% colorbar
A = subfigure([], Grid, [1, 1], [1, 4], false, '', Format);

Format.Colorbar.Position = 'south';
Format.Text.LegendSize = Format.Text.AxisSize;
plotColorbar('Divergent', CLims, Labels.t, Format)
% save
saveFig(['Sources_Colorbar'], Paths.Poster, Format)

%%
for Indx_T = 1:numel(AllTasks)
    figure('units','centimeters','position',[0 4 44 10])
    % plot each face
    subfigure([], Grid, [1, 1], [], false, '', Format);
    plotBalloonBrain(Maps(Indx_T), 'left-outside', CLims, false, Format)
    
    % plot all other balloon sides
    subfigure([], Grid, [1, 2], [], false, '', Format);
    plotBalloonBrain(Maps(Indx_T), 'right-outside', CLims, false, Format)
    
    subfigure([], Grid, [1, 3], [], false, '', Format);
    plotBalloonBrain(Maps(Indx_T), 'left-inside', CLims, plotPatch, Format)
    
    subfigure([], Grid, [1, 4], [], false, '', Format);
    plotBalloonBrain(Maps(Indx_T), 'right-inside', CLims, plotPatch, Format)
    
    % save
    saveFig(['Sources_', AllTasks{Indx_T}], Paths.Poster, Format)
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots for powerpoints

%% plot grid


Grid = [2 2];
CLims_Diff = [-7 7];
PlotPatch = true;
Powerpoint = P.Powerpoint;
Powerpoint.Figure.Padding = 5;

Order = {'left-outside', 'right-outside',  'left-inside',  'right-inside'};
Locations = [1 1; 1 2; 2 1; 2 2];

for Indx_T = 1:numel(AllTasks)
    figure('units','centimeters','position',[0 0 35 30])
    for Indx_F = 1:4
        subfigure([], Grid, Locations(Indx_F, :), [], false, '', Powerpoint);
        plotBalloonBrain(Maps(Indx_T), Order{Indx_F}, CLims_Diff, PlotPatch, Powerpoint)
        padAxis('x', .75)
    end
    
    saveFig([TaskLabels{Indx_T}, '_square'], Paths.Powerpoint, Format)
end


%% plot vertical

Grid = [4 1];
CLims_Diff = [-7 7];
PlotPatch = true;
Powerpoint = P.Powerpoint;
Powerpoint.Figure.Padding = 5;
Powerpoint.Axes.yPadding = 5;
Order = {'left-outside', 'right-outside',  'left-inside',  'right-inside'};


for Indx_T = 1:numel(AllTasks)
    figure('units','centimeters','position',[0 0 15 40])
    for Indx_F = 1:4
        subfigure([], Grid, [Indx_F, 1], [], false, '', Powerpoint);
        plotBalloonBrain(Maps(Indx_T), Order{Indx_F}, CLims_Diff, PlotPatch, Powerpoint)
    end
    
    saveFig([TaskLabels{Indx_T}, '_vertical'], Paths.Powerpoint, Format)
    
end



%% plot horizontal


Grid = [1 4];
CLims_Diff = [-7 7];
PlotPatch = true;
Powerpoint = P.Powerpoint;
Powerpoint.Figure.Padding = 5;
Powerpoint.Axes.xPadding = 5;
Powerpoint.Axes.yPadding = 15;
Order = {'left-outside', 'right-outside',  'left-inside',  'right-inside'};

for Indx_T = 1:numel(AllTasks)
    figure('units','centimeters','position',[0 0 50 10])
    for Indx_F = 1:4
        subfigure([], Grid, [1, Indx_F], [], false, '', Powerpoint);
        plotBalloonBrain(Maps(Indx_T), Order{Indx_F}, CLims_Diff, PlotPatch, Powerpoint)
        
    end
    
    saveFig([TaskLabels{Indx_T}, '_horizontal'], Paths.Powerpoint, Format)
    
end





