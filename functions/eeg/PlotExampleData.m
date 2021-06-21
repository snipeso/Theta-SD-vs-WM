function PlotExampleData(EEG, StartTime, StopTime, Channel, Color)
% plots a little segment of data, highlighting one channel

fs = EEG.srate;

Start = round(StartTime*fs);
Stop = round(StopTime*fs);

Data = EEG.data(:, Start:Stop);

figure('units','normalized', 'outerposition',[0 0 .6 .3])
ProtoChannel = labels2indexes(Channel, EEG.chanlocs);
hold on
plot(Data', 'Color', [.8 .8 .8 .5])
plot(Data(ProtoChannel, :), 'Color', Color, 'LineWidth', 3)
ylim([-200 200])
set(gca,'visible','off')
set(gca,'xtick',[])
set(gcf, 'InvertHardcopy', 'off')
set(gcf, 'Color', 'none');    
set(gca, 'Color', 'none');