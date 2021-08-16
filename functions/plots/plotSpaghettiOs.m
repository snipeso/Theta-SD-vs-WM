function Stats = plotSpaghettiOs(Data, Indx_BL, XLabels, CLabels, Colors, StatsP, Format)
% Data is a P x m x n matrix, plotting a separate line for each n at m
% points on the x axis. It plots a circle with a white dot in it whenever
% the change from BL_Indx is significant, corrected for multiple testing.
% Colors is a n x 3 matrix.

LW = 3;

Dims = size(Data);

% get all p-values TODO: move to separate function
pValues = nan(Dims(2), Dims(3));
tValues = pValues;
df = pValues;
CI = nan(Dims(2), Dims(3), 2);
pValues_fdr = pValues; % for alpha = .05
pValues_fdr_trend = pValues; % for alpha = .1

for Indx_S = 1:Dims(2)
    for Indx_T = 1:Dims(3)
        D = squeeze(Data(:, Indx_S, Indx_T));
        BL = squeeze(Data(:, Indx_BL, Indx_T));
        [~, pValues(Indx_S, Indx_T), CI(Indx_S, Indx_T, :), stats] = ttest(D(:), BL(:));
        df(Indx_S, Indx_T) = stats.df;
        tValues(Indx_S, Indx_T) = stats.tstat;
    end
end

% apply fdr correction
Indx = 1:Dims(2);
notBL = Indx~=Indx_BL;
[~, pValues_fdr(notBL, :)] = fdr(pValues(notBL, :), StatsP.Alpha);
[~, pValues_fdr_trend(notBL, :)] = fdr(pValues(notBL, :), StatsP.Trend);
Stats.pValues = pValues;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot everything

hold on

for Indx_T = 1:Dims(3)
    C = Colors(Indx_T, :);
    
    % plot mean per n
    Mean = squeeze(nanmean(Data(:, :, Indx_T), 1));
    h = plot(Mean, 'Color', C,  'LineWidth', LW);
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','on'); % indicate this goes in the legend
    
    % plot significance marker if present
    for Indx_S = 1:Dims(2)
        
        if Indx_S == Indx_BL % don't plot marker for reference session
            continue
        end
        
        P_alpha = pValues_fdr(Indx_S, Indx_T);
        P_trend = pValues_fdr_trend(Indx_S, Indx_T);
        
        % change marker type based on p value
        if P_alpha
            MF = [1 1 1]; % Marker Face
            ME = C;
        elseif P_trend
            MF = C;
            ME = 'none';
        else
            MF = 'none';
            ME = 'none';
        end
        h= plot(Indx_S, Mean(Indx_S), 'o', ...
            'MarkerEdgeColor', ME, 'MarkerFaceColor', MF,  'LineWidth', LW);
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        
    end
end


set(gca, 'FontName', Format.FontName, 'FontSize', 14)
xlim([.75, Dims(2)+.25])
xticks(1:Dims(2))
xticklabels(XLabels)
legend(CLabels, 'location', 'northwest')



%  'HandleVisibility','off'