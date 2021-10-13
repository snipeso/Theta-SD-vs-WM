function NewData = trialData(Data, Trials)
% splits EEG power matrix by trial type and provides new averages
% Data is a P x S x T x E x Ch x F matrix. Trials is a P x S x T matix

Dims = size(Data);

TrialTypes = unique(Trials);
TrialTypes(isnan(TrialTypes)) = [];

NewDims = Dims;
NewDims(3) = numel(TrialTypes);

NewData = nan(NewDims);
for Indx_E = 1:Dims(4)
    for Indx_Ch = 1:Dims(5)
        for Indx_F = 1:Dims(6)
            D = squeeze(Data(:, :, :, Indx_E, Indx_Ch, Indx_F));
            NewData(:, :, :, Indx_E, Indx_Ch, Indx_F) = splitLevels(D, Trials, 'mean');
            
        end
    end
end