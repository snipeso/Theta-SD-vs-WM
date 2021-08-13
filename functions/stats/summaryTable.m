function Summary = summaryTable(Data, ColNames)
% gives summary table of means and so on

Dims = size(Data);

if istable(Data)
    if isempty(ColNames)
        ColNames = Data.Properties.VariableNames;
    end
    Data = table2array(Data);
else
    if isempty(ColNames)
        ColNames = string(1:Dims(2));
    end
end

Summary = table(string(ColNames), repmat(Dims(1), Dims(2), 1), ...
    nanmean(Data, 1)', nanstd(Data, 1)', skewness(Data, 0, 1)', kurtosis(Data, 0, 1)', ...
    'VariableNames', {'Condition', 'N', 'Means', 'STD', 'Skew', 'Kurtosis'});