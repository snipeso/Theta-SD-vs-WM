function bData = bandData(Data, Freqs, Bands, fDim)
% script for combining matrix of EEG power data into frequency bands. It's
% in this stupid format so that if I ever figure out a better way, I can
% change it all at once.

Dims = size(Data);
BandLabels = fieldnames(Bands);
FreqRes = Freqs(2)-Freqs(1);

switch numel(Dims)
    case 5
        bData = nan();
        
    otherwise
        error('dimention not known')
end

switch fDim
    case 'last'
        bData = nan([Dims(1:end-1), numel(BandLabels)]);
        
        for Indx_P = 1:size(Data, 1)
            for Indx_B = 1:numel(BandLabels)
                Band = Bands.(BandLabels{Indx_B});
                Band = dsearchn(Freqs', Band');
                
                switch numel(Dims)
                    case 5
                        D = Data(Indx_P, :, :, :, Band(1):Band(2));
                        D = nansum(D, 5).*FreqRes;
                        bData(Indx_P, :, :, :, Indx_B) = D;
                    otherwise
                        disp('unknown number of dimentions')
                end
                
            end
        end
    otherwise
        % TODO
end