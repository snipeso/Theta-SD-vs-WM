function newData = averageTrials(Data, Trials)
% Data is P x T x whatever
% Trials is P x T 1s and 0s
Dims = size(Data);
Dims(2) = [];
if numel(Dims) == 1
    newData = nan(Dims, 1);
else
    newData = nan(Dims);
end


for Indx_P = 1:Dims(1)
   T = logical(Trials(Indx_P, :));
   D = Data(Indx_P, T, :, :);
   newData(Indx_P, :, :) = nanmean(D, 2);
end