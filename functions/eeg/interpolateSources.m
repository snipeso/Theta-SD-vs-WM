function Map = interpolateSources(stat)
% interpolates voxel data into specific balloon surfaces. Based on
% fieldtrip and Elena's stuff.

load('mri_for_plot.mat', 'mri_spm_sliced')


% interpolate on the standard mri
cfg = [];
cfg.parameter           = 'stat';
sourceDiff_int          = ft_sourceinterpolate(cfg, stat, mri_spm_sliced);
cfg.parameter           = 'mask';
mask_int                = ft_sourceinterpolate(cfg, stat, mri_spm_sliced);
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

Map.left = left;
Map.right = right;

