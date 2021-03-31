function rmCh(CutFilename, Ch)
% function for C_Cuts in preprocessing to remove a channel

if Ch < 1 || Ch > 128
    error('not real channels!')
end

m = matfile(CutFilename,'Writable',true);

Content = whos(m);
if ismember('badchans', {Content.name})
   m.badchans = [m.badchans, Ch];
else
    m.badchans = Ch;
end
    