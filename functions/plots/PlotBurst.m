function Title = PlotBurst(EEG, Start, Stop, ProtoChannel, Bands, Format)
% plots a burst with a butterfly plot, then broken down into the 4 power
% bands, and a butterfly plot for power

fs = EEG.srate;
Data = EEG.data(:, round(Start*fs):round(Stop*fs));
ProtoChannelIndx = labels2indexes(ProtoChannel, EEG.chanlocs);
Window =  Stop-Start;
BandLabels = fieldnames(Bands);

% plot EEG data butterfly plot
t = linspace(0, Window,  size(Data,2));
MidY = mean( Data(ProtoChannelIndx, :));
Range = max(MidY-min(Data(:)), max(Data(:))-MidY);

figure('units','normalized','outerposition',[0 0 .5 .6])
subplot(3, 4, [1:4])
hold on
plot(t, Data', 'Color', [.8 .8 .8 .5])
plot(t, Data(ProtoChannelIndx, :), 'Color', [Format.Colors.Red], 'LineWidth', 3)
ylim([MidY-Range, MidY+Range])
title('EEG')
xlabel('Time (s)')
set(gca, 'FontName', Format.FontName, 'FontSize', 14)
% axes('YColor','none');
% ax1 = gca;                   % gca = get current axis
% ax1.YAxis.Visible = 'off';

% plot power bands
Freqs = 1:1/Window:40;
[FFT, ~] = pwelch(Data', [], [], Freqs, fs);
bData = bandData(FFT', Freqs, Bands, 'last');
Subplots = [5 6 9 10];

for Indx_B = 1:numel(Subplots)
    subplot(3, 4, Subplots(Indx_B))
    topoplot(bData(:, Indx_B), EEG.chanlocs, 'style', 'map', 'headrad', 'rim', ...
        'whitebk', 'on', 'maplimits', 'minmax', 'gridscale', Format.TopoRes, 'emarker2', {[ProtoChannelIndx],'.',[.5 .5 .5]});
    colorbar
    title(BandLabels{Indx_B}, 'FontName', Format.FontName,  'FontSize', 14)
end

colormap(Format.Colormap.Linear)
% plot frequencies
subplot(3, 4, [7 8 11 12])
hold on
plot(Freqs, FFT', 'Color', [.8 .8 .8 .5])
plot(Freqs, FFT(:, ProtoChannelIndx), 'Color', Format.Colors.Red, 'LineWidth', 3)
xlim([1 35])
xlabel('Frequency (Hz)')
ylabel('Power')
Title = strjoin({num2str(Start), num2str(Window), num2str(ProtoChannel)}, '_');
set(gca, 'FontName', Format.FontName , 'FontSize', 14)
