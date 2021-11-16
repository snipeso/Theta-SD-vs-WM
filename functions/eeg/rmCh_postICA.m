function rmCh_postICA(CutFilename, Ch)
% function for C_Cuts in preprocessing to remove a channel. Ch is saved as
% the absolute label, not the index within the matrix.

if any(Ch < 1) || any(Ch > 129)
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

if ismember('badchans_postICA', {Content.name})
    disp(['old postICA channels: ',  num2str(m.badchans_postICA)])
    Ch = [m.badchans_postICA, Ch];
end

m.badchans_postICA = Ch;
m.Fixed = true;

disp(['new postICA channels: ',  num2str(m.badchans_postICA)])