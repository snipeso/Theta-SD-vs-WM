function [Peak, Amp] = bandPeak(Data, Freqs, Range)
% identifies peak frequency in specified range


Indx_Band = dsearchn(Freqs', Range');

Band = Data(Indx_Band(1):Indx_Band(2));

[pks, locs] = findpeaks(Band, Freqs(Indx_Band(1):Indx_Band(2)));

[~, Indx_Max] = max(pks);

Peak = locs(Indx_Max);
Amp = pks(Indx_Max);

if isempty(Peak) || ismember(Peak, Range)
    Peak = nan;
    Amp = nan;
end