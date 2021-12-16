function Stats = plotTopoDiff(Data1, Data2, Chanlocs, CLims, StatsP, Format)
% Plot t values of difference between two conditions (Data2 - Data1)
% Each matrix needs the same number of dimentions; participant x ch

% get t values
[~, p, CI, stats] = ttest((Data2 - Data1));
[Sig, crit_p, ~, adj_P] = fdr_bh(p, StatsP.Alpha, StatsP.ttest.dep); % NOTE: dep is good for ERPs, since data can be negatively correlated as well

t_values = stats.tstat';

Stats.t = t_values(:);
Stats.p = p(:);
Stats.p_fdr = adj_P;
Stats.crit_p = crit_p;
Stats.sig = Sig(:);
Stats.df = stats.df(:);
Stats.CI = CI';
Diff = Data2-Data1;
Stats.mean_diff = nanmean(Diff, 1)';
Stats.std_diff = nanstd(Diff, 0, 1)';

Stats.mean1 = nanmean(Data1, 1)';
Stats.std1 = nanstd(Data1, 0, 1)';
Stats.mean2 = nanmean(Data2, 1)';
Stats.std2 = nanstd(Data2, 0, 1)';


stats = mes(Data2, Data1, StatsP.Paired.ES, 'isDep', 1);
Gs = stats.(StatsP.Paired.ES)';
Stats.(StatsP.Paired.ES) = Gs;

% save max significant Hedge's g, # of sig channels, and # channels with
% G>1
Stats.ES_top1 = nnz(Gs >= 1);

Gs(~Sig) = nan; % only consider significant channels for rest
[Stats.ES_maxG, Indx] = max(Gs);
Stats.ES_maxGch = Chanlocs(Indx).labels;
Stats.sigtot = nnz(Sig);

Indexes = 1:numel(Chanlocs);

if isempty(CLims)
    Max = max(abs([quantile(t_values(:), .01), quantile(t_values(:), .99)]));
    CLims = [-Max Max];
end

topoplot(stats.(StatsP.Paired.ES), Chanlocs, 'maplimits', CLims, 'whitebk', 'on', ...
    'style', 'map',  'plotrad', .72, 'headrad', 'rim', 'gridscale', Format.TopoRes, ...
    'electrodes', 'on', 'emarker2', {Indexes(logical(Sig)), 'o', 'w', Format.Topo.Sig, .05});

set(gca, 'FontName', Format.FontName)
xlim([-.55 .55])
ylim([-.55 .6])

set(gca, 'FontName', Format.FontName)

Colormap = reduxColormap(Format.Colormap.Divergent, Format.Steps.Divergent);
colormap(Colormap)



%%% save in stats the peaks of values

[pks, locs, prom, width] = peakfinder_topo(Stats.hedgesg, [Chanlocs.X], [Chanlocs.Y], [Chanlocs.Z], StatsP.minProminence);
Labels = str2double({Chanlocs.labels})';
Stats.ES_Peaks = [pks, Labels(locs), prom, width];


