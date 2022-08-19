function Stats = corrAll(Data1, Data2, yLabel, yTickLabels, xLabel, xTickLabels, StatsP, PlotProps)
% Data1 is a P x M matrix
% Data2 is a P x N matrix
% Data1 ends up on the y axis, data2 on the x axis


Stats = correlation(Data1, Data2, StatsP);

R = Stats.r;

% R(Stats.p>StatsP.Trend) = R(Stats.p>StatsP.Trend)*.2; 
% R(Stats.p>StatsP.Alpha) = R(Stats.p>StatsP.Alpha)*.25; 
R(Stats.p>.01) = R(Stats.p>.01)*.25; 
% R(Stats.p_fdr>StatsP.Trend) = R(Stats.p_fdr>StatsP.Trend)*.2;
%  R(Stats.p_fdr>StatsP.Alpha) = R(Stats.p_fdr>StatsP.Alpha)*.2;

imagesc(R)
ylabel(yLabel)
yticks(1:numel(yTickLabels))
yticklabels(yTickLabels)

xlabel(xLabel)
xticks(1:numel(xTickLabels))
xticklabels(xTickLabels)

Max = max(abs(Stats.r(:)));
caxis([-Max, Max])
colormap(PlotProps.Color.Maps.Divergent)
h=gca; h.XAxis.TickLength = [0 0];
h.YAxis.TickLength = [0 0];
% h = colorbar;
% set(h, 'R values')


h = colorbar;
ylabel(h, 'R', 'FontName', PlotProps.Text.FontName, 'FontSize', PlotProps.Text.AxisSize,'Color', 'k')


set(gca,'FontName', PlotProps.Text.FontName, 'FontSize', PlotProps.Text.LegendSize)
