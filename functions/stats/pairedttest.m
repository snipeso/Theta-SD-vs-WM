function Stats = pairedttest(Data1, Data2, StatsP)
% Calculates t-tests, p values, fdr corrected p values, and effect sizes.
% Input options:
% A) Data1 = P x S, Data2 = []: t-tests done for every S with every S. Returns
% a S x S matrix, filled only in the upper triangle. Used in
% ConfettiSpaghetti.
% B) Data1 = P x S x T, Data2 = []: t-tests done for every S with every S,
% for all Ts. Results in a S x S x T matrix. TODO: not implemented yet
% C) Data1 = P x S, Data2 = P x S: t-tests done for each S of Data1 and
% Data2. Results in a S x 1 array. Used in TopoDiff.
% D) Data1 = P x T, Data2 = P x S x T: t-tests done between Data1 and every S
% of Data 2. Results in a S x T matrix. Used in SpaghettiOs.

Dims1 = size(Data1);
Dims2 = size(Data2);

if isempty(Data2) && numel(Dims1) == 2 % A
    
    pValues = nan(Dims1(2));
    tValues = nan(Dims1(2));
    CI = nan(Dims1(2), Dims1(2), 2);
    df = nan(Dims1(2));
    
    for Indx1 = 1:Dims1(2)-1
        for Indx2 = Indx1+1:Dims1(2)
            [~, p, ci, stats] = ttest(Data1(:, Indx1), Data1(:, Indx2));
            pValues(Indx1, Indx2) = p;
            tValues(Indx1, Indx2) = stats.tstat;
            df(Indx1, Indx2) = stats.df;
            CI(Indx1, Indx2, :) = ci;
        end
    end
    
    % get vector of diamond matrix so can replace things properly
    Indexes = 1:Dims1(2)^2;
    Indexes = reshape(Indexes, Dims1(2), []);
    pValues_long = pValues(:);
    Indexes_long = Indexes(:);
    Nans = isnan(pValues_long); % there is probably a more elegant way to do this
    pValues_long(Nans) = [];
    Indexes_long(Nans) = [];
    
    % identify still significant values
    [sig, crit_p, ~,  pValues_fdr] = fdr_bh(pValues_long, StatsP.Alpha, StatsP.ttest.dep);
    
    h = nan(Dims1(2));
    h(Indexes_long) = sig;
    Stats.sig = h;
    Stats.t = tValues;
    Stats.p = pValues;
    Stats.crit_p = crit_p;
    Stats.df = df;
    
    FDR = nan(Dims1(2));
    FDR(Indexes_long) = pValues_fdr;
    Stats.p_fdr = FDR;
    
    % get effect sizes
    G = hedgesG(Data1, StatsP);
    Stats.hedgesg = G.hedgesg;
    Stats.hedgesgCI = G.hedgesgCI;
    
elseif isempty(Data2) && numel(Dims1) == 3 % B
    Stats = struct();
    
elseif numel(Dims1) == 2 && numel(Dims2) == 2 % C
    
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
    
elseif numel(Dims1) == 2 && numel(Dims2) == 3 % D
    
    % get all p-values
    p = nan(Dims2(2), Dims2(3));
    t_values = p;
    df = p;
    CI = nan(Dims2(2), Dims2(3), 2);
    
    for Indx_S = 1:Dims2(2)
        for Indx_T = 1:Dims2(3)
            D = squeeze(Data2(:, Indx_S, Indx_T));
            BL = squeeze(Data1(:, Indx_T));
            [~, p(Indx_S, Indx_T), CI(Indx_S, Indx_T, :), stats] = ttest(D(:)-BL(:));
            df(Indx_S, Indx_T) = stats.df;
            t_values(Indx_S, Indx_T) = stats.tstat;
        end
    end
    
    % apply fdr correction
    [Sig, crit_p, ~,  pValues_fdr] = fdr_bh(p, StatsP.Alpha, StatsP.ttest.dep);
    
    % save to stats struct
    Stats.p = p;
    Stats.p_fdr =  pValues_fdr;
    Stats.crit_p = crit_p;
    Stats.sig = Sig;
    Stats.t = t_values;
    Stats.df = df;
end