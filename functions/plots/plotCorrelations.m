function Stats = plotCorrelations(Data1, Data2, AxisLabels, Legend, Colors, PlotProps, StatsP)
% Data1 and Data2 are P x G matrices, with G groups labeled with colors.
% AxisLabels is a cell with {'xlabel', 'ylabel'}; Legend is {G x 1}. Colors
% are [G x 3].

Dims = size(Data1);

if Dims(2)>1
    if isempty(Colors)
        Colors = getColors(Dims(2));
    end
else
    if isempty(Colors)
        Colors = PlotProps.Color.Generic;
    end
end

hold on
for Indx_G = 1:Dims(2)

    if size(Colors, 1) == Dims(2)
        C = Colors(Indx_G, :);
    elseif size(Colors, 1) == Dims(1)
        C = Colors;
    else
        C = Colors;
    end
    scatter(Data1(:, Indx_G), Data2(:, Indx_G), ...
        PlotProps.Scatter.Size, C, 'filled', 'MarkerFaceAlpha', .5 )
end

    % get correlation
    Stats = correlation(Data1, Data2, StatsP);

% plot regression lines. For some reason, these are the scattered plots
% backwards.

if size(Colors, 1) == Dims(1)
    Colors = [0 0 0];
end

L = lsline;
FlippedColors = flipud(Colors);
FlippedStats = flipud(Stats.p);
for Indx_L = 1:numel(L)
    if  FlippedStats(Indx_L) <= .05
        L(Indx_L).LineWidth = PlotProps.Line.Width;
    else
        L(Indx_L).LineWidth = 2;
    end
    L(Indx_L).Color = FlippedColors(Indx_L, :);

end

set(gca, 'FontName', PlotProps.Text.FontName, 'FontSize', PlotProps.Text.AxisSize)
axis square
if~isempty(Legend)
    legend(Legend)
end
xlim([min(Data1(:)), max(Data1(:))])
ylim([min(Data2(:)), max(Data2(:))])

if ~isempty(AxisLabels)
    xlabel(AxisLabels{1})
    ylabel(AxisLabels{2})
end