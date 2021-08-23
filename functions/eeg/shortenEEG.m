function EEG = shortenEEG(EEG, Duration)
% gives as much data as specified, ignoring nans. Duration is in minutes.

fs = EEG.srate;

TotKeepPoints = Duration*60*fs;

Nans = mean(EEG.data,1);

NotNan = ~isnan(Nans);

if nnz(NotNan) <= TotKeepPoints
    warning([EEG.filename, ' has only ', num2str(round((nnz(NotNan)/fs)/60)), ' minutes'])
    return
end


KeepPoints = find(NotNan, TotKeepPoints);