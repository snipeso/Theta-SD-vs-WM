function Title = PlotBurst2(EEG, Start, Stop, ProtoChannel, Bands, Format)
% plots a burst with a butterfly plot, the specified band's topoplot, and
% the power spectrum

fs = EEG.srate;
Data = EEG.data(:, round(Start*fs):round(Stop*fs));
Points = size(Data,2);

ProtoChannelIndx = labels2indexes(ProtoChannel, EEG.chanlocs);
Window =  Stop-Start;
BandLabels = fieldnames(Bands);

% plot EEG data butterfly plot
t = linspace(0, Window,  Points);

Colors =  getColors(numel(ProtoChannel));

figure('units','normalized','outerposition',[0 0 .4 .4])
subplot(2, 4, 1:4)
% tiledlayout(2, 4, 'Padding', 'none', 'TileSpacing', 'compact');
% 
% nexttile(1, [1, 4])
hold on
plot(t, Data', 'Color', [.8 .8 .8 .5])
for Indx_Ch = 1:numel(ProtoChannel)
    plot(t, Data(ProtoChannelIndx(Indx_Ch), :), 'Color', Colors(Indx_Ch, :), 'LineWidth', Format.LW)
end
ylim([-50 50])
xlabel('Time (s)')
set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize)

% plot topoplot
[FFT, Freqs] = pwelch(Data', hanning(Points), 0, Points, fs);

bData = bandData(FFT', Freqs', Bands, 'last');

CLims = [min(bData), max(bData)]; 
% nexttile
subplot(2, 4, 5)
topoplotTEMP(bData(:, 1), EEG.chanlocs, 'style', 'map', 'headrad', 'rim', ...
    'whitebk', 'on', 'maplimits', CLims, 'gridscale', Format.TopoRes, ...
    'electrodes', 'on', 'emarker2', {ProtoChannelIndx,'.',Colors});
set(gca, 'LineWidth', 1)
xlim([-.55 .55])
ylim([-.55 .6])

h = colorbar;
 ylabel(h, Format.Labels.Power, 'FontName', Format.FontName, 'FontSize', Format.BarSize)
 h.TickLength = 0;
caxis(CLims)
axis off
Colormap = 'Monochrome';
colormap(reduxColormap(Format.Colormap.(Colormap), Format.Steps.(Colormap)))
set(gca, 'FontName', Format.FontName, 'FontSize', Format.BarSize)

% plot spectrum
% nexttile(6, [1, 3])
subplot(2, 4, 6:8)
hold on
plot(Freqs, FFT', 'Color', [.8 .8 .8 .5])
for Indx_Ch = 1:numel(ProtoChannel)
    plot(Freqs, FFT(:, ProtoChannelIndx(Indx_Ch)), 'Color', Colors(Indx_Ch, :), 'LineWidth', 3)
end
xlim([1 35])
xlabel('Frequency (Hz)')
ylabel('Power')
set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', Format.Labels.Bands, ...
    'FontName', Format.FontName)
Title = strjoin({num2str(Start), num2str(Window), num2str(ProtoChannel)}, '_');
set(gca, 'FontName', Format.FontName , 'FontSize', Format.FontSize)

