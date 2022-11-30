function plotBurstFig2(EEG, Start, Stop, ProtoChannel, Bands, Space, Log, Color, PlotProps, Labels)
% plots a burst with a butterfly plot, the specified band's topoplot, and
% the power spectrum

AmpLim = [0 390];
VoltLim = [-80 80];

LineColors = [.8 .8 .8 .2];

fs = EEG.srate;
Data = EEG.data(:, round(Start*fs):round(Stop*fs));
Points = size(Data,2);

PowerLabel = extractBetween(Labels.Power, '(', ')');

Grid = [2, 6];

ProtoChannelIndx = labels2indexes(ProtoChannel, EEG.chanlocs);
Window =  Stop-Start;
t = linspace(0, Window,  Points);


%%% plot EEG data butterfly plot


figure('Units','centimeters', 'Position',[0 0 22 10])
hold on

% every channel
plot(t, Data', 'Color', LineColors)

% prototype channels
if ~isempty(Color)
    Colors = Color;
else
    Colors =  getColors(numel(ProtoChannel));
end
for Indx_Ch = 1:numel(ProtoChannel)
    plot(t, Data(ProtoChannelIndx(Indx_Ch), :), 'Color', Colors(Indx_Ch, :), 'LineWidth', PlotProps.Line.Width)
end

ylim(VoltLim)
xlabel(Labels.Time)
ylabel(extractBetween(Labels.Amplitude, '(', ')'))
set(gca, 'FontName', PlotProps.Text.FontName, 'FontSize', PlotProps.Text.AxisSize)


%%% get power
[FFT, Freqs] = pwelch(Data', hanning(Points), 0, Points, fs);
bData = bandData(FFT', Freqs', Bands, 'last');

CLims = [min(bData), max(bData)];


%%% plot spectrum
figure('Units','centimeters', 'Position',[0 0 20 12])
hold on
if Log
    set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', log(Labels.logBands))
    
    plot(log(Freqs), FFT', 'Color', LineColors)
    
    % plot prototype channels
    for Indx_Ch = 1:numel(ProtoChannel)
        plot(log(Freqs), FFT(:, ProtoChannelIndx(Indx_Ch)), ...
            'Color', Colors(Indx_Ch, :), 'LineWidth', PlotProps.Line.Width)
    end
    
    xticks(log(Labels.logBands))
    xticklabels(Labels.logBands)
    xlim(log(Labels.FreqLimits))
    
else
    
    % plot all channels
    plot(Freqs, FFT', 'Color', LineColors)
    
    % plot prototype channels
    for Indx_Ch = 1:numel(ProtoChannel)
        plot(Freqs, FFT(:, ProtoChannelIndx(Indx_Ch)), ...
            'Color', Colors(Indx_Ch, :), 'LineWidth', PlotProps.Line.Width)
    end
    
    xlim(Labels.FreqLimits)
end

xlabel(Labels.Frequency)
ylabel(PowerLabel)
ylim(AmpLim)
yticks(AmpLim(1):100:AmpLim(2))
set(gca, 'XGrid', 'on', 'YGrid', 'on', 'FontName', PlotProps.Text.FontName, 'FontSize', PlotProps.Text.AxisSize)



%%% plot topoplot
Colormap = 'Monochrome';

% plot topo
figure('Units','centimeters', 'Position',[0 0 7 7])

topoplotTEMP(bData(:, 1), EEG.chanlocs, 'style', 'map', 'headrad', 'rim', ...
    'whitebk', 'on', 'maplimits', CLims, 'gridscale', PlotProps.External.EEGLAB.TopoRes, ...
    'electrodes', 'on', 'emarker2', {ProtoChannelIndx,'.',Colors});
A = gca;
set(A.Children, 'LineWidth', 1)

xlim([-.55 .55])
ylim([-.55 .6])

colormap(reduxColormap(PlotProps.Color.Maps.(Colormap), PlotProps.Color.Steps.(Colormap)))