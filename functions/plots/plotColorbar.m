function plotColorbar(Colormap, CLims, CLabel,  Format)
h = colorbar;
 ylabel(h, CLabel, 'FontName', Format.FontName, 'FontSize', Format.FontSize)
 h.TickLength = 0;
caxis(CLims)
axis off
colormap(reduxColormap(Format.Colormap.(Colormap), Format.Steps.(Colormap)))
set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize)