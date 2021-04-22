function EEGnew = interpolateSnippets(EEG, badchans, cutData, cut_srate, PlotData)
% function for interpolating snippets of bad data from neighboring
% channels. For every snippet, it carves out a column of data, removes the
% channel, and interpolates it, then returns the column to the rest of the
% data.

EEGnew = EEG;

ChanLabels = {EEG.chanlocs.labels}; % list of channel labels

% get clusters of data to interpolate (overlapping segments)
% cutData(badchans, :) = []; % remove bad channels from cuts, so it matches the EEG

if isempty(cutData)
    return
    % elseif size(cutData, 1) ~= size(EEGnew.data, 1)
    %     error('not the same number of channels in cuts and in EEG data')
end

% convert matrix of nans to "table" indicating time points that aren't nan
Snippets = nandata2windows(cutData);
Snippets(:, 2:3) = Snippets(:, 2:3)/cut_srate; % convert into seconds

% ignore segments that are part of removed channels
Snippets(ismember(Snippets(:, 1), badchans), :) = [];

% group segments into clusters based on temporal overlap
Clusters = segments2clusters(Snippets);



%%% interpolate each cluster

for Indx_C = 1:size(Clusters, 2)
    
    % select the column of data of the current cluster
    Start = round(EEGnew.srate*Clusters(Indx_C).Start); % convert back to points of current EEG data
    End = round(EEGnew.srate*Clusters(Indx_C).End);
    
    if End > size(EEGnew.data, 2)
        End =  size(EEGnew.data, 2);
    end
    
    EEGmini =  pop_select(EEG, 'point', [Start, End]);
    
    if  isempty(EEGmini.data)
        warning(['Empty cluster during snippet interpolation for ', EEG.filename])
        continue
    end
    
    
    % select channels that won't be used for interpolation
    RemoveChannels = string(unique(Clusters(Indx_C).Channels));
    [~, RemoveChannelsIndx] = intersect(ChanLabels, RemoveChannels);
    
    EEGmini = pop_select(EEGmini, 'nochannel', RemoveChannelsIndx);
    
    
    % interpolate bad segments
    EEGmini = pop_interp(EEGmini, EEG.chanlocs);
    
    
    % replace interpolated data into new data structure
    EEGnew.data(:, Start:End) = EEGmini.data;
    
end


%%% Option to plot
if exist('PlotData', 'var') && PlotData
    eegplot(EEG.data, 'srate', EEG.srate, 'winlength', 30, 'data2', EEGnew.data)
    disp(['Starts:'])
    disp({Clusters.Start})
end


