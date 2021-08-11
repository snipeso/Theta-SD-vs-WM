function Stats = Pairwise(Data, Corrected)
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
        if exist('Corrected', 'var') && Corrected
            [~, sig] = fdr(pValues, .05);
            pValues(not(sig)) = nan; % TEMP
            warning('temp stat!')
        end
        
        
        
    otherwise
        disp('dont know what to do with these dimentions')
end


Stats.p = pValues;
Stats.CI = CI;
Stats.t = tValues;
Stats.df = df;