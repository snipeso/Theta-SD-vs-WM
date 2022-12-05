function PlotSegment(EEG, Start, Stop, Channels, ProtoChannel, Color)
% channels is a cell array of lists of channel numbers

Freqs = 1:0.5:50;
plotFreqs = [2:2:15, 25];
% plotFreqs = [ 20, 25];
fs = EEG.srate;
% Colormap = flipud(colorcet('L17'));
Colormap = parula;

if ~exist('Color', 'var')
    Color = 'r';
end

 Data = EEG.data(:, round(Start*EEG.srate):round(Stop*EEG.srate));
    
 figure('units','normalized','outerposition',[0 0 .6 .3])
ProtoChannel = labels2indexes(ProtoChannel, EEG.chanlocs);
hold on
plot(Data', 'Color', [.7 .7 .7])
plot(Data(ProtoChannel, :), 'Color', Color, 'LineWidth', 2)
 set(gca,'visible','off')
set(gca,'xtick',[])
 %%% plot power

 % calculate FFT
 [FFT, ~] = pwelch(Data', [], [], Freqs, fs);
Labels = cell(size(Channels));
    
figure
hold on
for Indx = 1:numel(Channels)
    plot(Freqs, 10*log(mean(FFT(:, Channels{Indx}), 2)))
    Labels{Indx} = num2str(Channels{Indx});
end
legend(Labels)

figure('units','normalized','outerposition',[0 0 1 .3])
FreqsIndx =  dsearchn( Freqs', plotFreqs');
for Indx = 1:numel(plotFreqs)
    subplot(1, numel(plotFreqs), Indx)
    topoplot(10*log(FFT(FreqsIndx(Indx), :)), EEG.chanlocs, 'style', 'map', 'headrad', 'rim', 'electrodes', 'on');
    colorbar
    title([num2str(plotFreqs(Indx)), 'Hz'])
    
end

colormap(Colormap)

