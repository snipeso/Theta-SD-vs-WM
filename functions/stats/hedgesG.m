function Stats = hedgesG(Data1, Data2, StatsP)
% Data1 and Data2 are P x m x n matrices resulting in m x n stats matrices
% with Hedge's g m x n matrix and confidence intervals m x n x 2. If only
% Data1 is provided, then it should be a P x m matrix, and g values will be
% calculated for every pairwise comparison

Dims = size(Data1);

if nargin == 2 % if only one data matrix is provided
    gValues = nan(Dims(2));
    CI = nan(Dims(2), Dims(2), 2);
    for Indx1 = 1:Dims(2)-1
        for Indx2 = Indx1+1:Dims(2)
            D1 = squeeze(Data1(:, Indx1));
            D2 = squeeze(Data1(:, Indx2));
            stats = mes(D2, D1, Data2.Paired.ES, 'isDep', 1, 'nBoot', Data2.ANOVA.nBoot); % bit of a hack, there's probably a nicer way to do this
            gValues(Indx1, Indx2) = stats.hedgesg;
            CI(Indx1, Indx2, :) = stats.hedgesgCi;
        end
    end
    
    
    
elseif nargin == 3 % if two matrices are provided
    
    if numel(Dims) == 3
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
        
    elseif numel(Dims) == 2
        
        gValues = nan(Dims(2), 1);
        CI = nan(Dims(2), 2);
        
        for Indx1 = 1:Dims(2)
            D1 = squeeze(Data1(:, Indx1));
            D2 = squeeze(Data2(:, Indx1));
            stats = mes(D2, D1, StatsP.Paired.ES, 'isDep', 1, 'nBoot', StatsP.ANOVA.nBoot);
            gValues(Indx1) = stats.hedgesg;
            CI(Indx1, :) = stats.hedgesgCi;
        end
        
        
    end
else
    error('Too few inputs')
end

Stats.hedgesg = gValues;
Stats.hedgesgCI = CI;