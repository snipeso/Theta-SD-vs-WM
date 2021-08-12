function Stats = anova2way(Data, ConditionLabels)
% runs a repeated measures anova on data in the form of: P x m x n



% remove all data listwise if there are missing values

% give warning this is happening


% check if differences are normally distributed (ks test)

% give warning if they're not, save output to stats, but continue



% use Mauchley's test of sphericity

% give warning if not valid, and apply GG correction



