function Stats = plotSpectrumDiff(Data, AllFreqs, BL_Indx, LineLabels, Colors, Log, Format, StatsP)
% plots changes in power spectrum, highlighting significant frequencies
% different from specified BL_Indx. It also marks where the theta range is.
% Data is a P x S x Freq matrix.

XLims = Format.Labels.FreqLimits;

XIndx = dsearchn(AllFreqs', XLims');

Data = Data(:, :, XIndx(1):XIndx(2));
Freqs = AllFreqs(XIndx(1):XIndx(2));

% y limits
Means = squeeze(nanmean(Data, 1));
Min = min(Means(:));
Max = max(Means(:));

% stats unit
StatWidth = StatsP.FreqBin; % # frequencies to pool

% plot thin lines marking the band ranges
if Log
    set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', log(Format.Labels.logBands))
    Stats = plotLineDiff(Data, Freqs, BL_Indx, LineLabels, StatWidth, Colors, Log, Format, StatsP);
    xticks(log(Format.Labels.logBands))
    xticklabels(Format.Labels.logBands)
    xlim(log(Freqs([1, end])))
   
else
    set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', Format.Labels.Bands)
    Stats = plotLineDiff(Data, Freqs, BL_Indx, LineLabels, StatWidth, Colors, Log, Format, StatsP);
        
        xticks(Format.Labels.Bands)
    xticklabels(Format.Labels.Bands)
    
  xlim(Freqs([1, end]))
end

Stats.freqs = Freqs;
Stats.lines = LineLabels;
Stats.lines(BL_Indx) = [];
Stats.pvalues(BL_Indx, :) = [];
Stats.df(BL_Indx, :) = [];
Stats.sig(BL_Indx, :) = [];
Stats.tvalues(BL_Indx, :) = [];
Stats.p_fdr(BL_Indx, :) = [];
Stats.crit_p(BL_Indx) = [];

ylim([Min Max])
ylabel(Format.Labels.zPower)
xlabel(Format.Labels.Frequency)