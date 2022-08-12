function Stats = topoCorr(DataCh, Data2, Chanlocs, CLims, StatsP, PlotProps, Labels)
% topoDiff(Data1, Data2, Chanlocs, CLims, StatsP, PlotProps)
%
% plots the t-values (color) and significant channels (white dots) of
% Data2 vs Data1 using chART plots.
% DataCh is a P x Ch, Data2 is a P x 1 array.
% Chanlocs is an EEGLAB channel structure.
% CLims is the limits for the colormap. If none is provided, then the
% min/max is used, centered on 0.
% StatsP is a structure with statistics info (see analysisParameters).
% PlotProps is a structure with plotting info (see chART).

%%% Statistics
Stats = struct();
[R, P] = corrcoef([DataCh, Data2], 'Rows','complete');

Stats.r = R(:, end);
Stats.p = P(:, end);
[Stats.sig, Stats.crit_p, ~,  Stats.p_fdr] = fdr_bh(Stats.p, StatsP.Alpha, StatsP.ttest.dep); 

%%% Plot

% get colorlimits
if isempty(CLims)
    Max = max(abs([quantile(R, .01), quantile(R, .99)]));
    CLims = [-Max Max];
end

plotTopoplot(Stats.r, Stats, Chanlocs, CLims, Labels.r, 'Divergent', PlotProps)


