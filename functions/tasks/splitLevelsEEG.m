function DataSplit = splitLevelsEEG(EEGData, Levels)
% Data is a P x S x T x E x Ch x F matrix, and levels s a P x S x T matrix.
% Returns a P x S x TrialType x E x Ch x F matrix.

Dims = size(EEGData);

DataSplit = nan([Dims(1:2), numel(unique(Levels)), Dims(4:6)]);

for Indx_E = 1:Dims(4)
   for Indx_Ch = 1:Dims(5)
      for Indx_F = 1:Dims(6)
         Data  = squeeze(EEGData(:, :, :, Indx_E, Indx_Ch, Indx_F));
         DataSplit(:, :, :, Indx_E, Indx_Ch, Indx_F) = splitLevels(Data, Levels, 'mean');
      end
   end
end