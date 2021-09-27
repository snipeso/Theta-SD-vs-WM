function plotColorbar(CLims, CLabel, Format)
h = colorbar;
 ylabel(h, CLabel, 'FontName', Format.FontName, 'FontSize', Format.FontSize)
 h.TickLength = 0;
caxis(CLims)
axis off
colormap(reduxColormap(Format.Colormap.Divergent, Format.Steps.Topo*2))
set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize)