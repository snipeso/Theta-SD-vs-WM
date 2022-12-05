function Stats = plotSticksAndStones(Data1, Data2, AxisLabels, Legend, Colors, PlotProps)
% Data1 and Data2 are P x G matrices, with G groups labeled with colors

Dims = size(Data1);

Stats.r = nan(Dims(2), 1);
Stats.pvalue = Stats.r;

hold on
for Indx_G = 1:Dims(2)
    
    scatter(Data1(:, Indx_G), Data2(:, Indx_G), ...
        PlotProps.Scatter.Size, Colors(Indx_G, :), 'filled', 'MarkerFaceAlpha', .5 )
    
    % get correlation
    [Stats.r(Indx_G), Stats.pvalue(Indx_G)] = corr(Data1(:, Indx_G), Data2(:, Indx_G));
    
end

% plot regression lines. For some reason, these are the scattered plots
% backwards.

L = lsline;
FlippedColors = flipud(Colors);
FlippedStats = flipud(Stats.pvalue);
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
xlabel(AxisLabels{1})
ylabel(AxisLabels{2})