function plotFlames(Data, XLabels, Colors, Alpha, Format)
% takes a matrix of P x S x T of values, and plots overlapping violin plots
% for each participant

Dims = size(Data);

hold on

for Indx_P = 1:Dims(1)
   for Indx_S = 1:Dims(2)
      D = squeeze(Data(Indx_P, Indx_S, :)); 
       D(isnan(D)) = [];
       
       if isempty(D)
           continue
       end
    violin(D, 'x', [Indx_S, 0], 'facecolor', Colors(Indx_P, :), 'edgecolor', [], ...
        'facealpha', Alpha, 'mc', [], 'medc', []);
    
   end
end

xlim([.5, Dims(2)+.5])
xticks(1:Dims(2))

if ~isempty(XLabels)
    xticklabels(XLabels)
end

box off

set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize)