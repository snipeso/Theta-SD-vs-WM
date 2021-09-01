function Stats = plotTopoDiff(Data1, Data2, Chanlocs, CLims, StatsP, Format)
% Plot t values of difference between two conditions (Data2 - Data1)
% Each matrix needs the same number of dimentions; participant x ch

% get t values
[~, p, CI, stats] = ttest((Data2 - Data1));
[~, Sig] = fdr(p, StatsP.Alpha);
t_values = stats.tstat';

Stats.t = t_values(:);
Stats.p = p(:);
Stats.sig = Sig(:);
Stats.df = stats.df(:);
Stats.CI = CI';
Diff = Data2-Data1;
Stats.diff_mean = nanmean(Diff, 1);
Stats.diff_std = nanstd(Diff, 0, 1);


stats = mes(Data2, Data1, StatsP.Paired.ES, 'isDep', 1);
Stats.(StatsP.Paired.ES) = stats.(StatsP.Paired.ES);


CLabel = StatsP.Paired.ES;
Indexes = 1:numel(Chanlocs);


if isempty(CLims)
    Max = max(abs([quantile(t_values(:), .01), quantile(t_values(:), .99)]));
    CLims = [-Max Max];
end

topoplot(stats.(StatsP.Paired.ES), Chanlocs, 'maplimits', CLims, 'whitebk', 'on', ...
    'style', 'map', 'headrad', 'rim', 'gridscale', Format.TopoRes, ...
   'electrodes', 'on', 'emarker2', {Indexes(logical(Sig)), 'o', 'w', 5, .01});

% 
% h = colorbar;
% ylabel(h, CLabel, 'FontName', Format.FontName, 'FontSize', Format.FontSize)

set(gca, 'FontName', Format.FontName)
xlim([-.55 .55])
ylim([-.55 .6])

set(gca, 'FontName', Format.FontName)

colormap(reduxColormap(Format.Colormap.Divergent, Format.Steps.Topo))
