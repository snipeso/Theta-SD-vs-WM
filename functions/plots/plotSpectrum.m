function plotSpectrum(Data, Freqs, LineLabels, Colors, Alpha, LineWidth, Log, PlotProps, Labels)
%  plotSpectrum(Data, Freqs, LineLabels, Colors, Alpha, LineWidth, Format)

% plot spectrums, but without any statistics. Data is n x Freq
Dims = size(Data);

hold on

if Log
    XLim = Labels.FreqLimits;
    plotFreqs = log(Freqs);
    
    % plot thin lines marking the theta range
    set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', log(Labels.logBands), ...
        'FontName', PlotProps.Text.FontName, 'FontSize', PlotProps.Text.AxisSize)
    
    xticks(log(Labels.logBands))
    xticklabels(Labels.logBands)
    xlim(log(XLim))
    
else
    XLim = [1 35];
    plotFreqs = Freqs;
    
    % plot thin lines marking the theta range
    set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', Labels.Bands, ...
        'FontName', PlotProps.Text.FontName, 'FontSize', PlotProps.Text.AxisSize)
    
    xlim(XLim)
end


for Indx = 1:Dims(1)
    if size(Colors, 1) == 1
        plot(plotFreqs, Data(Indx, :), 'LineWidth', LineWidth, 'Color', [Colors, Alpha])
    else
        plot(plotFreqs, Data(Indx, :), 'LineWidth', LineWidth, 'Color', [Colors(Indx, :), Alpha])
    end
end

% y limits
F = dsearchn(Freqs', XLim');
Min = min(Data(:, F(1):F(2)), [], 'all');
Max =  max(Data(:, F(1):F(2)), [], 'all');

ylim([Min Max])
ylabel(Labels.zPower)
xlabel(Labels.Frequency)


if ~isempty(LineLabels)
    legend(LineLabels)
end