function plotLineDiff(Data, X, BL_Indx, LineLabels, StatWidth, Colors, Format)
% plots generic line plot, highlighting sections that are significantly
% different from a specified baseline.
% Data is a P x S x n matrix. with BL_Indx referring to S. n is the same
% length as X. StatWidth refers to the bin size of X (# of points) for
% conducting different t-tests. These are then fdr corrected.

Dims = size(Data);

MeanDataP = squeeze(nanmean(Data, 1));
hold on
for Indx_S = 1:Dims(2)
    plot(X, MeanDataP(Indx_S, :), 'Color', Colors(Indx_S, :))
end

% conduct stats

Edges = X(1):StatWidth:X(end);
Bins = discretize(X, Edges);
Midpoints = diff(Edges)+Edges(1:end-1);
MeanDataX = nan([Dims(1:2), numel(Edges)-1]);
for Indx_P = 1:Dims(1)
    for Indx_S = 1:Dims(2) % TEMP, might be a cleaner way without the for loop
        MeanDataX(Indx_P, Indx_S, :) = accumarray(Bins', squeeze(Data(Indx_P, Indx_S, :)), [], @mean);
    end
end

DataBL = squeeze(MeanDataX(:, BL_Indx, :));
for Indx_S = 1:Dims(2)
    if Indx_S == BL_Indx
        continue
    end
    
    Data1 = squeeze(MeanDataX(:, Indx_S, :));
    [~, p, ~, stats] = ttest(Data1, DataBL);
    [~, sig] = fdr(p, .05);
    
    SigData = nan(1, numel(Midpoints));
    SigData(sig) = squeeze(nanmean(MeanDataX(:, Indx_S, sig), 1));
    plot(Midpoints, SigData, 'LineWidth', 4, 'Color', [Colors(Indx_S, :), .7], 'HandleVisibility','off')
end

set(gca, 'FontName', Format.FontName)

if ~isempty(LineLabels)
    legend(LineLabels)
end