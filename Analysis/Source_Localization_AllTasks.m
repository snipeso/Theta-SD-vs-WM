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
Pixels = P.Pixels;
Format = P.Format;

Folder = fullfile(Paths.Data, 'EEG', 'Source', 'Figure');

load(fullfile(Folder, 'stat_all_tasks_sess2_vs_base.mat'), 'stat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Project to source space (based on fieldtrip)

Source = fullfile(Folder, 'Figures');
if ~exist(Source, 'dir')
    mkdir(Source)
end


%%

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

Pixels = P.Pixels;

Grid = [7, 4];
CLims = [-7 7];
Pixels.PaddingExterior = 90;
plotPatch = true;
figure('units','centimeters','position',[0 4 Pixels.W Pixels.H])


for Indx_T = 1:numel(AllTasks)
    
    % plot each face
    subfigure([], Grid, [Indx_T, 1], [], false, '', Pixels);
    plotBalloonBrain(Maps(Indx_T), 'left-outside', CLims, false, Format)
    
    
   % plot task labels
     Z = get(gca, 'ZLim');
    text(0, 150, diff(Z)/2 + Z(1), TaskLabels{Indx_T}, ...
        'FontSize', Pixels.LetterSize, 'FontName', Pixels.FontName, ...
        'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'Rotation', 90);
    
    % plot all other balloon sides
    subfigure([], Grid, [Indx_T, 2], [], false, '', Pixels);
    plotBalloonBrain(Maps(Indx_T), 'right-outside', CLims, false, Format)
    
    subfigure([], Grid, [Indx_T, 3], [], false, '', Pixels);
    plotBalloonBrain(Maps(Indx_T), 'left-inside', CLims, plotPatch, Format)
    
    subfigure([], Grid, [Indx_T, 4], [], false, '', Pixels);
    plotBalloonBrain(Maps(Indx_T), 'right-inside', CLims, plotPatch, Format)
end

% colorbar
A = subfigure([], Grid, [numel(AllTasks)+1, 1], [1, 4], false, '', Pixels);
shiftaxis(A, Pixels.PaddingLabels, Pixels.PaddingLabels)

Pixels.Colorbar = 'north';
Pixels.BarSize = Pixels.FontSize;
plotColorbar('Divergent', CLims, Format.Labels.t, Pixels)

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

