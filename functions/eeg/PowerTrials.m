function Power = PowerTrials(EEG, Freqs, Starts, Ends, Window)
% calculate welch power for trials

Chanlocs = EEG.chanlocs;
fs = EEG.srate;

Power = nan(numel(Chanlocs), numel(Freqs), numel(Starts));

for Indx_S = 1:numel(Starts)
    Data = EEG.data(:, round(Starts(Indx_S):Ends(Indx_S)));
    
    % remove epochs with >1/3 nan values
    nanPoints = isnan(Data(1, :));
    if nnz(nanPoints) >  numel(nanPoints)/3
        continue
    end
    
    
    Data(:, nanPoints) = [];
    
    if size(Data, 2) < Window*fs
        W = size(Data, 2);
    else
        W = Window*fs;
    end
    [FFT, ~] = pwelch(Data', W, W/2, Freqs, fs);
   
    Power(:, :, Indx_S) = FFT';
end