
Data = [EEG.data(20, 406*fs:416*fs), EEG2.data(108, 750*fs:760*fs-1)];

% 20 s
AllPoints = numel(Data);
F = 1:0.05:20;

[FFT, Freqs] = pwelch(Data, hanning(AllPoints), 0, F, fs);

figure
plot(Freqs, FFT, 'Color', 'k', 'LineWidth', 2)
hold on


% 5 s
Points = 5*fs;
[FFT, Freqs] = pwelch(Data, hanning(Points), 0, F, fs);
plot(Freqs, FFT, 'Color', getColors(1, 'rainbow', 'red'), 'LineWidth', 2)


% 5s padding
AllFFT = nan(4, numel(F));
St = 1:Points:AllPoints-Points;
for Indx_S = 1:numel(St)
    D = [zeros(1, 7*fs), Data(St(Indx_S):St(Indx_S)+Points), zeros(1, 8*fs)];
    
    [FFT, Freqs] = pwelch(D, hanning(AllPoints), 0, F, fs);
    AllFFT(Indx_S, :) = FFT;
end
plot(Freqs, nanmean(AllFFT), 'Color', getColors(1, 'rainbow', 'yellow'), 'LineWidth', 2)

% 5 s (correct freqs)
F = 1:0.2:77;
[FFT, Freqs] = pwelch(Data, hanning(Points), 0, F, fs);
plot(Freqs, FFT, 'Color', getColors(1, 'rainbow', 'green'), 'LineWidth', 2)

legend({'20s (0.05Hz res)', '5s (0.05Hz res)', '5s, 0 padding (0.05Hz res)', '5s (0.2Hz res)'})
xlim([5 7])

