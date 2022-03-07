function plotExcelTable(Data, Mask, xLabels, yLabels, cLabel, PlotProps)
% Plots an image that pretents to be an excel table, color coding cells by
% their value.
% Data is R x C
% Mask is a boolean R x C, and determines if text is grayed out or not.
% xLabels is 1 x R


Dims = size(Data);

% plot color squares
plotStatsMatrix(Data, xLabels, yLabels, [], cLabel, PlotProps)


%%% insert text within each cell
x = repmat(1:Dims(2), Dims(1), 1);
y =  repmat(1:Dims(1), Dims(2), 1)';


Labels = num2str(Data(:), '%.2f');
Labels = string(Labels);

% get color for each text
TextColor = repmat([0 0 0], numel(x), 1);

if any(Data(:) < 0) % colormap is divergent
    Q = quantile(abs(Data(:)), .90);
    Top = abs(Data(:)) > Q;
    TextColor(Top, :) = repmat([1 1 1], nnz(Top), 1);
    if ~isempty(Mask)
        TextColor(~Mask(:), :) = repmat([.5 .5 .5], nnz(~Mask(:)), 1);
    end
else % colormap is linear
end

hold on
textscatter(x(:), y(:), string(Labels), 'ColorData', TextColor, ...
    'FontName', PlotProps.Text.FontName, 'TextDensityPercentage', 100, ...
    'FontSize', PlotProps.Text.AxisSize)

h=gca; h.YAxis.TickLength = [0 0];
h.XAxis.TickLength = [0 0];
h.XAxis.FontWeight = 'bold';

set(gca, 'XAxisLocation','top')