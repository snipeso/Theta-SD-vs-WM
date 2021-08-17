function plotSpectrum(Data, Freqs, LineLabels, Colors, Alpha, LineWidth, Format)
% plot spectrums, but without any statistics. Data is n x Freq

Dims = size(Data);


hold on
for Indx = 1:Dims(1)
    plot(Freqs, Data(Indx, :), 'LineWidth', LineWidth, 'Color', [Colors(Indx, :), Alpha])
    
end

% plot thin lines marking the theta range
set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', Format.Labels.Bands, ...
    'FontName', Format.FontName)


% y limits
XLim = [1, 40];
F = dsearchn(Freqs', XLim');
Min = min(Data(:, F(1):F(2)), [], 'all');
Max =  max(Data(:, F(1):F(2)), [], 'all');

ylim([Min Max])
xlim(XLim)
ylabel('Power')
xlabel('Frequency (Hz)')

if ~isempty(LineLabels)
    legend(LineLabels)
end