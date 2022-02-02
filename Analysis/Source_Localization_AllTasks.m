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

load('mri_for_plot.mat', 'mri_spm_sliced') % TODO check


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
        
        stat_curr = stat.(AllTasks{Indx_T});
        
        % interpolate on the standard mri
        cfg = [];
        cfg.parameter           = 'stat';
        sourceDiff_int          = ft_sourceinterpolate(cfg, stat_curr, mri_spm_sliced);
        cfg.parameter           = 'mask';
        mask_int                = ft_sourceinterpolate(cfg, stat_curr, mri_spm_sliced);
        sourceDiff_int.mask     = mask_int.mask;
        
        cfg = [];
        sourceDiffNorm  = ft_volumenormalise(cfg, sourceDiff_int); % without it plots as squares
        
        % remove everything on the right
        left = sourceDiffNorm;
        left.anatomy(92:181,:,:)   = 0;
        left.stat(92:181,:,:)      = 0;
        left.inside(92:181,:,:)    = 0;
        left.mask(92:181,:,:)      = 0;
        
        % remove everything on the left
        right = sourceDiffNorm;
        right.anatomy(1:91,:,:)    = 0;
        right.stat(1:91,:,:)       = 0;
        right.inside(1:91,:,:)     = 0;
        right.mask(1:91,:,:)       = 0;
        
        
        
        % save
        save(fullfile(Source, [AllTasks{Indx_T}, '.mat']), 'left', 'right');
        Maps(Indx_T).left = left;
        Maps(Indx_T).right = right;
        
    else
        load(fullfile(Source, [AllTasks{Indx_T}, '.mat']), 'left', 'right')
        Maps(Indx_T).left = left;
        Maps(Indx_T).right = right;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot


%%

Grid = [7, 5];
CLims = [-6 6];
figure('units','centimeters','position',[0 4 Pixels.W Pixels.H])


for Indx_T = 1:numel(AllTasks)
    
    %Plot title
    subfigure([], Grid, [Indx_T, 1], [], '', Pixels);
    text(0, 0, TaskLabels{Indx_T}, ...
        'FontSize', Pixels.LetterSize, 'FontName', Pixels.FontName, ...
        'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'Rotation', 90);
    xlim([-1 .25])
    ylim([-.5 .5])
    axis off
    
    % plot each face
    subfigure([], Grid, [Indx_T, 2], [], '', Pixels);
    plotBalloonBrain(Maps(Indx_T), 'left-outside', CLims, Format)
    
    subfigure([], Grid, [Indx_T, 3], [], '', Pixels);
    plotBalloonBrain(Maps(Indx_T), 'right-outside', CLims, Format)
     
    subfigure([], Grid, [Indx_T, 4], [], '', Pixels);
    plotBalloonBrain(Maps(Indx_T), 'left-inside', CLims, Format)
    
    subfigure([], Grid, [Indx_T, 5], [], '', Pixels);
    plotBalloonBrain(Maps(Indx_T), 'right-inside', CLims, Format) 
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

