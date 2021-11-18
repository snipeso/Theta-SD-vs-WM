function Stats = plotLineDiff(Data, X, BL_Indx, LineLabels, StatWidth, Colors, xLog, Format, StatsP)
% plots generic line plot, highlighting sections that are significantly
% different from a specified baseline.
% Data is a P x S x n matrix. with BL_Indx referring to S. n is the same
% length as X. StatWidth refers to the bin size of X (# of points) for
% conducting different t-tests. These are then fdr corrected.

Dims = size(Data);

MeanDataP = squeeze(nanmean(Data, 1));
hold on
for Indx_S = 1:Dims(2)
    if xLog
        plot(log(X), MeanDataP(Indx_S, :), ':', 'Color', Colors(Indx_S, :), 'LineWidth', Format.LW/2)
    else
        plot(X, MeanDataP(Indx_S, :), ':', 'Color', Colors(Indx_S, :), 'LineWidth', Format.LW/2)
    end
    
end

% conduct stats

Edges = X(1):StatWidth:X(end);
Edges(1) =  X(1);
Edges(end) = X(end);
Bins = discretize(X, Edges);
Midpoints = Edges(1:end-1)+StatWidth/2;
MeanDataX = nan([Dims(1:2), numel(Edges)-1]);
for Indx_P = 1:Dims(1)
    for Indx_S = 1:Dims(2) % TEMP, might be a cleaner way without the for loop
        MeanDataX(Indx_P, Indx_S, :) = accumarray(Bins', squeeze(Data(Indx_P, Indx_S, :)), [], @mean);
    end
end

Stats = struct();
Stats.pvalues = nan(Dims(2),  numel(Edges)-1);
Stats.sig = Stats.pvalues;
Stats.df = Stats.pvalues;
Stats.tvalues =  Stats.pvalues;

DataBL = squeeze(MeanDataX(:, BL_Indx, :));
for Indx_S = 1:Dims(2)
    if Indx_S == BL_Indx
        continue
    end
    
    Data1 = squeeze(MeanDataX(:, Indx_S, :));
    [~, p, ~, stats] = ttest(Data1, DataBL);
    [~, sig] = fdr(p, StatsP.Alpha);
    
    Stats.pvalues(Indx_S, :) = p;
    Stats.sig(Indx_S, :) = sig;
    Stats.df(Indx_S, :) = stats.df;
    Stats.tvalues(Indx_S, :, :)= stats.tstat;
    
    [Starts, Ends] = data2windows(sig);
    Starts = dsearchn(X', Midpoints(Starts)');
    Ends = dsearchn(X', Midpoints(Ends)');
    
    SigData = nan(1, numel(X));
    for Indx_St = 1:numel(Starts)
        SigData(Starts(Indx_St):Ends(Indx_St)) = MeanDataP(Indx_S, Starts(Indx_St):Ends(Indx_St));
        
    end
    
    if xLog
        scatter(log(X), SigData, Format.LW*4, Colors(Indx_S, :), 'filled', ...
            'HandleVisibility','off')
        if Indx_S == BL_Indx+1
            plot(log(X), SigData, 'LineWidth', Format.LW, 'Color', Colors(Indx_S, :), ...
                'HandleVisibility','on')
        else
            plot(log(X), SigData, 'LineWidth', Format.LW, 'Color', Colors(Indx_S, :), ...
                'HandleVisibility','off')
        end
    else
        scatter(X, SigData, Format.LW*4, Colors(Indx_S, :), 'filled', ...
            'HandleVisibility','off')
        if Indx_S == BL_Indx+1
            plot(X, SigData, 'LineWidth', Format.LW, 'Color', Colors(Indx_S, :), ...
                'HandleVisibility','on')
        else
            plot(X, SigData, 'LineWidth', Format.LW, 'Color', Colors(Indx_S, :), ...
                'HandleVisibility','off')
        end
    end
end

set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize)

if ~isempty(LineLabels)
    Sig = ['p < ', num2str(StatsP.Alpha)];
    legend([LineLabels, Sig])
end