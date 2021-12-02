function plotBurstFig(EEG, Start, Stop, ProtoChannel, Bands, Space, Log, Color, Format)
% plots a burst with a butterfly plot, the specified band's topoplot, and
% the power spectrum

AmpLim = [0 390];
VoltLim = [-80 80];

LineColors = [.8 .8 .8 .2];

fs = EEG.srate;
Data = EEG.data(:, round(Start*fs):round(Stop*fs));
Points = size(Data,2);

PowerLabel = extractBetween(Format.Labels.Power, '(', ')');

Grid = [2, 6];

ProtoChannelIndx = labels2indexes(ProtoChannel, EEG.chanlocs);
Window =  Stop-Start;
t = linspace(0, Window,  Points);

%%% plot EEG data butterfly plot

subfigure(Space, Grid, [1, 1], [1, Grid(2)], Format.Numerals{1}, Format);
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
    plot(t, Data(ProtoChannelIndx(Indx_Ch), :), 'Color', Colors(Indx_Ch, :), 'LineWidth', Format.Pixels.LW)
end

ylim(VoltLim)
xlabel(Format.Labels.Time)
ylabel(extractBetween(Format.Labels.Amplitude, '(', ')'))
set(gca, 'FontName', Format.FontName, 'FontSize', Format.Pixels.FontSize)


%%% plot topoplot
Colormap = 'Monochrome';

% get power
[FFT, Freqs] = pwelch(Data', hanning(Points), 0, Points, fs);
bData = bandData(FFT', Freqs', Bands, 'last');

CLims = [min(bData), max(bData)];

% plot topo
A = subfigure(Space, Grid, [2, 1], [1 2], Format.Numerals{2}, Format);
A.Units = 'pixels';
A.Position(2) = A.Position(2)-Format.Pixels.PaddingLabels;
A.Position(4) =  A.Position(4) + Format.Pixels.PaddingLabels;

A.Position(1) = A.Position(1)-Format.Pixels.PaddingLabels;
A.Position(3) =  A.Position(3) + Format.Pixels.PaddingLabels;
A.Units = 'normalized';
topoplotTEMP(bData(:, 1), EEG.chanlocs, 'style', 'map', 'headrad', 'rim', ...
    'whitebk', 'on', 'maplimits', CLims, 'gridscale', Format.TopoRes, ...
    'electrodes', 'on', 'emarker2', {ProtoChannelIndx,'.',Colors});


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

colormap(reduxColormap(Format.Colormap.(Colormap), Format.Steps.(Colormap)))


%%% plot spectrum
subfigure(Space, Grid, [2, 3], [1, Grid(2)-2], Format.Numerals{3}, Format);
hold on

if Log
    set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', log(Format.Labels.logBands))
    
    plot(log(Freqs), FFT', 'Color', LineColors)
    
    % plot prototype channels
    for Indx_Ch = 1:numel(ProtoChannel)
        plot(log(Freqs), FFT(:, ProtoChannelIndx(Indx_Ch)), ...
            'Color', Colors(Indx_Ch, :), 'LineWidth', Format.Pixels.LW)
    end
    
    xticks(log(Format.Labels.logBands))
    xticklabels(Format.Labels.logBands)
    xlim(log(Format.Labels.FreqLimits))
    
else
    % plot all channels
    plot(Freqs, FFT', 'Color', [.8 .8 .8 .5])
    
    % plot prototype channels
    for Indx_Ch = 1:numel(ProtoChannel)
        plot(Freqs, FFT(:, ProtoChannelIndx(Indx_Ch)), ...
            'Color', Colors(Indx_Ch, :), 'LineWidth', Format.Pixels.LW)
    end
    
    xlim(Format.Labels.FreqLimits)
end
xlabel(Format.Labels.Frequency)
ylabel(PowerLabel)
ylim(AmpLim)
yticks(AmpLim(1):100:AmpLim(2))
set(gca, 'XGrid', 'on', 'YGrid', 'on', 'FontName', Format.FontName, 'FontSize', Format.Pixels.FontSize)
