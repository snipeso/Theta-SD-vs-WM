function Stats = plotScatterBox(Data, XLabels, StatsP, Colors, YLims, Format)
% Data is a P x m matrix. This plots a cluster of boxplots for each m, with
% the partcipant dots on top.

Dims = size(Data);

%%% get stats
Stats = Pairwise(Data, StatsP);


if size(Colors, 1) == Dims(1)
    ScatterColor = Colors;
    BoxColor = 'k';
elseif size(Colors, 1) == Dims(2)
    ScatterColor = [.5 .5 .5];
    BoxColor = Colors;
else
    ScatterColor = 'k';
    BoxColor = 'k';
end


%%% plot boxplots
hold on
boxplot(Data, 'BoxStyle', 'outline', 'Colors', BoxColor, 'Symbol', '')
% boxplot(Data, 'BoxStyle', 'filled', 'Widths', .5, 'Colors', BoxColor, 'Symbol', '')


%%% plot scatter of participants
for Indx_T = 1:Dims(2)
    scatter(ones(Dims(1), 1)*Indx_T, Data(:, Indx_T), Format.ScatterSize, ScatterColor, 'filled',...
        'MarkerFaceAlpha', Format.Alpha.Participants)
end


if ~isempty(YLims)
    ylim(YLims)
end


%%% plot pairwise significances
plotHangmanStars(Stats, 1:Dims(2), YLims, BoxColor, Format)


xticklabels(XLabels)
set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize)
axis square
box off

set(findobj(gca,'LineStyle','--'),'LineStyle','-') % make whiskers solid line
set(findobj(gca,'LineStyle','-'),'LineWidth',Format.LW) % make all lines quite thick