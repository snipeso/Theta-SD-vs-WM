function plotPairwiseStars(Stats, XPoints, Color)
% plots significance stars

% get significant and trending pairs
Pairs = {};
pValues = [];

for Indx1 = 1:numel(XPoints)-1
    for Indx2 = Indx1+1:numel(XPoints)
        p = Stats.p(Indx1, Indx2);
        if p < .1
           pValues = cat(1, pValues, p);
           Pairs = cat(1, Pairs, XPoints([Indx1, Indx2]));
        end
    end
end

if isempty(Color) % default black
    Color = [0 0 0];
end

% plot stars
 sigstar(Pairs, pValues, repmat({Color}, size(Pairs)))