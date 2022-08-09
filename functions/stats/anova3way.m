function Stats = anova3way(Data, FactorLabels)
% runs a repeated measures anova on data in the form of: P x m x n x o

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% set up data

% remove all data listwise if there are missing values

% remove whole task if missing
NaNs = squeeze(all(all(isnan(Data), 1), 2));

if any(NaNs)
    warning('Removing task from anova')
    Data(:, :, NaNs) = [];
end

NaNs = any(squeeze(any(isnan(Data), 2)), 2); % WARNING: this won't work with later matlab versions

% give warning this is happening
if any(NaNs)
    warning(['Removing ', num2str(nnz(NaNs)), ' from anova2way'])
    
    Data(NaNs, :, :) = [];
end

Dims = size(Data);

% put data into table that ranova likes
Between = array2table(reshape(Data, Dims(1), Dims(2)*Dims(3)*Dims(4)));

Within  = table();
Within.(FactorLabels{1}) = reshape(repmat(categorical(1:Dims(2))', 1, Dims(3)*Dims(4)), [], 1);
Within.(FactorLabels{2}) = reshape(repmat(categorical(1:Dims(3)), Dims(2), Dims(4)), [], 1);
Within.(FactorLabels{3}) = reshape(repmat(categorical(1:Dims(4)), Dims(2)*Dims(3), 1), [], 1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run repeated-measures ANOVA

% MATLAB version, for GG corrected values and neater table
rm = fitrm(Between,['Var1-Var', num2str(Dims(2)*Dims(3)*Dims(4)),'~1'], 'WithinDesign',Within); % get general linear model
ranovatbl = ranova(rm, 'WithinModel', strjoin(FactorLabels, '*'));

Stats.ranovatbl = ranovatbl;


SS = ranovatbl.SumSq(2:end);
Stats.p = ranovatbl.pValueGG(3:2:end);
Stats.effects.eta2 = SS(2:2:14)/sum(SS);
Stats.labels = [FactorLabels, strjoin(FactorLabels([1, 2]), ':'), ...
    strjoin(FactorLabels([1, 3]), ':'), strjoin(FactorLabels([2, 3]), ':'), strjoin(FactorLabels, ':')];

