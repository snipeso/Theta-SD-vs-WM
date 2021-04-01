function [Starts, Ends] = data2windows(Array, Threshold)
% Takes an array of numbers. If the data is not 1s and 0s, then it uses the
% threshold to convert into windows above the threshold. If no threshold is
% provided, then it will take all positive values as above threshold. If
% you want everything below a threshold, just provide both values as
% negative

Array = reshape(Array, 1, []); % make sure its a 1 x n array

% convert data if it's not already binary
if any(Array ~= 0 & Array~=1)
    
   % set threshold to 0 if none provided
   if ~exist('Threshold', 'var')
       Threshold = 0;
       warning('No threshold provided, so using 0')
   end

   Array = Array > Threshold;
end

% Convert to windows
Array = [0, Array, 0]; % make sure there's always a start and stop

% get edges
DataEdges = diff(Array);

Starts = find(DataEdges == 1); % starts are the first 1 value of a segment
Ends = find(DataEdges == -1) - 1;  % ends are the last value of a segment, shifted by 1 index

