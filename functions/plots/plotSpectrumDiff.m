function Stats = plotSpectrumDiff(Data, Freqs, BL_Indx, LineLabels, Colors, Format, StatsP)
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
StatWidth = dsearchn(Freqs'-Freqs(1), StatWidth);

% plot thin lines marking the theta range

set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', Format.Labels.Bands)

Stats = plotLineDiff(Data, Freqs, BL_Indx, LineLabels, StatWidth, Colors, Format, StatsP);

ylim([Min Max])
xlim(XLims)
ylabel(Format.Labels.zPower)
xlabel('Frequency (Hz)')