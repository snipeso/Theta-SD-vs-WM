function [Power, Freqs] = PowerTrials(EEG, Starts, Ends, Window)
% calculate welch power for trials

Chanlocs = EEG.chanlocs;
fs = EEG.srate;

% p welch parameters
nfft = 2^nextpow2(Window*fs);
noverlap = round(nfft*.75);
window = hanning(nfft);

nFreqs = nfft/2 + 1;
Power = nan(numel(Chanlocs), nFreqs, numel(Starts));

for Indx_S = 1:numel(Starts)
    Data = EEG.data(:, round(Starts(Indx_S):Ends(Indx_S)-1));
    
    % remove data with nan
    nanPoints = isnan(Data(1, :));
    Data(:, nanPoints) = [];

    if size(Data, 2) < nfft*.75 % if a lot less than nfft, skip
        continue
    elseif size(Data, 2) < nfft % zero pad if there's just a little missing data
        Pad = floor(nfft-size(Data, 2));
        pData = zeros(size(Data, 1), nfft);
        pData(:, Pad:size(Data, 2)+Pad-1) = Data;  
        
         [FFT, Freqs] = pwelch(pData', window, noverlap, nfft, fs);
    else
        
        [FFT, Freqs] = pwelch(Data', window, noverlap, nfft, fs);
    end
    
    Power(:, :, Indx_S) = FFT';
end

Freqs = Freqs';


