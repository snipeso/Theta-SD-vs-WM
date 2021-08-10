function plotSpectrumDiff(Data, Freqs, BL_Indx, LineLabels, Colors, Format)
% plots changes in power spectrum, highlighting significant frequencies
% different from specified BL_Indx. It also marks where the theta range is.
% Data is a P x S x Freq matrix.

% y limits
Means = squeeze(nanmean(Data, 1));
Min = min(Means(:));
Max = max(Means(:));

% stats unit
StatWidth = 0.25; % size of freuqency bin

% plot thin lines marking the theta range

set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', Format.Labels.Bands)

plotLineDiff(Data, Freqs, BL_Indx, LineLabels, StatWidth, Colors, Format)

ylim([Min Max])
xlim([1, 30])
ylabel('Power')
xlabel('Frequency (Hz)')