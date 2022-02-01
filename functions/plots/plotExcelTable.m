function plotExcelTable(Data, Mask, xLabels, yLabels, cLabel, Format)


Dims = size(Data);
% [~, Order] = sort(nanmean(Data, 2), 'descend');
Order = 1:Dims(1);

Data = Data(Order, :);

Format.FontSize = 10;
plotStatsMatrix(Data, xLabels(Order), yLabels, [], cLabel, Format)


% insert text within each cell
x = repmat(1:Dims(2), Dims(1), 1);
y =  repmat(1:Dims(1), Dims(2), 1)';


Labels = num2str(Data(:), '%.2f');
Labels = string(Labels);

TextColor = repmat([0 0 0], numel(x), 1);

if any(Data(:) < 0) % colormap is divergent
    Q = quantile(Data(:), .90);
    Top = Data(:) > Q;
    TextColor(Top, :) = repmat([1 1 1], nnz(Top), 1);
    if ~isempty(Mask)
    TextColor(~Mask(:), :) = repmat([.5 .5 .5], nnz(~Mask(:)), 1);
    end
else % colormap is linear
end

hold on
textscatter(x(:), y(:), string(Labels), 'ColorData', TextColor, 'FontName', Format.FontName, 'TextDensityPercentage', 100)
h=gca; h.YAxis.TickLength = [0 0];
h.XAxis.TickLength = [0 0];
h.XAxis.FontWeight = 'bold';

set(gca, 'XAxisLocation','top')