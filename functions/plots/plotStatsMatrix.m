function plotStatsMatrix(Data, yLabels, xLabels, Grid, CLabel, Format)
% plots t or g or whatever values.

imagesc(Data)

Range = [min(Data(:)), max(Data(:))];

if ~isempty(CLabel)
    h = colorbar;
    ylabel(h, CLabel, 'FontName', Format.FontName, 'FontSize', Format.BarSize)
end

if Range(1) < 0
    Lim = max(abs(Range));
    Range = [-Lim, Lim];
    colormap(Format.Colormap.Divergent)
    caxis(Range)
else
    colormap(Format.Colormap.Linear)
    caxis(Range)
end

nYLabels = numel(yLabels);

yticks(1:nYLabels)
yticklabels(yLabels)




% axis square
set(gca, 'FontName', Format.FontName)

xticklabels(xLabels)

% plot session grid
if ~isempty(Grid)
    xticks((Grid+1)/2:Grid:nYLabels);
xticklabels(xLabels)

    hold on
    for Indx_S = 1:numel(xLabels)-1
        X = Indx_S*Grid + .5;
        Y = nYLabels + .5;
        plot([X, X], [0 Y], 'k')
        plot([0 Y], [X X], 'k')
    end
end

set(gca, 'FontSize', Format.FontSize)