function Clusters = segments2clusters(Segments)
% converts list of segments into clusters based on temporal overlap.
% Segments should be [Channels, Starts, Ends]
% Clusters is a struct, since it indicates all the channlels involved

Clusters = struct(); % has to be struct because can have different number of channels

for Indx_S = 1:size(Segments, 1)
    Start = Segments(Indx_S, 2);
    End = Segments(Indx_S, 3);
    
    OverlapWindowsIndx = (Segments(:, 2) <= Start & Segments(:, 3) >= Start) | ...
        (Segments(:, 2) <= End & Segments(:, 3) >= End);
    
    OverlapStarts = Segments(OverlapWindowsIndx, 2);
    OverlapEnds = Segments(OverlapWindowsIndx, 3);
    
    % assign the minimum start and max stop of all segments in cluster
    Segments(OverlapWindowsIndx, 2) = min(OverlapStarts);
    Segments(OverlapWindowsIndx, 3) = max(OverlapEnds);
end


% reformat as a structure
uniqueStarts = unique(Segments(:, 2));

for Indx_C = 1:numel(uniqueStarts)
    Clusters(end + 1).Start = uniqueStarts(Indx_C);
    Clusters(end).End = Segments(find(Segments(:, 2) == uniqueStarts(Indx_C), 1), 3);
    Clusters(end).Channels = Segments(Segments(:, 2) == uniqueStarts(Indx_C), 1)';
end

Clusters(1) = []; % stupid hack I don't feel like fixing