function Stats = groupDiff(Data, XLabels, YLabels, YLims, Colors, StatsP, PlotProps)
% plots confettispaghetti comparing groups. Colors should reflect the
% different groups

[uColors, ~, Groups] = unique(Colors, 'rows');

%%% Stats

pValues = nan(numel(XLabels), 1);
for Indx_X = 1:numel(XLabels)

    [~, pValues(Indx_X), ci, stats] = ttest2(Data(Groups==1, Indx_X), Data(Groups==2, Indx_X));

end

%%% Plot

% set y axis
if~isempty(YLims)
    ylim(YLims)

    if ~isempty(YLabels)
        yticks(linspace(YLims(1), YLims(2), numel(YLabels)))
        yticklabels(YLabels)
    end
else
    YLims = ylim;
end

plotConfettiSpaghetti(Data, [],  XLabels, Colors, PlotProps)


    Stats = struct();
    
if ~isempty(StatsP)
    Stats.p = pValues;
    Stats.ci = ci;
    Stats.df = stats.df;
    [Stats.sig, Stats.crit_p, ~,  Stats.p_fdr] = fdr_bh(pValues, StatsP.Alpha, StatsP.ttest.dep);

    if any(Stats.p_fdr<StatsP.Trend)
        plotStars(Stats.p_fdr, 1:numel(XLabels), [], [], PlotProps)
    end
end



CurrentYLims = ylim;

if CurrentYLims(2)<YLims(2)
    ylim(YLims)
end