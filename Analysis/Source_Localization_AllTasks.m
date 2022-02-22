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
Format = P.Format;
Format = P.Manuscript;
Poster = P.Poster;
Powerpoint = P.Powerpoint;
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


%% % plot inflated hemispheres for all tasks

Format = P.Manuscript;

Grid = [7, 4];
CLims = [-7 7];
Format.Figure.Padding = 90;
plotPatch = true;
figure('units','centimeters','position',[0 4 Format.Figure.Width Format.Figure.Height])


for Indx_T = 1:numel(AllTasks)
    
    % plot each face
    subfigure([], Grid, [Indx_T, 1], [], false, '', Format);
    plotBalloonBrain(Maps(Indx_T), 'left-outside', CLims, false, Format)
    
    
    % plot task labels
    Z = get(gca, 'ZLim');
    text(0, 150, diff(Z)/2 + Z(1), TaskLabels{Indx_T}, ...
        'FontSize', Format.Text.IndexSize, 'FontName', Format.Text.FontName, ...
        'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'Rotation', 90);
    
    % plot all other balloon sides
    subfigure([], Grid, [Indx_T, 2], [], false, '', Format);
    plotBalloonBrain(Maps(Indx_T), 'right-outside', CLims, false, Format)
    
    subfigure([], Grid, [Indx_T, 3], [], false, '', Format);
    plotBalloonBrain(Maps(Indx_T), 'left-inside', CLims, plotPatch, Format)
    
    subfigure([], Grid, [Indx_T, 4], [], false, '', Format);
    plotBalloonBrain(Maps(Indx_T), 'right-inside', CLims, plotPatch, Format)
end

% colorbar
A = subfigure([], Grid, [numel(AllTasks)+1, 1], [1, 4], false, '', Format);

Format.Colorbar.Position = 'north';
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


