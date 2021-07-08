function TimeSeriesStats(Matrix, t, PeriodLength)
% SUPER TEMP!
% Matrix is participants x time x group

% get mini window for test
End = size(Matrix, 2);
fs = 1/(diff(t(1:2)));
Period = (PeriodLength/1000)*fs;

Starts = round(1:Period+1:End+1);
Stops = round(Starts-1);
Stops(1) = []; % remove starting 0

% remove groups that are missing
if ndims(Matrix) == 3
    Matrix(:, :, squeeze(all(isnan(mean(Matrix, 2))))) = [];
end

% get pvalues for each window
pValues = ones(numel(Stops), 1);
for Indx_S = 1:numel(Stops)
    
    if ndims(Matrix) < 3 %run a t-test
        Data = squeeze(nanmean(Matrix(:, Starts(Indx_S):Stops(Indx_S)), 2));
        
        [~, p] = ttest(Data);
    else
        Data = squeeze(nanmean(Matrix(:, Starts(Indx_S):Stops(Indx_S), :), 2));
        [stats, Table] = mes1way(Data, 'eta2', 'isDep',1); %  'nBoot', 1000
        p = Table{2, 6};
    end
    
    pValues(Indx_S) = p;
end

% identify height for plotting sig bars
GrandMean = nanmean(Matrix, 1);
Max = max(GrandMean(:));
Min = min(GrandMean(:));
Ceiling = Max+(Max-Min)*0.1;
YLims = [  Min-(Max-Min)*0.2, Max+(Max-Min)*0.2];
ylim(YLims)

% do fdr correction
[~, pValuesFDRmask] = fdr(pValues, .05);
pValuesFDR = nan(size(pValues));
pValuesFDR(pValuesFDRmask) = pValues(pValuesFDRmask);

% TODO: make this more succint
Sig_pValues = nan(size(pValues));
Sig_pValues(pValues<=.05) = Ceiling;
Sig_pValues(pValues>.05) = nan;

Sig_pValuesFDR = nan(size(pValuesFDR));
Sig_pValuesFDR(pValuesFDR<=.05) = Ceiling;
Sig_pValuesFDR(pValuesFDR>.05) = nan;

% plot significance bars
hold on
t_pValues = linspace(t(1), t(end), numel(Sig_pValues));
plot(t_pValues, Sig_pValues, 'LineWidth', 4, 'Color', [.7 0.7 0.7])
plot(t_pValues, Sig_pValuesFDR, 'LineWidth', 4, 'Color', [0 0 0])


% plot 0 line, because this is what the stats were compared to
if ndims(Matrix) < 3
    plot(t, zeros(size(Matrix, 2), 1), 'Color', [0  0 0])
end
% TODO: split by larger significance?
end
