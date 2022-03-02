function Title = PlotBurst(EEG, Start, Stop, ProtoChannel, Bands, Format)
% plots a burst with a butterfly plot, then broken down into the 4 power
% bands, and a butterfly plot for power

fs = EEG.srate;
Data = EEG.data(:, round(Start*fs):round(Stop*fs));
Points = size(Data,2);

ProtoChannelIndx = labels2indexes(ProtoChannel, EEG.chanlocs);
Window =  Stop-Start;
BandLabels = fieldnames(Bands);

% plot EEG data butterfly plot
t = linspace(0, Window,  Points);
MidY = mean( Data(ProtoChannelIndx, :));
Range = max(MidY-min(Data(:)), max(Data(:))-MidY);

Colors =  getColors(numel(ProtoChannel));

figure('units','normalized','outerposition',[0 0 1 1])
% figure('units','normalized','outerposition',[0 0 .5 .6])
subplot(3, 4, [1:4])
hold on
plot(t, Data', 'Color', [.8 .8 .8 .5])
plot(t, Data(ProtoChannelIndx, :), 'Color', Colors, 'LineWidth', 3)
ylim([MidY-Range, MidY+Range])
title('EEG')
xlabel('Time (s)')
set(gca, 'FontName', Format.Text.FontName, 'FontSize', Format.Text.AxisSize)
% axes('YColor','none');
% ax1 = gca;                   % gca = get current axis
% ax1.YAxis.Visible = 'off';

% plot power bands

[FFT, Freqs] = pwelch(Data', hanning(Points), 0, Points, fs);

bData = bandData(FFT', Freqs', Bands, 'last');
Subplots = [5 6 9 10];

for Indx_B = 1:numel(Subplots)
    subplot(3, 4, Subplots(Indx_B))
    topoplot(bData(:, Indx_B), EEG.chanlocs, 'style', 'map', 'headrad', 'rim', ...
        'whitebk', 'on', 'maplimits', 'minmax', 'gridscale', Format.External.EEGLAB.TopoRes, ...
         'electrodes', 'on', 'emarker2', {[ProtoChannelIndx],'.',Colors, 20});
    colorbar
    title(BandLabels{Indx_B}, 'FontName', Format.Text.FontName,  'FontSize', Format.Text.AxisSize)
end

colormap(reduxColormap(Format.Color.Maps.Linear, Format.Color.Steps.Linear))


FreqTicks = [];
for Indx_B = 1:numel(BandLabels)
   FreqTicks = [FreqTicks, Bands.(BandLabels{Indx_B})]; 
end

FreqTicks = unique(FreqTicks);

% plot frequencies
subplot(3, 4, [7 8 11 12])
hold on
plot(Freqs, FFT', 'Color', [.8 .8 .8 .5])
plot(Freqs, FFT(:, ProtoChannelIndx), 'Color', Colors, 'LineWidth', 3)
xlim([1 35])
xlabel('Frequency (Hz)')
ylabel('Power')
set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', FreqTicks, ...
    'FontName', Format.Text.FontName)
Title = strjoin({num2str(Start), num2str(Window), num2str(ProtoChannel)}, '_');
set(gca, 'FontName', Format.Text.FontName , 'FontSize', Format.Text.AxisSize)

