function Stats = Pairwise(Data, StatsP)
% Data is a P x w/e matrix, and here t-tests are returned. If "Corrected"
% is specified, conducts FDR correction on the p values. pvalues, tvalues
% and df are saved as S x S matrix

Dims = size(Data);

if any(Dims==1)
    nDims = numel(Dims)-1;
else
    nDims = numel(Dims);
end

switch nDims
    case 2 % e.g. P x S
        pValues = nan(Dims(2));
        tValues = nan(Dims(2));
        CI = nan(Dims(2), Dims(2), 2);
        df = nan(Dims(2));
        
        for Indx1 = 1:Dims(2)-1
            for Indx2 = Indx1+1:Dims(2)
                [~, p, ci, stats] = ttest(Data(:, Indx1), Data(:, Indx2));
                pValues(Indx1, Indx2) = p;
                tValues(Indx1, Indx2) = stats.tstat;
                df(Indx1, Indx2) = stats.df;
                CI(Indx1, Indx2, :) = ci;
            end
        end
        
        % correct for multiple comparisons
        if exist('StatsP', 'var')
            % get vector of diamond matrix so can replace things properly
            Indexes = 1:Dims(2)^2;
            Indexes = reshape(Indexes, Dims(2), []);
            pValues_long = pValues(:);
            Indexes_long = Indexes(:);
            Nans = isnan(pValues_long); % there is probably a more elegant way to do this
            pValues_long(Nans) = [];
            Indexes_long(Nans) = [];
            
            % identify still significant values
            [~, sig] = fdr(pValues_long, StatsP.Alpha);
            h = nan(Dims(2));
            h(Indexes_long) = sig;
            Stats.sig = h;
          
            % identify trending values
           [~, sig] = fdr(pValues_long, StatsP.Trend);
            h = nan(Dims(2));
            h(Indexes_long) = sig;
            Stats.trend = h;
            
        end
        
        
        
    otherwise
        disp('dont know what to do with these dimentions')
end


Stats.p = pValues;
Stats.CI = CI;
Stats.t = tValues;
Stats.df = df;