function plotRankChange(Data, XLabels, YLabels, Colors, Legend, LegendPosition, Format)
% function for plotting change in values
% Data is Ch x S 

Dims = size(Data);

X = 1:Dims(2);

% make legend items only the first of each color
UniqueColors = unique(Colors, 'rows');


set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize)

hold on
for Indx = 1:Dims(1)
    C = Colors(Indx, :);

    UC = ismember(UniqueColors, C, 'rows');

    if any(UC)
        HV = 'on';
        UniqueColors(UC, :) = [];
    else
        HV = 'off';
    end
    
    plot(X, Data(Indx, :), '-o', 'LineWidth', Format.LW, 'MarkerFaceColor', ...
       C, 'Color', [C, .5], 'HandleVisibility', HV)
end

if ~isempty(YLabels)
    text(ones(Dims(1), 1)*.95, Data(:, 1), string(YLabels),  'HorizontalAlignment', 'right',...
        'FontName', Format.FontName, 'FontSize', Format.BarSize)
end

axis tight
YLims = ylim;

Y = YLims(2)+diff(YLims)*.05;
text(X(1, :), Y*ones(1, Dims(2)), XLabels, 'HorizontalAlignment', 'center', ...
    'FontName', Format.FontName, 'FontSize', Format.TitleSize)

xlim([.5 2.25])
ylim([YLims(1),  YLims(2)+diff(YLims)*.1])
axis off

set(gca, 'FontName', Format.FontName)

if ~isempty(Legend)
    legend(Legend, 'location', LegendPosition)
end

