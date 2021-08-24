function EEG = rmNaN(EEG)
% properly removes all data marked by NaNs

isNaN = isnan(mean(EEG.data, 1));

[Starts, Ends] = data2windows(isNaN); 

EEG = pop_select(EEG, 'nopoint', [Starts(:), Ends(:)]);