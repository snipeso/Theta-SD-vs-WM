function plotSpectrumDiff(Data, Freqs, BL_Indx, Bands, LineLabels, Colors, Format)
% plots changes in power spectrum, highlighting significant frequencies
% different from specified BL_Indx. It also marks where the theta range is.
% Data is a P x S x Freq matrix.

% y limits
Means = squeeze(nanmean(Data, 1));
Min = min(Means(:));
Max = max(Means(:));

% stats unit
StatWidth = 0.5; % size of freuqency bin

% plot thin lines marking the theta range
LineColor = [.5 .5 .5];
hold on
plot([Bands.Theta(1), Bands.Theta(1)], [Min Max], ':', 'Color', LineColor, 'HandleVisibility','off')
plot([Bands.Theta(2), Bands.Theta(2)], [Min Max], ':', 'Color', LineColor, 'HandleVisibility','off')

plotLineDiff(Data, Freqs, BL_Indx, LineLabels, StatWidth, Colors, Format)

ylim([Min Max])
xlim([1, 30])
ylabel('Power')
xlabel('Frequency (Hz)')