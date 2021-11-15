function rsCh_postICA(CutFilepath, Ch)
% function for C_Cuts in preprocessing to restore a channel

if any(Ch < 1) || any(Ch > 128)
    error('not real channels!')
end

m = matfile(CutFilepath,'Writable',true);

Content = whos(m);

if ismember('badchans_postICA', {Content.name})
   m.badchans_postICA(ismember(m.badchans_postICA, Ch)) = [];
end
    