function saveFig(Title, Destination, Format)
% little script for saving figures, so I can change things all together if
% I want

saveas(gcf, fullfile(Destination, [Title, '.svg']));
saveas(gcf, fullfile(Destination, [Title, '.png']));