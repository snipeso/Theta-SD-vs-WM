function EEGshort = keepEEG(EEG, Minutes)
% little function to select a specified amount of time from the beginning
% of an EEG file, while also accepting having a little less than that.
% If Minutes is negative, it takes from the end.

fs = EEG.srate;


if abs(Minutes)*60*fs >= size(EEG.data, 2) % use whole file
   
    warning([EEG.filename, ' has only ', num2str(round(size(EEG.data, 2)/fs)/60), ...
        ' minutes but requested ', num2str(Minutes)])
    EEGshort = EEG;
    
elseif Minutes < 0 % get end of file
    
    TotT = size(EEG.data, 2)/EEG.srate;
    EEGshort = pop_select(EEG, 'time', [TotT+Minutes*60, TotT]);
    
else % get start of tile
    EEGshort = pop_select(EEG, 'time', [0 Minutes*60]);
end