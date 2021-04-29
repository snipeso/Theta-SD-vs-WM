function rmCh_postICA(CutFilename, Ch)
% function for C_Cuts in preprocessing to remove a channel

if any(Ch < 1) || any(Ch > 128)
    warning('not real channels!')
    return
end

m = matfile(CutFilename,'Writable',true);

Content = whos(m);
if ismember('badchans', {Content.name})
   badchans = m.badchans;
else
    badchans = [];
end

% make sure only channels not already removed are in list
Ch = setdiff(Ch, badchans);
if isempty(Ch)
    return
end

% identify new channel indices based on the bad channels already removed
OldChannels = 1:128;
OldChannels(badchans) = [];

Ch = find(ismember(OldChannels, Ch));

if ismember('badchans_postICA', {Content.name})
    Ch = [m.badchans_postICA, Ch];
end

m.badchans_postICA = Ch;