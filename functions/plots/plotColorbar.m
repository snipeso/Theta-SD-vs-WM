function plotColorbar(Colormap, CLims, CLabel,  Format)
h = colorbar('location', 'west');
 ylabel(h, CLabel, 'FontName', Format.FontName, 'FontSize', Format.BarSize)
 h.TickLength = 0;
caxis(CLims)
axis off
colormap(reduxColormap(Format.Colormap.(Colormap), Format.Steps.(Colormap)))
set(gca, 'FontName', Format.FontName, 'FontSize', Format.BarSize)