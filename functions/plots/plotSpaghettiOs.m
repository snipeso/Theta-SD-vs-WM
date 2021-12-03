function Stats = plotSpaghettiOs(Data, Indx_BL, XLabels, CLabels, Colors, StatsP, Format)
% Stats = plotSpaghettiOs(Data, Indx_BL, XLabels, CLabels, Colors, StatsP, Format)
%
% Data is a P x m x n matrix, plotting a separate line for each n at m
% points on the x axis. It plots a circle with a white dot in it whenever
% the change from BL_Indx is significant, corrected for multiple testing.
% Colors is a n x 3 matrix.

Dims = size(Data);
GenericColor = [.5 .5 .5];


% indicate what gets saved in legend
if isempty(CLabels)
    SigMarker = 'on';
    CMarker = 'off';
else
    SigMarker = 'off';
    CMarker = 'on';
end

% get all p-values TODO: move to separate function
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

Stats.pValues = pValues;

Stats.p_fdr =  pValues_fdr;
Stats.crit_p = crit_p;
Stats.sig = Sig(:);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot everything

Marked = [false false]; % used to keep track of handles for sig markers

hold on


% plot mean per n
for Indx_T = 1:Dims(3)
    C = Colors(Indx_T, :);
    
    Mean = squeeze(nanmean(Data(:, :, Indx_T), 1));
    h = plot(Mean, 'Color', C,  'LineWidth', Format.LW, 'HandleVisibility', CMarker);
    
end



% plot significance marker if present
for Indx_T = 1:Dims(3)
    
    C = Colors(Indx_T, :);
    Mean = squeeze(nanmean(Data(:, :, Indx_T), 1));
    
    for Indx_S = 1:Dims(2)
        
        if Indx_S == Indx_BL % don't plot marker for reference session
            continue
        end
        
        P = pValues_fdr(Indx_S, Indx_T);
        
        % HACK plot hidden marker behind marker to include in legend
        if P <= StatsP.Alpha
            MF = [1 1 1]; % Marker Face
            ME = C;
            
            if ~Marked(2)
                plot(Indx_S, Mean(Indx_S), 'o', 'MarkerSize', Format.OSize,...
                    'MarkerEdgeColor', GenericColor, 'MarkerFaceColor', MF,  'LineWidth', Format.LW, ...
                    'HandleVisibility', 'on');
                
                Marked(2) = true;
            else
                Mark = 'off';
            end
            
        elseif P <= StatsP.Trend
            MF = C;
            ME = 'none';
            
            if ~Marked(1)
                plot(Indx_S, Mean(Indx_S), 'o', 'MarkerSize', Format.OSize,...
                    'MarkerEdgeColor', ME, 'MarkerFaceColor', GenericColor,  'LineWidth', Format.LW, ...
                    'HandleVisibility', 'on');
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


% legend
Alpha = num2str(StatsP.Alpha);
Sig = ['p<', Alpha(2:end)];

TrendAlpha =  num2str(StatsP.Trend);
Trend = ['p<', TrendAlpha(2:end)];
Legend = {Trend, Sig};

if isempty(CLabels)
    
    legend(Legend(Marked))
    
    if ~any(Marked)
        legend off
    end
else
    legend([CLabels, Legend(Marked)])
end

end



%  'HandleVisibility','off'