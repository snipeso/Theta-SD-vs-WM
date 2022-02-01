function plotRankChange(Data, XLabels, YLabels, Format)

Dims = size(Data);

X = 1:Dims(2);

% Color is divergent color based on whether it goes up or down between the
% two lists
if Dims(2) == 2
Colormap = Format.Colormap.Divergent;
Indexes = 1:size(Colormap, 1);
Diffs = diff(Data, 1, 2);
Max = max(abs(Diffs));
Diffs = mat2gray([-Max; Diffs; Max]);
Indexes = dsearchn(Indexes', Diffs(:)*size(Colormap, 1));
Indexes([1 end]) = [];
Colors = Colormap(Indexes, :);

else
    Colors = reduxColormap(Format.Colormap.Rainbow, Dims(1));
end

hold on
for Indx = 1:Dims(1)
plot(X, Data(Indx, :), '-o', 'LineWidth', Format.LW, 'MarkerFaceColor', Colors(Indx, :), 'Color', [Colors(Indx, :), .5])
end

if ~isempty(YLabels)
text(ones(Dims(1), 1)*.95, Data(:, 1), string(YLabels),  'HorizontalAlignment', 'right',...
    'FontName', Format.FontName, 'FontSize', Format.BarSize)
end

axis tight
YLims = ylim;

Y = YLims(2)+diff(YLims)*.05;
text(X(1, :), Y*ones(1, Dims(2)), XLabels, 'HorizontalAlignment', 'center', 'FontName', Format.FontName, 'FontSize', Format.TitleSize)

xlim([.5 2.25])
ylim([YLims(1),  YLims(2)+diff(YLims)*.1])
axis off

set(gca, 'FontName', Format.FontName)