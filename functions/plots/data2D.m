function Stats = data2D(PlotType, Data, XLabels, YLabels, YLims, Colors, StatsP, PlotProps)
% Stats = data2D(PlotType, Data, XLabels, YLabels, YLims, Colors, StatsP, PlotProps)
% PlotType is a string, either 'box' or 'line', and plots data as either a
% series of boxplots or a line plot for each participant.

if ~isempty(StatsP)
    Stats = pairedttest(Data, [], StatsP);
else
    Stats = [];
    % TODO: plot stars for group comparison
end

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

switch PlotType
    case 'line'
        plotConfettiSpaghetti(Data, Stats, XLabels, Colors, PlotProps)
    case 'box'
        plotScatterBox(Data, Stats, XLabels, Colors, YLims, PlotProps)
    case 'grid'
        Data = Stats.t;
        Data = tril(-Data.') + triu(Data, 1);
        p = Stats.p_fdr;
        p = tril(p.') + triu(p, 1);
%         Data(p<StatsP.Trend) = 0;
        Data(isnan(Data)) = 0;
        plotStatsMatrix(Data, XLabels, XLabels, [], 't values', PlotProps)
    otherwise
        error('Unknown plot type')
end

