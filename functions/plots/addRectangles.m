function addRectangles(xLabels, yLabels, PlotProps)
% little hack to outline which comparisons were in the same recording
hold on
for Indx_X = 1:numel(xLabels)
Corner = find(contains(yLabels, xLabels{Indx_X}), PlotProps.Line.Width/2, 'first');
End = find(contains(yLabels, xLabels{Indx_X}), PlotProps.Line.Width/2, 'last');

if isempty(Corner)
    continue
end
X = Indx_X-0.5;
Y = Corner-0.5;
Height = End-Corner+1;
Width = 1;
rectangle('Position', [X, Y,  Width, Height], 'LineWidth', 1, 'LineStyle','--')

end