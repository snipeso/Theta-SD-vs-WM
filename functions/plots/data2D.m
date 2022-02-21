function Stats = data2D(Data, XLabels, YLabels, YLims, Colors, StatsP, PlotProps)
% Stats = data2D(Data, XLabels, YLabels, YLims, Colors, StatsP, PlotProps)

% Plots a confettiSpaghetti plot of Data (P x S). and returns pairwise comparisons of all groups TOCHECK

if ~isempty(StatsP)
 Stats = Pairwise(Data, StatsP);
else
    Stats = [];
    % TODO: plot stars for group comparison
end

plotConfettiSpaghetti(Data, Stats, XLabels, Colors, PlotProps)


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