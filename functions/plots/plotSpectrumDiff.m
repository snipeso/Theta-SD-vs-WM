function Stats = plotSpectrumDiff(Data, Freqs, BL_Indx, LineLabels, Colors, Log, Format, StatsP)
% plots changes in power spectrum, highlighting significant frequencies
% different from specified BL_Indx. It also marks where the theta range is.
% Data is a P x S x Freq matrix.

XLims = [1 35];

XIndx = dsearchn(Freqs', XLims');

Data = Data(:, :, XIndx(1):XIndx(2));
Freqs = Freqs(XIndx(1):XIndx(2));

% y limits
Means = squeeze(nanmean(Data, 1));
Min = min(Means(:));
Max = max(Means(:));

% stats unit
StatWidth = StatsP.FreqBin; % # frequencies to pool

% plot thin lines marking the band ranges
if Log
    set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', log(Format.Labels.Bands))
    Stats = plotLineDiff(Data, Freqs, BL_Indx, LineLabels, StatWidth, Colors, Log, Format, StatsP);
    xticks(log(Format.Labels.Bands))
    xticklabels(Format.Labels.Bands)
    xlim(log(XLims))
   
else
    set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', Format.Labels.Bands)
    Stats = plotLineDiff(Data, Freqs, BL_Indx, LineLabels, StatWidth, Colors, Log, Format, StatsP);
    xlim(XLims)
end

ylim([Min Max])
ylabel(Format.Labels.zPower)
xlabel(Format.Labels.Frequency)