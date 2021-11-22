function plotICLabel(Values, Labels, Format)
% plots scatter of IC values, split by column and colorcoded by Labels

Dims = size(Values);

X = repmat([1:Dims(1)]'*.004, 1, Dims(2));

X = X + [1:Dims(2)]-.5;

hold on
scatter(X(:), Values(:), Format.ScatterSize, [.5 .5 .5])



% TODO: if I ever need a similar plot, make the basic plot a function