function plotHangmanStars(Stats, XPoints, YLims, Colors, StatsP, Format)
% function that plots all the pairwise comparisons in Stats.p, with a
% single line for each effect. Sorted from bottom to top by total number of
% significant comparisons.

OldYLims = ylim;
OldXLims =  xlim;

LW = 1;

nGroups = size(Stats.p, 1);

pValues = Stats.pFDR;


% mirror p-values
pValues(logical(tril(ones(size(pValues)), -1))) = 0;
pValues_mirror = pValues + tril(pValues');

if isempty(YLims)
    axis(gca, 'tight')
else
    ylim(YLims)
end
DataRange = get(gca, 'YLim');

YHeight = DataRange(2);
Increase = diff(DataRange)*.1;

hold on
for Indx = 1:nGroups % go from most to least significant
    
    % identify next biggest group
    TotSig = sum(~isnan(pValues_mirror)); % total number of significant comparisons
    SumP = 1-nansum(pValues_mirror);
    MostSig = TotSig + SumP;
    
    [~, G_Indx] = max(MostSig);
    
    % identify other groups that are significantly different
    X_Minor = XPoints(~isnan(pValues_mirror(G_Indx, :)) & pValues_mirror(G_Indx, :) < StatsP.Trend);
    if isempty(X_Minor)
        continue
    end
    
    X_All = [X_Minor, G_Indx];
    
    % identify color of line
    if size(Colors, 1) == nGroups
        C = Colors(G_Indx, :);
    elseif ~isempty(Colors)
        C = Colors;
    else
        C = Format.Colors.SigStar;
    end
    
    % identify height at which to draw the line
    YHeight = YHeight+Increase;
    
    % plot main horizontal bar
    plot(X_All, YHeight*ones(size(X_All)),  '-o',  'MarkerFaceColor', C, 'MarkerSize', .5, 'LineWidth', LW, 'Color', C)
    
    % plot main post
    plot([XPoints(G_Indx), XPoints(G_Indx)], [YHeight-Increase*.75, YHeight], ...
        '-o',  'MarkerFaceColor', C, 'MarkerSize', .5, 'LineWidth', LW, 'Color', C)
    
    
    for x = X_Minor
        % plot minor posts
        plot([x, x], [YHeight-Increase*.2, YHeight], ...
               '-o',  'MarkerFaceColor', C, 'MarkerSize', .5, 'LineWidth', LW, 'Color', C)
        
        % plot stars
        P = pValues_mirror(x, G_Indx);
        Symbol = getSigSymbol(P);
        if ~isempty(Symbol)
            text(x, YHeight-Increase*.5, Symbol, 'HorizontalAlignment', 'center', 'Color', C, 'FontSize', Format.BarSize)
        end
    end
    
    % remove from list the p-values already plotted
    pValues_mirror(G_Indx, :) = nan;
    pValues_mirror(:, G_Indx) = nan;
    
end

if YHeight+Increase/4> OldYLims(2)
    ylim([OldYLims(1), YHeight+Increase/4])
else
    ylim(OldYLims)
end
set(gca, 'FontName', Format.FontName)
xlim(OldXLims)