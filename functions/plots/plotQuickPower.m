function plotQuickPower(EEG, Color, Start, End, PlotProps)

WelchWindow = 8; % duration of window to do FFT
Overlap = .75; % overlap of hanning windows for FFT

fs = EEG.srate;

EEGshort = pop_select(EEG, 'time', [Start, End]);

nfft = 2^nextpow2(WelchWindow*fs);
noverlap = round(nfft*Overlap);
window = hanning(nfft);
[Power, Freqs] = pwelch(EEGshort.data', window, noverlap, nfft, fs);


figure('Units','normalized', 'Position',[0 0 .4 .4])
hold on
plot(Freqs, log(Power), 'Color', [.6 .6 .6 .2], 'LineWidth', .5)

plot(Freqs, mean(log(Power), 2), 'Color', Color, 'LineWidth', 4)
axis tight
ylabel('Log Power')
xlabel('Frequency')
xlim([0 65])
setAxisProperties(PlotProps)