function EEG = nanNoise(EEG, Cuts_Filepath)
% makes all data marked as a cut to nan

m = matfile(Cuts_Filepath);

Cuts = m.TMPREJ;
try
fs = m.srate;
catch
    error(['No srate for ', EEG.filename])
end

if ~isempty(m.TMPREJ)
    Starts = convertFS(Cuts(:, 1), fs, EEG.srate);
    Ends =  convertFS(Cuts(:, 2), fs, EEG.srate);
    
    if any(Ends>size(EEG.data, 2))
        Diff = max(Ends) - size(EEG.data, 2);
        warning([num2str(Diff), ' extra samples'])
        
        if Diff > 10
            error(['Too much discrepancy for ', EEG.filename])
        end
        
        % set end to file end
        Ends(Ends>size(EEG.data, 2)) = size(EEG.data, 2);
    end
    
    for Indx_N = 1:numel(Starts)
        EEG.data(:, Starts(Indx_N):Ends(Indx_N)) = nan;
    end
end
end


function Point = convertFS(Point, fs1, fs2)

Time = Point./fs1; % written out so my tired brain understands
Point = round(Time.*fs2);

end