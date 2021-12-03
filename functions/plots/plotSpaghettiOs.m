function Stats = plotSpaghettiOs(Data, Indx_BL, XLabels, CLabels, Colors, StatsP, Format)
% Stats = plotSpaghettiOs(Data, Indx_BL, XLabels, CLabels, Colors, StatsP, Format)
%
% Data is a P x m x n matrix, plotting a separate line for each n at m
% points on the x axis. It plots a circle with a white dot in it whenever
% the change from BL_Indx is significant, corrected for multiple testing.
% Colors is a n x 3 matrix.

Dims = size(Data);

% indicate whether Clabels get included in plot
if isempty(CLabels)
    CMarker = 'off';
    Legend = {};
else
    CMarker = 'on';
    Legend = CLabels;
end

% terms for significant dots
Alpha = num2str(StatsP.Alpha);
Alpha = ['p<', Alpha(2:end)];

TrendAlpha =  num2str(StatsP.Trend);
Trend = ['p<', TrendAlpha(2:end)];


%%% Get stats

% get all p-values
pValues = nan(Dims(2), Dims(3));
tValues = pValues;
df = pValues;
CI = nan(Dims(2), Dims(3), 2);
pValues_fdr = pValues; % for alpha = .05

for Indx_S = 1:Dims(2)
    for Indx_T = 1:Dims(3)
        D = squeeze(Data(:, Indx_S, Indx_T));
        BL = squeeze(Data(:, Indx_BL, Indx_T));
        [~, pValues(Indx_S, Indx_T), CI(Indx_S, Indx_T, :), stats] = ttest(D(:)-BL(:));
        df(Indx_S, Indx_T) = stats.df;
        tValues(Indx_S, Indx_T) = stats.tstat;
    end
end

% apply fdr correction
Indx = 1:Dims(2);
notBL = Indx~=Indx_BL;

[Sig, crit_p, ~,  pValues_fdr(notBL, :)] = fdr_bh(pValues(notBL, :), StatsP.Alpha, StatsP.ttest.dep);

% save to stats struct
Stats.pValues = pValues;
Stats.p_fdr =  pValues_fdr;
Stats.crit_p = crit_p;
Stats.sig = Sig(:);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot everything

Marked = [false false]; % used to keep track of handles for legend; first item is Trend, second is Sig

hold on


% plot mean lines
for Indx_T = 1:Dims(3)
    C = Colors(Indx_T, :);
    
    Mean = squeeze(nanmean(Data(:, :, Indx_T), 1));
    plot(Mean, 'Color', C,  'LineWidth', Format.LW, 'HandleVisibility', CMarker);
end


% plot significance marker if present
for Indx_T = 1:Dims(3) % loop through lines
    
    C = Colors(Indx_T, :);
    Mean = squeeze(nanmean(Data(:, :, Indx_T), 1));
    
    for Indx_S = 1:Dims(2) % loop through points in line
        
        if Indx_S == Indx_BL % don't plot marker for reference session
            continue
        end
        
        P = pValues_fdr(Indx_S, Indx_T);
        
        % HACK plot hidden marker behind marker to include in legend
        if P <= StatsP.Alpha % big empty circle for significant difference
            MF = [1 1 1]; % Marker Face
            ME = C; % Marker edge color
            
            if ~Marked(2) % if not already placed a hidden marker, do so
                plot(Indx_S, Mean(Indx_S), 'o', 'MarkerSize', Format.OSize,...
                    'MarkerEdgeColor', Format.Colors.Generic, 'MarkerFaceColor', MF,  'LineWidth', Format.LW, ...
                    'HandleVisibility', 'on');
                
                Legend = [Legend, Alpha]; % add legend item
                Marked(2) = true;
            end
            
        elseif P <= StatsP.Trend % filled little circle for trend
            MF = C;
            ME = 'none';
            
            if ~Marked(1)
                plot(Indx_S, Mean(Indx_S), 'o', 'MarkerSize', Format.OSize,...
                    'MarkerEdgeColor', ME, 'MarkerFaceColor', Format.Colors.Generic,  'LineWidth', Format.LW, ...
                    'HandleVisibility', 'on');
                Legend = [Legend, Trend];
                Marked(1) = true;
            end
            
        else
            MF = 'none';
            ME = 'none';
        end
        
        plot(Indx_S, Mean(Indx_S), 'o', 'MarkerSize', Format.OSize,...
            'MarkerEdgeColor', ME, 'MarkerFaceColor', MF,  'LineWidth', Format.LW, ...
            'HandleVisibility', 'off');
    end
end

set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize)
xlim([.75, Dims(2)+.25])
xticks(1:Dims(2))
xticklabels(XLabels)


%%% legend
legend(Legend)
if ~any(Marked) % removes empty box
    legend off
end


