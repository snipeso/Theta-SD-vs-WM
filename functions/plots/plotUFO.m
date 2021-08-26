function plotUFO(Data, CI, XLabels, CLabels, Colors, Orientation, Format)
% Data is a m x n matrix, CI is an m x n x 2. Colors is m x 3 or n x 3.
% this plots means and confidence intervals stacked vertically.

Dims = size(Data);

XMajorPoints = flip(1:Dims(1))';

XScatter = linspace(-.5, .5, Dims(2)+2);
XScatter([1, end]) = [];

XMinorPoints = XMajorPoints + XScatter;

if Dims(2) > 3
    Paleness = linspace(.2, 1, Dims(2));
elseif Dims(2) > 1
    Paleness = linspace(.3, 1, Dims(2));
end

hold on
for Indx_N = 1:Dims(2)
    
    % determine if colors provided come from m or n dimention, and choose
    % appropriately
    if size(Colors, 1) == Dims(1)
        Color = makePale(Colors, Paleness(Indx_N)); % make it paler for each n
    elseif size(Colors, 1) == Dims(2)
        Color = repmat(Colors(Indx_N, :), Dims(1), 1);
    end
    
    
    for Indx_M = 1:Dims(1)
        X = XMinorPoints(Indx_M, Indx_N);
        
        plot([X, X], squeeze(CI(Indx_M, Indx_N, :)), 'Color', Color(Indx_M, :), 'LineWidth', 5, 'HandleVisibility', 'off')
        
    end
    
    scatter( XMinorPoints(:, Indx_N), Data(:, Indx_N), 300, Color, 'filled')
end


set(gca, 'FontName', Format.FontName, 'FontSize', 14)

xlim([.5 Dims(1)+.5])
xticks(flip(XMajorPoints))
xticklabels(flip(XLabels))
Ax = gca;
Ax.XAxis.FontSize = 18;

ylim([min(CI(:)),  max(CI(:))])
padAxis('x')
padAxis('y')


legend(CLabels)

if strcmpi(Orientation, 'vertical')
    view([90 90])
end

