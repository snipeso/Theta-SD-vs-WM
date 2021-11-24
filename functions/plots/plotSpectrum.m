function plotSpectrum(Data, Freqs, LineLabels, Colors, Alpha, LineWidth, Log, Format)
%  plotSpectrum(Data, Freqs, LineLabels, Colors, Alpha, LineWidth, Format)

% plot spectrums, but without any statistics. Data is n x Freq
Dims = size(Data);

hold on

if Log
    XLim = [2 35];
    plotFreqs = log(Freqs);
    
    % plot thin lines marking the theta range
    set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', log(Format.Labels.Bands), ...
        'FontName', Format.FontName, 'FontSize', Format.FontSize)
    
    xticks(log(Format.Labels.Bands))
    xticklabels(Format.Labels.Bands)
    xlim(log(XLim))
    
else
    XLim = [1 35];
    plotFreqs = Freqs;
    
    % plot thin lines marking the theta range
    set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', Format.Labels.Bands, ...
        'FontName', Format.FontName, 'FontSize', Format.FontSize)
    
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
ylabel(Format.Labels.zPower)
xlabel(Format.Labels.Frequency)


if ~isempty(LineLabels)
    legend(LineLabels)
end