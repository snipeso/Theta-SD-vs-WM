function rsCh_postICA(CutFilepath, Ch)
% function for C_Cuts in preprocessing to restore a channel

if any(Ch < 1) || any(Ch > 128)
    error('not real channels!')
end

m = matfile(CutFilepath,'Writable',true);

Content = whos(m);

if ismember('badchans', {Content.name})
   badchans = m.badchans;
else
    badchans = [];
end

OldChannels = 1:128;
OldChannels(badchans) = [];

Ch = find(ismember(OldChannels, Ch)); % get new location

if ismember('badchans_postICA', {Content.name})
   m.badchans_postICA(ismember(m.badchans_postICA, Ch)) = [];
end
    