function plotSpectrumPeaks(Spectrum, Peaks, Freqs, LineLabels, Colors, Alpha, LineWidth, Format)
% plots both the spectrum and the peaks asked for. Spectrum is a m x Freq
% matrix, Peaks is a m x 1 matrix.

Dims = size(Spectrum);

hold on
for Indx = 1:Dims(1)
    
    
    F_Indx = dsearchn(Freqs', Peaks(Indx));
    Amp = Spectrum(Indx, F_Indx);
    
    plot(Freqs, Spectrum(Indx, :), 'LineWidth', LineWidth, 'Color', [Colors(Indx, :), Alpha])
    plot(Freqs([F_Indx, F_Indx]), [0, Amp], 'LineWidth', 1, 'Color', [Colors(Indx, :), Alpha], 'HandleVisibility', 'off')
    scatter(Freqs(F_Indx), Amp, 20, Colors(Indx, :), 'filled', 'MarkerFaceAlpha', Alpha,  'HandleVisibility', 'off')
end

% plot thin lines marking the band ranges
set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', Format.Labels.Bands, ...
    'FontName', Format.FontName)


% y limits
XLim = [1, 40];
F = dsearchn(Freqs', XLim');
Min = min(Spectrum(:, F(1):F(2)), [], 'all');
Max =  max(Spectrum(:, F(1):F(2)), [], 'all');

ylim([Min Max])
xlim(XLim)
ylabel('Power')
xlabel('Frequency (Hz)')

if ~isempty(LineLabels)
    legend(LineLabels)
end