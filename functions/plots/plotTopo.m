function plotTopo(Data, Chanlocs, CLims, CLabel, Colormap, Format)
% plotTopo(Data, Chanlocs, CLims, CLabel, Colormap, Format)
% Data is a Ch x 1 matrix. If CLims is empty, uses "minmax". Colormap is
% string.

if numel(CLims) ~= 2
    CLims = 'minmax';
end

topoplot(Data, Chanlocs, 'style', 'map', 'headrad', 'rim', 'whitebk', 'on', ...
    'electrodes', 'on',  'maplimits', CLims, 'gridscale', Format.TopoRes);
xlim([-.55 .55])
ylim([-.55 .6])
set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize-5)

if ~isempty(CLabel)
    h = colorbar;
    ylabel(h, CLabel, 'FontName', Format.FontName, 'FontSize', Format.FontSize-5)
end

Colormap = reduxColormap(Format.Colormap.(Colormap), Format.Steps.(Colormap));
colormap(Colormap)