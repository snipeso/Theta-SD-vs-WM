function Stats = correlation(Data1, Data2, StatsP)
% get correlations between two P x 1 variables.

Dims1 = size(Data1);
Dims2 = size(Data2);
Stats  = struct();



R = nan(Dims1(2), Dims2(2));
P = R;
for Indx1 = 1:Dims1(2)
    for Indx2 = 1:Dims2(2)
        [R(Indx1, Indx2), P(Indx1, Indx2)] = corr(Data1(:, Indx1), Data2(:, Indx2), ...
            'Rows', 'complete', 'type',StatsP.Correlation);
    end
end

if numel(R)>1
    PDims = size(P);
    [Sig, crit_p, ~, adj_P] = fdr_bh(P(:), StatsP.Alpha, StatsP.ttest.dep);
    Stats.sig = reshape(Sig, PDims(1), PDims(2));
    Stats.crit_p = crit_p;
    Stats.p_fdr =  reshape(adj_P, PDims(1), PDims(2));
else
Keep = ~(isnan(Data1)|isnan(Data2));
Stats.df = nnz(Keep)-2;
end
Stats.r = R;
Stats.p = P;
Stats.df = Dims1(1)-2;