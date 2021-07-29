function gridTopo(Data, Chanlocs, Labels)
% Instead of a standard topo, creates an "image", with each square
% representing a channel

load('gridChanlocs.mat', 'gridChanlocsIndexes')

% fill data into a matrix based on coordinates specified in gridChanlocs
Grid = nan(12, 11);
for Indx_Ch = 1:numel(Chanlocs)
    [Row, Col] = indx2grid(Chanlocs, gridChanlocsIndexes, Indx_Ch);
    Grid(Row, Col) = Data(Indx_Ch);
end


% plot as image
imagesc(Grid)
% axis off
axis square
colorbar

% add channel labels to image
if exist('Labels', 'var') && Labels
    for Indx_Ch = 1:numel(Chanlocs)
        [Row, Col] = indx2grid(Chanlocs, gridChanlocsIndexes, Indx_Ch);
        text(Col, Row, Chanlocs(Indx_Ch).labels, 'HorizontalAlignment', 'center', 'FontSize', 10)
    end
end

% set(findall(gcf,'-property','FontSize'),'FontSize',12)

end


function [Row, Col] = indx2grid(Chanlocs, gridChanlocsIndexes, Indx_Ch)
% converts the index in the chanlocs to the coordinates in the grid

Label = Chanlocs(Indx_Ch).labels;
if strcmpi(Label, 'Cz')
    Ch = 129;
else
    Ch = str2double(Label);
end
Indx = Ch == gridChanlocsIndexes(:, 1);
Row = gridChanlocsIndexes(Indx, 2);
Col = gridChanlocsIndexes(Indx, 3);

end