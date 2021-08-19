function PlotColorLegend(Colors, Labels, Format)
% plots a dedicated legend for colors used

N = numel(Labels);


W = 4;
H = .75;
 figure('units','normalized','outerposition',[0 0 .1 .5])
hold on
for Indx = 1:N
rectangle('Position',[1 Indx W H],'Curvature',0.2, ...
    'EdgeColor','none', 'FaceColor', Colors(Indx, :))

text(1+W/2, Indx+H/2, Labels{Indx}, 'HorizontalAlignment', 'center', ...
    'FontSize', 25, 'FontName', Format.FontName)
end


set(gca,'XColor', 'none','YColor','none')
axis off
