function saveFig(Title, Destination, Format)
% little script for saving figures, so I can change things all together if
% I want

saveas(gcf, fullfile(Destination, [Title, '.svg']));
try
saveas(gcf, fullfile(Destination, [Title, '.jpg']));
catch
    warning(['couldnt save jpg ', Title])
end