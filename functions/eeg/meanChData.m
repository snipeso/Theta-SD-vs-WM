function NewData = meanChData(Data, Chanlocs, ChannelStruct, ChDim)
% ChannelStruct is a structure, with each field holding a set of channels
% to average together.

Dims = size(Data);
TotDims = numel(Dims);
ChLabels = fieldnames(ChannelStruct);

% create new matrix with the number of channels replaced with the number of
% averaged groups of channels
Dims(ChDim) = numel(ChLabels);
NewData = nan(Dims);


switch ChDim
    case 4
        for Indx_Ch = 1:numel(ChLabels)
            Ch = ChannelStruct.(ChLabels{Indx_Ch});
            Ch = labels2indexes(Ch, Chanlocs);
            
            switch TotDims
                case 5
                    NewData(:, :, :, Indx_Ch, :) = nanmean(Data(:, :, :, Ch, :), ChDim);
                otherwise
                    error("Don't know this dimention (total matrix size)")
            end
        end 
    otherwise
        error("Don't know this dimention (channel dimention)")
end