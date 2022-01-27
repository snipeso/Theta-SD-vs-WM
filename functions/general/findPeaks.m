function [Peaks, Amps, Proms] = findPeaks(Data, Range, Freqs, toSmooth)
% finds the peak frequency by row of Data in specific range. Data is a ch x
% freqs array

Dims = size(Data);

if Dims(2) == 1
    Dims = flip(Dims);
    Data = Data';
end

Peaks = nan(Dims(1), 1);
Amps = Peaks;
Proms = Peaks;

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
% figure
%     findpeaks(D, F, 'Annotate','extents')
    if isempty(pks)
        Amps(Indx_Ch) = nan;
        Peaks(Indx_Ch) = nan;
    else
        [Amps(Indx_Ch), Indx] = max(pks);
        Peaks(Indx_Ch) = locs(Indx);
        
        % find prominence as amplitude until change in direction found
         [~, locs] = findpeaks(-D);
         if isempty(locs)
             Proms(Indx_Ch) = max(pks) - min(D);
         else
        Switch = dsearchn(locs', find(pks(Indx)==D)); % closest switch in direction to peak
         Proms(Indx_Ch) = max(pks) - D(locs(Switch));
         end
       
    end
end
