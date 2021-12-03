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

for Indx_Ch = 1:numel(ChLabels)
    Ch = ChannelStruct.(ChLabels{Indx_Ch});
    Ch = labels2indexes(Ch, Chanlocs);
    switch ChDim
        case 1
            switch TotDims
                case 2 % e.g. ch x freq
                    NewData(Indx_Ch, :) = nanmean(Data(Ch, :), ChDim);
                    
                otherwise
                    error("Don't know this dimention (total matrix size)")
            end
        case 3
            switch TotDims
                case 4
                    NewData(:, :, Indx_Ch, :) = nanmean(Data(:, :, Ch, :), ChDim);
                otherwise
                    error("Don't know this dimention (total matrix size)")
            end
        case 4
            switch TotDims
                case 5
                    NewData(:, :, :, Indx_Ch, :) = nanmean(Data(:, :, :, Ch, :), ChDim);
                otherwise
                    error("Don't know this dimention (total matrix size)")
            end
        case 5
            switch TotDims
                case 6
                    NewData(:, :, :, :, Indx_Ch, :) = nanmean(Data(:, :, :, :, Ch, :), ChDim);
                otherwise
                    error("Don't know this dimention (total matrix size)")
            end
        otherwise
            error("Don't know this dimention (channel dimention)")
    end
end