function Stats = plotES(Data, Orientation, Sort, Colors, xLabels, Legend, PlotProps, StatsP, Labels)
% plot effects sizes as ines with circle in middle
% Data is a P x S x T matrix

% get hedge's g stats (because <50 participants)
Dims = size(Data);

if Dims(2) == 3
    
    BL = Data(:, 1, :);
    BL = permute(repmat(BL, 1, 2, 1), [1 3 2]);
    
    SD = permute(Data(:, 2:3, :), [1 3 2]);
else
    BL = permute(Data(:, 1, :), [1 3 2]);
    SD = permute(Data(:, 2, :), [1 3 2]);
end

Stats = hedgesG(BL, SD, StatsP);

if Sort
    % Order values based on SD hedge's G
    [~, Order] = sort(mean(Stats.hedgesg, 2));
    
    plotUFO(Stats.hedgesg(Order, :), Stats.hedgesgCI(Order, :, :), xLabels(Order), Legend, ...
        Colors(Order, :), Orientation, PlotProps)
else
    plotUFO(Stats.hedgesg, Stats.hedgesgCI, xLabels, Legend, ...
        Colors, Orientation, PlotProps)
end

ylabel(Labels.ES)

if max(abs(Stats.hedgesgCI(:)))>5
Ticks = -10:1:10;
else
Ticks = -10:.5:10;
end

yticks(Ticks)
yticklabels(Ticks)
set(gca, 'YGrid', 'on')
