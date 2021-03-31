function rmSnippet(EEG, StartTime, EndTime, Channel)
% function for C_Cuts in preprocessing to remove a snippet

m = matfile(EEG.CutFilepath,'Writable',true);

Content = whos(m);

if ~ismember('cutData', {Content.name})
    m.cutData = nan(size(EEG.data)); % for plotting purposes
end

fs = EEG.srate;
Start = round(StartTime*fs);
End = round(EndTime*fs);

% handle incorrect inputs
if Start < 1
    Start = 1;
end

if End > pnts
    End = pnts;
end

if Channel < 1 || Channel > ch
    error('Not a real channel')
end

m.cutData(Channel, Start:End) = EEG.data(Channel, Start:End);
