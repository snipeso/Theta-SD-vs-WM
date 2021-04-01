function Indexes = labels2indexes(Labels, Chanlocs)
% function for converting from labels to indexes

Labels = string(Labels);

ChanLabels = string({Chanlocs.labels});

[Members, Indexes] = ismember(Labels, ChanLabels);

Members = Members(:)';
Labels = Labels';

Indexes(Indexes == 0) = [];

if any(not(Members))
    warning(strjoin([ 'Chan ', Labels(not(Members))', ' not present in the chanlocs']))
end


