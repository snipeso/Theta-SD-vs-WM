function rsCh(CutFilepath, Ch)
% function for C_Cuts in preprocessing to restore a channel

m = matfile(CutFilepath,'Writable',true);

Content = whos(m);
if ismember('badchans', {Content.name})
   m.badchans(ismember(m.badchans, Ch)) = [];
else
    m.badchans = Ch;
end
    