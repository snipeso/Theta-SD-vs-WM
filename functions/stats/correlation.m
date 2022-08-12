function Stats = correlation(Data1, Data2, StatsP)
% get correlations between two P x 1 variables.

Dims = size(Data1);
Stats  = struct();

Keep = ~(isnan(Data1)|isnan(Data2));
Stats.df = nnz(Keep)-2;


[R, P] = corr(Data1, Data2, 'Rows', 'complete', 'type',StatsP.Correlation);

if numel(R)>1
    PDims = size(P);
    [Sig, crit_p, ~, adj_P] = fdr_bh(P(:), StatsP.Alpha, StatsP.ttest.dep);
    Stats.sig = reshape(Sig, PDims(1), PDims(2));
    Stats.crit_p = crit_p;
    Stats.p_fdr =  reshape(adj_P, PDims(1), PDims(2));
end
Stats.r = R;
Stats.p = P;