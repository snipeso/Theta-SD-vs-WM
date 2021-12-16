function [pks, locs, prom, width] = peakfinder_topo(Data, X, Y, Z, minProminence)
% function for finding peaks in a topoplot.
% [pks, locs, prom] = peakfinder_topo(Data, Chanlocs)

% Algorithm:
% 1) loop through channels until you find the highest value
% 2) find it's immediate neighbors
% 3) see if any neighbor increases with respect to the peak
% 4) if none of the neighbors increase, repeat steps 2-3 for the neighbors,
% and so on until the whole grid has been searched
% 5) when either an increase or the whole grid has been searched, identify
% the prominence of that peak, save info to the outcome variables
% 6) continue through list of electrodes steps 2-5


if ~exist('minProminence', 'var')
    minProminence = 0;
end

pks = []; % Data value peaks
locs = []; % index of the peak
prom = []; % prominance with respect to the closest change in direction
width = [];

AllCh = 1:numel(Data);

% get neighbors matrix
Distances = getDistances(X, Y, Z);
Distances(1:numel(Data)+1:numel(Distances)) = nan;

% get Data in array, saviing corresponding chanlocs, by amplitude
[Data_Ordered, Order] = sort(Data, 'descend');

% loop through array
for Indx_Ch = 1:numel(Data)
    
    % if nan, skip
    if isnan(Data_Ordered(Indx_Ch))
        continue
    end
    
    % get the index of the peak
    Ch_ID = Order(Indx_Ch);
    
    
    %%% find the base of the peak
    
    EdgeCh = Ch_ID; % variable indicating from where to start looking at descent. So start from peak
    goesUp = []; % variable keeping track of which channels switch direction
    flipPoints = []; % keeps track of all the lowest points of the current peak when there's a direction flip
    goesDown = Ch_ID; % variable keeping track of which channels are involved in the peak
    
    while isempty(goesUp) % keep searching until a channel switching directions is found
        
        NextEdge = []; % variable keeping track of where the new edge is
        
        for Ch = EdgeCh % loop through all channels in current edge
            
            % identify neighbors, ignoring "isoline" channels and channels
            % already involved in peak
            Min_D = min(Distances(:, Ch)); % find closest distance
            Remaining = setdiff(AllCh, goesDown);
            Neighbors = Remaining(Distances(Remaining, Ch) < Min_D*1.5);
            
            % see which direction neighbors go in with respect to edge point
            Descend = Data(Neighbors) <= Data(Ch)+minProminence;
            
            if isempty(Descend) % if there are no more neighbors to search throuh
                continue
            elseif all(Descend)
                NextEdge = union(NextEdge, Neighbors); % add neighbors to upcoming edge
                
            elseif any(~Descend) % jackpot!
                goesUp = union(goesUp, Neighbors(~Descend)); % get all channels that flip direction, so that can later pick the one is closest
                flipPoints = cat(2, flipPoints, Data(Ch));
            end
        end
        
        goesDown = union(goesDown, NextEdge); % add new edge to peak channels
        
        % if all channels have been searched, leave loop
        if all(ismember(AllCh, goesDown)) % CHECK
            goesUp = [];
            break
        else
            EdgeCh = reshape(NextEdge, 1, []); % now next loop is done on outer rim electrodes
        end
    end
    
    
    if numel(goesDown) > 1 % save as peak if there's more than one channel
        
        %%% calculate prominence of peak respect to rest of data
        if isempty(goesUp) % if only one peak, then just span of data
            Prominance = max(Data) - min(Data);
            
        else
            Prominance = Data(Ch_ID) -  max(flipPoints);
        end
        
        
        pks = [pks; Data(Ch_ID)];
        locs = [locs; Ch_ID];
        prom = [prom; Prominance];
        width = [width; numel(goesDown)];
        
    end
    
    % remove from data ordered the channels involved in the descent
    Data_Ordered(ismember(Order, goesDown)) = nan; % CHECK
    
end
% the loop will end when there are no more channels marked as nan




