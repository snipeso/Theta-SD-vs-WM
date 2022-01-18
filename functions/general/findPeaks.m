function [Peaks, Amps] = findPeaks(Data, Range, Freqs, toSmooth)
% finds the peak frequency by row of Data in specific range. Data is a ch x
% freqs array

Dims = size(Data);
Peaks = nan(Dims(1), 1);
Amps = Peaks;

% get location of frequencies within requested range
F_Indx = Freqs>=Range(1) & Freqs<=Range(2);

for Indx_Ch = 1:Dims(1)
    
    % select data in requested range
    D = Data(Indx_Ch, F_Indx);
    F = Freqs(F_Indx);
    
    % smooth the data
    if toSmooth
        D = smoothFreqs(D, F);
    end
    
    [pks, locs] = findpeaks(D, F);
    if isempty(pks)
        Amps(Indx_Ch) = nan;
        Peaks(Indx_Ch) = nan;
    else
        [Amps(Indx_Ch), Indx] = max(pks);
        Peaks(Indx_Ch) = locs(Indx);
    end
end
