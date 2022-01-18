function Stats = pairedttest(Data1, Data2, StatsP)
% does both hedge's g and ttest and fdr correction. Data1 should be a P x
% Ch matrix


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
ES = stats.(StatsP.Paired.ES)';
Stats.(StatsP.Paired.ES) = ES;