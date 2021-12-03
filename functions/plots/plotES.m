function Stats = plotES(Data, Orientation, Colors, xLabels, Legend, Format, StatsP)
% plot effects sizes as ines with circle in middle

Effects = 0:.5:3; % lines to plot

% get hedge's g stats (because <50 participants)
BL = Data(:, 1, :);
BL = permute(repmat(BL, 1, 2, 1), [1 3 2]);

SD = permute(Data(:, 2:3, :), [1 3 2]);
Stats = hedgesG(BL, SD, StatsP);

% Order values based on SD hedge's G
[~, Order] = sort(mean(Stats.hedgesg, 2));

% plot effect size lines
hold on
for E = Effects % NB: has to be this way because of axis flipping (i think)
    plot( [0, numel(xLabels)+1],[E, E], 'Color', [.9 .9 .9], 'HandleVisibility', 'off')
end

plotUFO(Stats.hedgesg(Order, :), Stats.hedgesgCI(Order, :, :), xLabels(Order), Legend, ...
    Colors(Order, :), Orientation, Format)

ylabel(Format.Labels.ES)
