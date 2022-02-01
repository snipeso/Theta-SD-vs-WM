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
ft_defaults

load('mtrx_all_tasks')
load('mri_for_plot.mat')
load('stat_all_tasks_sess2_vs_base.mat')

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

cfg = [];
cfg.method         = 'surface';
cfg.funparameter   = 'stat';
cfg.projmethod     = 'nearest';
cfg.funcolorlim    = [-6 6];
cfg.funcolormap    = reduxColormap(Format.Colormap.Divergent, 20);% YOUR COLORMAP
% cfg.opacitylim     = [0 0.2];
cfg.opacitymap     = 'rampup';
cfg.maskparameter  = 'mask';
cfg.colorbar       = 'no';


cfg.surffile       = 'surface_white_left.mat'; % if put inflated here it does not project correct
cfg.surfinflated   = 'surface_inflated_left.mat';




%%

Grid = [7, 4];
figure('units','centimeters','position',[0 4 Pixels.W Pixels.H])
% figure



for Indx_T = 1:numel(AllTasks)
    
    cfg.surffile       = 'surface_white_left.mat'; % if put inflated here it does not project correct
    cfg.surfinflated   = 'surface_inflated_left.mat';
    
    % left inside
    A = subfigure([], Grid, [Indx_T, 1], [], '', Pixels);
    ft_sourceplot_hemisphere(cfg, Maps(Indx_T).left);
    view(-90,0)
    lighting none
    axis tight
    
    % Plot title TODO
%     X = get(gca, 'XLim');
%     Y = get(gca, 'YLim');
%     text(X(1)-diff(X)*.25, Y(1)+diff(Y)*.5, TaskLabels{Indx_T}, ...
%         'FontSize', Pixels.LetterSize, 'FontName', Pixels.FontName, ...
%         'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'Rotation', 90);
    
    
    A = subfigure([], Grid, [Indx_T, 3], [], '', Pixels);
    ft_sourceplot_hemisphere(cfg, Maps(Indx_T).left);
    view(90,0)
    lighting none
    axis tight
    
    cfg.surffile       = 'surface_white_right.mat'; % if put inflated here it does not project correct
    cfg.surfinflated   = 'surface_inflated_right.mat';
    
    
    A = subfigure([], Grid, [Indx_T, 4], [], '', Pixels);
    ft_sourceplot_hemisphere(cfg, Maps(Indx_T).right);
    view(-90,0)
    lighting none
    axis tight
    
    
    A = subfigure([], Grid, [Indx_T, 2], [], '', Pixels);
    ft_sourceplot_hemisphere(cfg, Maps(Indx_T).right);
    view(90,0)
    lighting none
    axis tight
    
end


% save
saveFig('All_Sources', Paths.Paper, Format)

