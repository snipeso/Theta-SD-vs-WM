function plotBurstFig(EEG, Start, Stop, ProtoChannel, Bands, Space, Log, Color, Pixels)
% plots a burst with a butterfly plot, the specified band's topoplot, and
% the power spectrum

AmpLim = [0 390];
VoltLim = [-80 80];

LineColors = [.8 .8 .8 .2];

fs = EEG.srate;
Data = EEG.data(:, round(Start*fs):round(Stop*fs));
Points = size(Data,2);

PowerLabel = extractBetween(Pixels.Labels.Power, '(', ')');

Grid = [2, 6];

ProtoChannelIndx = labels2indexes(ProtoChannel, EEG.chanlocs);
Window =  Stop-Start;
t = linspace(0, Window,  Points);

%%% plot EEG data butterfly plot

subfigure(Space, Grid, [1, 1], [1, Grid(2)], Pixels.Numerals{1}, Pixels);
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
    plot(t, Data(ProtoChannelIndx(Indx_Ch), :), 'Color', Colors(Indx_Ch, :), 'LineWidth', Pixels.LW)
end

ylim(VoltLim)
xlabel(Pixels.Labels.Time)
ylabel(extractBetween(Pixels.Labels.Amplitude, '(', ')'))
set(gca, 'FontName', Pixels.FontName, 'FontSize', Pixels.FontSize)


%%% plot topoplot
Colormap = 'Monochrome';

% get power
[FFT, Freqs] = pwelch(Data', hanning(Points), 0, Points, fs);
bData = bandData(FFT', Freqs', Bands, 'last');

CLims = [min(bData), max(bData)];

% plot topo
A = subfigure(Space, Grid, [2, 1], [1 2], Pixels.Numerals{2}, Pixels);
A.Units = 'pixels';
A.Position(2) = A.Position(2)-Pixels.PaddingLabels;
A.Position(4) =  A.Position(4) + Pixels.PaddingLabels;

A.Position(1) = A.Position(1)-Pixels.PaddingLabels;
A.Position(3) =  A.Position(3) + Pixels.PaddingLabels;
A.Units = 'normalized';
topoplotTEMP(bData(:, 1), EEG.chanlocs, 'style', 'map', 'headrad', 'rim', ...
    'whitebk', 'on', 'maplimits', CLims, 'gridscale', Pixels.TopoRes, ...
    'electrodes', 'on', 'emarker2', {ProtoChannelIndx,'.',Colors});
set(A.Children, 'LineWidth', 1)

xlim([-.55 .55])
ylim([-.55 .6])

% % plot colorbar
% h = colorbar('Location', 'westoutside', 'AxisLocation', 'out');
% ylabel(h, PowerLabel, 'FontName', Format.FontName, 'FontSize', Format.Pixels.BarSize)
% 
% h.TickLength = 0;
% h.Position = [0.15, h.Position(2:end)];
% caxis(CLims)
% set(gca, 'FontName', Format.FontName, 'FontSize', Format.Pixels.BarSize)
% axis off

colormap(reduxColormap(Pixels.Colormap.(Colormap), Pixels.Steps.(Colormap)))


%%% plot spectrum
subfigure(Space, Grid, [2, 3], [1, Grid(2)-2], Pixels.Numerals{3}, Pixels);
hold on

if Log
    set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', log(Pixels.Labels.logBands))
    
    plot(log(Freqs), FFT', 'Color', LineColors)
    
    % plot prototype channels
    for Indx_Ch = 1:numel(ProtoChannel)
        plot(log(Freqs), FFT(:, ProtoChannelIndx(Indx_Ch)), ...
            'Color', Colors(Indx_Ch, :), 'LineWidth', Pixels.LW)
    end
    
    xticks(log(Pixels.Labels.logBands))
    xticklabels(Pixels.Labels.logBands)
    xlim(log(Pixels.Labels.FreqLimits))
    
else
    % plot all channels
    plot(Freqs, FFT', 'Color', [.8 .8 .8 .5])
    
    % plot prototype channels
    for Indx_Ch = 1:numel(ProtoChannel)
        plot(Freqs, FFT(:, ProtoChannelIndx(Indx_Ch)), ...
            'Color', Colors(Indx_Ch, :), 'LineWidth', Pixels.LW)
    end
    
    xlim(Pixels.Labels.FreqLimits)
end
xlabel(Pixels.Labels.Frequency)
ylabel(PowerLabel)
ylim(AmpLim)
yticks(AmpLim(1):100:AmpLim(2))
set(gca, 'XGrid', 'on', 'YGrid', 'on', 'FontName', Pixels.FontName, 'FontSize', Pixels.FontSize)
