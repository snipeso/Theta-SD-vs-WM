function Stats = anova2way(Data, FactorLabels, Factor1Labels, Factor2Labels, StatsP)
% runs a repeated measures anova on data in the form of: P x m x n

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% set up data


% remove all data listwise if there are missing values

% remove whole task if missing
NaNs = squeeze(all(all(isnan(Data), 1), 2));

if any(NaNs)
    warning('Removing task from anova')
    Data(:, :, NaNs) = [];
end

NaNs =  any(squeeze(any(isnan(Data), 2)), 2); % WARNING: this won't work with later matlab versions

% give warning this is happening
if any(NaNs)
    warning(['Removing ', num2str(nnz(NaNs)), ' from anova2way'])
    
    Data(NaNs, :, :) = [];
end



Dims = size(Data);

% put data into table that ranova likes
Between = array2table(reshape(Data, Dims(1), Dims(2)*Dims(3)));

Within  = table();
Within.(FactorLabels{1}) = reshape(repmat(categorical(1:Dims(2))', 1, Dims(3)), [], 1);
Within.(FactorLabels{2}) = reshape(repmat(categorical(1:Dims(3)), Dims(2), 1), [], 1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run repeated-measures ANOVA

% MATLAB version, for GG corrected values and neater table
rm = fitrm(Between,['Var1-Var', num2str(Dims(2)*Dims(3)),'~1'], 'WithinDesign',Within); % get general linear model
ranovatbl = ranova(rm, 'WithinModel', strjoin(FactorLabels, '*'));

Stats.ranovatbl = ranovatbl;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Check assumptions

% save summary statistics: table of means, std, for each combo
Titles = strcat(Factor1Labels(Within.(FactorLabels{1}))', Factor2Labels(Within.(FactorLabels{2}))');
Summary = summaryTable(Between, Titles);
Stats.summary = Summary;

% check if normally distributed (ks test or shapiro
% wilkes?) for each combo
Normality = nan(numel(Titles));
NormalityP = Normality;
NormalityH = [];
for Indx1 = 1:numel(Titles)-1
    for Indx2 = Indx1+1:numel(Titles)
        F1 = table2array(Between(:, Indx1));
        F2 = table2array(Between(:, Indx2));
        [h, NormalityP(Indx1, Indx2), Normality(Indx1, Indx2)] = swtest(F1-F2, StatsP.Alpha);
        NormalityH = cat(2, NormalityH, h);
    end
end

% give warning if they're not, save output to stats, but continue
if any(NormalityH)
    warning([num2str(nnz(NormalityH)), ' not normal pairs out of ', num2str(numel(NormalityH))])
end

Stats.normality.sw_p = NormalityP;
Stats.normality.sw = Normality;

% instead of correcting for sphericity for some of the models, it will
% always assume to be violeted, and GG correction will be used

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Effect sizes

% get effect sizes, CI from external toolbox
F1 = repmat(1:Dims(2), Dims(1), 1, Dims(3));
F2 = repmat(permute(1:Dims(3), [1 3 2]), Dims(1), Dims(2), 1);
group = [reshape(F1, [], 1), reshape(F2, [], 1)];

X = reshape(Data, [], 1);

esm = StatsP.ANOVA.ES;
nBoot = StatsP.ANOVA.nBoot;

[EffectSizes, Table] = mes2way(X, group, esm, 'fName', FactorLabels, 'isDep', [1 1], 'nBoot', nBoot);

Stats.effects = EffectSizes;
Stats.effects.table = Table;


%%% show relevant tables
disp(Summary)
disp(ranovatbl)

