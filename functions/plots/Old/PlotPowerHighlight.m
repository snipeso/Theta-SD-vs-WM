function PlotPowerHighlight(Matrix, Freqs, FreqsIndxBand, HighlightColor, Format, Legend)
% TEMP: haven't reviewed it yet
% Matrix is participant x session (or task, or whatever) x frequencies

if ndims(Matrix) > 2
    nLines = size(Matrix, 2);
    LineColors = linspace(0, .8, size(Matrix, 2));
else
    nLines = size(Matrix, 1);
    LineColors = linspace(0, .8, size(Matrix, 1));
    
end

hold on
% plot(Freqs, zeros(size(Freqs)), ':', 'LineWidth', .1, 'Color', 'k', 'HandleVisibility','off') % plot the 0 axis
for Indx_L = 1:nLines
    
    if size(HighlightColor, 1) > 1
        HC = HighlightColor(Indx_L, :);
        
        LC = rgb2hsv(HC);
        LC(3) = LC(3)*.75;
        LC(2) = LC(2)*.5;
        LC = hsv2rgb(LC);
        
    else
        HC = HighlightColor;
        LC = LineColors(Indx_L)*ones(1,3);
    end
    if ndims(Matrix) > 2
        Line = squeeze(nanmean(Matrix(:, Indx_L, :), 1));
    else
        Line = Matrix(Indx_L, :);
    end
    
    plot(Freqs, Line, '--', 'LineWidth', 1.5, 'Color', LC,'HandleVisibility','off')
    
    plot(Freqs(FreqsIndxBand(1):FreqsIndxBand(2)), ...
        Line(FreqsIndxBand(1):FreqsIndxBand(2)), ...
        'Color', HC, 'LineWidth', 4)
    
end

if ndims(Matrix) > 2
    Matrix = permute(Matrix, [1, 3, 2]);
    
    TimeSeriesStats(Matrix, Freqs, 100);
end
clc


set(gca, 'FontName', Format.FontName, 'FontSize', 12)
xlabel('Frequency (Hz)',  'FontSize', 14)
%     title(AllTasksLabels{Indx_T}, 'FontSize', 20)
%     axis square

if exist('Legend', 'var')
    legend(Legend)
end
