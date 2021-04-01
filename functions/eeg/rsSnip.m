function rsSnip(EEG, StartTime, EndTime, Channel)
% function for C_Cuts in preprocessing to restore a snippet

m = matfile(EEG.CutFilepath,'Writable',true);

Content = whos(m);

fs = EEG.srate;
[ch, pnts] = EEG.data;

% get latencies in points
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

% set back to nan the values of the snippet matrix
if ismember('cutData', {Content.name})
    m.cutData(Channel, Start:End) = nan;
end
