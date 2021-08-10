function PlotChannelMap(Chanlocs, ChannelStruct, Colors, Format)
% plots a 3D and grid map of electrode locations

Labels = fieldnames(ChannelStruct);

load('gridChanlocs.mat', 'gridChanlocsIndexes')

Grid = zeros(12, 11, 3);
for Indx_Cl = 1:numel(Labels)
    Color = Colors(Indx_Cl, :);
    Ch = ChannelStruct.(Labels{Indx_Cl});
    for Indx_Ch = 1:numel(Ch)
        
        Indx = gridChanlocsIndexes(:, 1) == Ch(Indx_Ch);
        
        R = gridChanlocsIndexes(Indx, 2);
        C = gridChanlocsIndexes(Indx, 3);
        Grid(R, C, :) = Color;
    end
end

figure('units','normalized','outerposition',[0 0 .5 .5])
subplot(1, 2, 1)
% image(Grid)
% hold on
% for Indx_Ch = 1:numel(Chanlocs)
%     
%     ChLabel = Chanlocs(Indx_Ch).labels;
%     if strcmpi(ChLabel, 'Cz')
%         ChLabel = '129';
%     end
%     Indx = gridChanlocsIndexes(:, 1) == str2double(ChLabel);
%     
%     R = gridChanlocsIndexes(Indx, 2);
%     C = gridChanlocsIndexes(Indx, 3);
%     text(C, R, ChLabel, 'HorizontalAlignment', 'center', 'FontSize', 10)
% end
% 
% axis square

PlotColors = ones(numel(Chanlocs), 3);
for Indx_Cl = 1:numel(Labels)
    
    Color = Colors(Indx_Cl, :);
        Ch = ChannelStruct.(Labels{Indx_Cl});
      for Indx_Ch = 1:numel(Ch)
          Indx = labels2indexes(Ch(Indx_Ch), Chanlocs);
          PlotColors(Indx, :) = Color;
      end
end
bubbleTopo(PlotColors, Chanlocs, 120, '2D', true, Format)


subplot(1, 2, 2)
bubbleTopo(PlotColors, Chanlocs, 200, '3D', true, Format)
