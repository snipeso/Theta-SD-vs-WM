function plotTopo(Data, Chanlocs, CLims, Colormap, Format)
% Data is a Ch x 1 matrix. If CLims is empty, uses "minmax". Colormap is
% string.

if numel(CLims) ~= 2
    CLims = 'minmax';
end

topoplot(Data, Chanlocs, 'style', 'map', 'headrad', 'rim', 'whitebk', 'on', ...
    'maplimits', CLims, 'gridscale', Format.TopoRes);

set(gca, 'FontName', Format.FontName, 'FontSize', 12)

colorbar
Colormap = Format.Colormap.(Colormap);
colormap(Colormap)