function plotPieBars(Data, Edges, YLabels, Colors, Format)
% Plots stacked bar plots horizontally, by binning the Data (m x n), and
% returning m bars divided into Edges-1 groups. 

Dims = size(Data);
 Bins = discretize(Data, Edges);
 
 Frequencies = zeros(Dims(1), numel(Edges)-1);
 
 for Indx_M = 1:Dims(1)
    T = tabulate(Bins(Indx_M, :)); 
     Frequencies(Indx_M, T(:, 1)) = T(:, 2);
 end
 
YLabels = flip(YLabels);
Frequencies = flip(Frequencies); 

h = barh(Frequencies, 'stacked', 'EdgeColor', 'none');

% turn into % value
Frequencies = round(100*(Frequencies/Dims(2)));

Prev = zeros(1, Dims(1));
for Indx_C = 1:numel(Edges)-1
    
    % change face color
   h(Indx_C).FaceColor = Colors(Indx_C, :);
   
   % write text of labels
   Freqs = Frequencies(:, Indx_C);
   Freqs(Freqs<5) = 0;
   Skip = Freqs == 0;
   Freqs = append(string(Freqs), '%');
   Freqs(Skip) = '';
   
   X = Prev + h(Indx_C).YData/2;
   
    text(X, 1:Dims(1), Freqs, 'Color', [.2 .2 .2],...
        'HorizontalAlignment', 'center', 'FontName', Format.FontName)
    Prev = h(Indx_C).YData + Prev;
end


axis tight

ylim([.5, Dims(1)+.5])
yticks(1:Dims(1))

set(gca,'XColor', 'none','YColor','none')
axis off

text(-ones(1, Dims(1))*2, 1:Dims(1), YLabels, 'HorizontalAlignment', 'right', ...
    'FontName', Format.FontName, 'FontSize', 15)

set(gca, 'FontSize', 14, 'FontName', Format.FontName)