function Index = getBestElectrode(EEG, Channels)
% Channels should be list of electrodes in the order in which you'd prefer
% them. This provides the index of the first that is present in the data

Index = [];


Channels = string(Channels);

EEG_Channels = {EEG.chanlocs.labels};


if size(Channels, 1) == 1 || size(Channels, 2) == 1
    if isempty(intersect(EEG_Channels, Channels))
        warning(['No channels were found for ', EEG.filename])
        return
    end
    
    First = find(ismember(Channels, EEG_Channels), 1, 'first');
    Index = find(strcmp(EEG_Channels,  Channels(First)));

elseif size(Channels, 2) == 2 % check if there's 2 columns
    
    % check if there's a channel for both columns
    if isempty(intersect(EEG_Channels, Channels(:, 1))) || isempty(intersect(EEG_Channels, Channels(:, 2)))
        warning(['No channels were found for ', EEG.filename])
        return
    end
    
    % try and find the first pair that is present in the data
    FirstPair = find(all(ismember(Channels, EEG_Channels), 2), 1, 'first');
    if ~isempty(FirstPair)
        First1 = FirstPair;
        First2 = FirstPair;
    else
        % otherwise, take the first of each list
        First1 = find(ismember(Channels(:, 1), EEG_Channels), 1, 'first');
        First2 =  find(ismember(Channels(:, 2), EEG_Channels), 1, 'first');
    end
    
    % get the indexes in the channel structure
    Index = [find(strcmp(EEG_Channels,  Channels(First1, 1))),  find(strcmp(EEG_Channels,  Channels(First2, 2)))];
    if First1 ~= 1 || First2 ~= 1
        disp(join(['Using ch', EEG_Channels{Index}, 'instead of', Channels(1, :), 'for' EEG.filename], ' '))
    end
    
else
    error('wrong size of matrix')
end

