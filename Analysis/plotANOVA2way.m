function plotANOVA2way(Stats, FactorLabels, StatsP, Format)

YLabel = StatsP.ANOVA.ES;

Data = Stats.effects.(YLabel);

CI =  Stats.effects.([YLabel, 'Ci']);

Y = [min(CI(:)), max(CI(:))];

% make CI relative to effect size
CI(:, 1) = Data - CI(:, 1);
CI(:, 2) = CI(:, 2) - Data;


drawBars(Data, [FactorLabels, 'Interaction'], [], 'vertical', CI, Format)
ylabel(YLabel)
ylim(StatsP.ANOVA.ES_lims)

% plot stars 
P = Stats.ranovatbl.(StatsP.ANOVA.pValue);

P = P([3, 5, 7]);

Symbol = cell([1 3]);

for Indx = 1:3
   Symbol{Indx} = getSigSymbol(P(Indx));
end


Max = Y(2) + .05;
text(1:3, Max*ones(1, 3), Symbol,   'HorizontalAlignment', 'center')
set(gca, 'FontSize', 14)