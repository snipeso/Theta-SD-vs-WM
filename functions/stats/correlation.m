function Stats = correlation(Data1, Data2)
% get correlations between two P x 1 variables.

Keep = ~(isnan(Data1)|isnan(Data2));

[R, P, C1, C2] = corrcoef(Data1(Keep), Data2(Keep));
Stats.r = R(2);
Stats.p = P(2);
Stats.CI = [C1(2), C2(2)];
Stats.df = nnz(Keep)-2;
