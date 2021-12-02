function EEG = rmNoise(EEG, Cuts_Filepath)
% removes all the data marked for removal so that only clean data is
% present. Use instead of nanNoise if upcoming analysis does not work well
% with NaNs.

m = matfile(Cuts_Filepath);

Cuts = m.TMPREJ;
try
    fs = m.srate;
catch
    error(['No srate for ', EEG.filename])
end

if ~isempty(m.TMPREJ)
    Cuts(:, 1) = convertFS(Cuts(:, 1), fs, EEG.srate);
    Ends =  convertFS(Cuts(:, 2), fs, EEG.srate);
    
    % deal with mistakes in cutting and rounding errors
    if any(Ends>size(EEG.data, 2))
        Diff = max(Ends) - size(EEG.data, 2);
        warning([num2str(Diff), ' extra samples'])
        
        if Diff > 10
            error(['Too much discrepancy for ', EEG.filename])
        end
        
        % set end to file end
        Ends(Ends>size(EEG.data, 2)) = size(EEG.data, 2);
    end
    
    Cuts(:, 2) = Ends;
    
    EEG = eeg_eegrej(EEG, eegplot2event(Cuts, -1));
    
end

EEG = eeg_checkset(EEG);

end




function Point = convertFS(Point, fs1, fs2)

Time = Point./fs1; % written out so my tired brain understands
Point = round(Time.*fs2);

end