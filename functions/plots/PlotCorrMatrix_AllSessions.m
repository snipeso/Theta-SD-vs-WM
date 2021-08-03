function PlotCorrMatrix_AllSessions(Data, yLabels, xLabels, Grid, Format)
% plots a correlation matrix, scaled to min max of the data, with a grid to
% delineate in chunks specified by Grid. xLabels specifies the number of
% lines.

imagesc(Data)
colorbar
colormap(Format.Colormap.Linear)

nYLabels = numel(yLabels);

yticks(1:nYLabels)
yticklabels(yLabels)

xticks(Grid/2:Grid:nYLabels);
xticklabels(xLabels)

caxis([min(Data(:)) max(Data(Data~=1))])
axis square
set(gca, 'FontName', Format.FontName)


% plot session grid
if ~isempty(Grid)
    hold on
    for Indx_S = 1:numel(xLabels)-1
        X = Indx_S*Grid + .5;
        Y = nYLabels + .5;
        plot([X, X], [0 Y], 'k')
        plot([0 Y], [X X], 'k')
    end
end