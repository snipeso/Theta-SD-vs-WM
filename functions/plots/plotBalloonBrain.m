function plotBalloonBrain(Maps, Orientation, CLims, Format)
% Function for plotting inflated brain half. Based on fieldtrip.
% Maps is a structure with field "left" and "right", containing data from
% that half.
% Orientation is either: 'left-inside', 'left-outside', 'right-inside', or
% 'right-outside'.

cfg = [];
cfg.method         = 'surface';
cfg.funparameter   = 'stat';
cfg.projmethod     = 'nearest';
cfg.funcolorlim    = CLims;
cfg.funcolormap    = reduxColormap(Format.Colormap.Divergent, 20);% YOUR COLORMAP
% cfg.opacitylim     = [0 0.2];
cfg.opacitymap     = 'rampup';
cfg.maskparameter  = 'mask';
cfg.colorbar       = 'no';


switch Orientation
    case 'left-inside'
        cfg.surffile       = 'surface_white_left.mat'; % if put inflated here it does not project correct
        cfg.surfinflated   = 'surface_inflated_left.mat';
        
        ft_sourceplot_hemisphere(cfg, Maps.left);
        view(90,0)
        
    case 'left-outside'
        cfg.surffile       = 'surface_white_left.mat'; % if put inflated here it does not project correct
        cfg.surfinflated   = 'surface_inflated_left.mat';
        
        ft_sourceplot_hemisphere(cfg, Maps.left);
        view(-90,0)
        
    case 'right-inside'
        cfg.surffile       = 'surface_white_right.mat'; % if put inflated here it does not project correct
        cfg.surfinflated   = 'surface_inflated_right.mat';
        
        ft_sourceplot_hemisphere(cfg, Maps.right);
        view(-90,0)
        
    case 'right-outside'
        cfg.surffile       = 'surface_white_right.mat'; % if put inflated here it does not project correct
        cfg.surfinflated   = 'surface_inflated_right.mat';
        
        ft_sourceplot_hemisphere(cfg, Maps.right);
        view(90,0)
end

lighting none
axis tight
