function plotWaves(EEG, Start, End, Ch, Color, Format)
% plots little snippet of EEG to show case an oscillation

fs = EEG.srate;

axis off
Data = EEG.data(:, Start*fs:End*fs);

hold on
plot(Data', 'Color', [Format.Colors.Generic, Format.Alpha.Channels], 'LineWidth', 1)

Ch_Indx = labels2indexes(Ch, EEG.chanlocs);
plot(Data(Ch_Indx, :), 'Color', Color, 'LineWidth', 3)
axis tight
set(gca, 'Position', [0 0 1 1])