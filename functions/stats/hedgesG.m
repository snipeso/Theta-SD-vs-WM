function Stats = hedgesG(Data1, Data2, StatsP)
% Data1 and Data2 are P x m x n matrices resulting in m x n stats matrices
% with Hedge's g m x n matrix and confidence intervals m x n x 2

Dims = size(Data1);

gValues = nan(Dims(2), Dims(3));
CI = nan(Dims(2), Dims(3), 2);

for Indx1 = 1:Dims(2)
    for Indx2 = 1:Dims(3)
        D1 = squeeze(Data1(:, Indx1, Indx2));
        D2 = squeeze(Data2(:, Indx1, Indx2));
        stats = mes(D2, D1, StatsP.Paired.ES, 'isDep', 1, 'nBoot', StatsP.ANOVA.nBoot);
        gValues(Indx1, Indx2) = stats.hedgesg;
        CI(Indx1, Indx2, :) = stats.hedgesgCi;
    end
end

Stats.hedgesg = gValues;
Stats.hedgesCI = CI;