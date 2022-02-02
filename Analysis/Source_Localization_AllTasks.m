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
Grid = [7, 5];
CLims = [-6 6];
plotPatch = true;
figure('units','centimeters','position',[0 4 Pixels.W Pixels.H])


for Indx_T = 1:numel(AllTasks)
    
    %Plot title
    subfigure([], Grid, [Indx_T, 1], [], '', Pixels);
    text(0, 0, TaskLabels{Indx_T}, ...
        'FontSize', Pixels.LetterSize, 'FontName', Pixels.FontName, ...
        'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'Rotation', 90);
    xlim([-1 .1])
    ylim([-.5 .5])
    axis off
    
    % plot each face
    subfigure([], Grid, [Indx_T, 2], [], '', Pixels);
    plotBalloonBrain(Maps(Indx_T), 'left-outside', CLims, false, Format)
    
    subfigure([], Grid, [Indx_T, 3], [], '', Pixels);
    plotBalloonBrain(Maps(Indx_T), 'right-outside', CLims, false, Format)
    
    subfigure([], Grid, [Indx_T, 4], [], '', Pixels);
    plotBalloonBrain(Maps(Indx_T), 'left-inside', CLims, plotPatch, Format)
    
    subfigure([], Grid, [Indx_T, 5], [], '', Pixels);
    plotBalloonBrain(Maps(Indx_T), 'right-inside', CLims, plotPatch, Format)
end

% colorbar
A = subfigure([], Grid, [numel(AllTasks)+1, 2], [1, 4], '', Pixels);
shiftaxis(A, Pixels.PaddingLabels, Pixels.PaddingLabels)

Pixels.Colorbar = 'north';
Pixels.BarSize = Pixels.FontSize;
Pixels.Steps.Divergent = 20;
plotColorbar('Divergent', CLims, Format.Labels.ES, Pixels)

% save
saveFig('All_Sources', Paths.Paper, Format)

