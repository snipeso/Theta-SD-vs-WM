function Segments = nandata2windows(EEGdata)
% function takes a matrix of ch x timepoints, mostly nans, and identifies the
% starts and stops of all the non-nan segments.
% Segments is [Channels, Starts, Ends]

Segments = [];

[Channels, ~] = size(EEGdata);

for Indx_Ch = 1:Channels
    
    Ch = ~isnan(EEGdata(Indx_Ch, :)); % get 1 for all data remaining, 0 otherwise
    
    [Starts, Ends] = data2windows(Ch);
    
    Segments = append(1, Segments, [Indx_Ch*ones(numel(Starts), 1), Starts(:), Ends(:)]);
end