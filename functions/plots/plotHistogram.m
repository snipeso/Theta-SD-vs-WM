function plotHistogram(Data, BinSize, xLims,  xLabel, yLabel, Legend, Colors, Format)
% plots overlapping histogram of S x T data

Dims = size(Data);

if isempty(xLims)
    Edges = min(Data(:)):BinSize:max(Data(:));
else
    Edges = xLims(1):BinSize:xLims(2);
end

hold on
for Indx_S = 1:Dims(1)
    histogram(Data(Indx_S, :), 'BinEdges', Edges, 'EdgeColor', 'none', ...
        'FaceColor', Colors(Indx_S, :), 'FaceAlpha', .5)
end

yticks([])
if ~isempty(xLabel)
    xlabel(xLabel)
end

if ~isempty(yLabel)
    ylabel(yLabel)
end

if ~isempty(Legend)
    legend(Legend)
end

set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize)
box off