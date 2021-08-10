function SmoothData = smoothFreqs(Data, Freqs)
% function for smoothing data (so that I'm consistent in all the code).
% Data is a 1 x Freqs matrix.

SmoothSpan = 1; % Hz

FreqRes = Freqs(2)-Freqs(1);
SmoothPoints = round(SmoothSpan/FreqRes);

SmoothData = smooth(Data, SmoothPoints, 'lowess');