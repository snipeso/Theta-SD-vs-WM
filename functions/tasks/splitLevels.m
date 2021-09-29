function DataSplit = splitLevels(Data, Levels, Operation)
% Data and Levels are a P x S x T matrix. DataSplit will be P x S x L

Dims = size(Data);
LevelTypes = unique(Levels);
LevelTypes(isnan(LevelTypes)) = [];

DataSplit = nan(Dims(1), Dims(2), numel(LevelTypes));

for Indx_P = 1:Dims(1)
    for Indx_S = 1:Dims(2)
        for Indx_L = 1:numel(LevelTypes)
            switch Operation
                case 'mean'
            T = squeeze(Levels(Indx_P, Indx_S, :)) == LevelTypes(Indx_L);
            DataSplit(Indx_P, Indx_S, Indx_L) = nanmean(Data(Indx_P, Indx_S, T));
                case 'sum'
                     T = squeeze(Levels(Indx_P, Indx_S, :)) == LevelTypes(Indx_L);
            DataSplit(Indx_P, Indx_S, Indx_L) = sum(Data(Indx_P, Indx_S, T));
                case 'ratio'
                        T = squeeze(Levels(Indx_P, Indx_S, :)) == LevelTypes(Indx_L);
             DataSplit(Indx_P, Indx_S, Indx_L) = sum(Data(Indx_P, Indx_S, T))/nnz(T);
                otherwise
                    error('dont know this operation')
            end
        end
    end
end