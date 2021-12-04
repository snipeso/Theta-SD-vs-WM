function Stats = plotConfettiSpaghetti(Data, XLabels, YLabels, YLims, Colors, StatsP, Format)
% PlotConfettiSpaghetti()
% plots a speghetti plot showing participant data in color and a black
% average. Data is a P x S matrix. If you want to specify YLabels, you
% also need to indicate the YLims.

Dims = size(Data);

XPoints = 1:Dims(2);

% set x axis
xlim([.5, Dims(2)+.5])
xticks(1:Dims(2))
if ~isempty(XLabels)
    xticklabels(XLabels)
end



% plot each participant
hold on
for Indx_P = 1:Dims(1)
    plot(XPoints, Data(Indx_P, :),  'LineWidth', .7, 'Color', [Colors(Indx_P, :), Format.Alpha.Participants])
    
    scatter(XPoints, Data(Indx_P, :), 50, ...
        'MarkerFaceColor', Colors(Indx_P, :), 'MarkerFaceAlpha',  Format.Alpha.Participants, ...
        'MarkerEdgeAlpha',  Format.Alpha.Participants, 'MarkerEdgeColor', Colors(Indx_P, :))
end


% set y axis
if~isempty(YLims)
    ylim(YLims)
    
    if ~isempty(YLabels)
        yticks(linspace(YLims(1), YLims(2), numel(YLabels)))
        yticklabels(YLabels)
    end
else
    YLims = ylim;
end



% plot mean
[ColorGroups, ~, Groups] = unique(Colors, 'rows');
TotGroups = size(ColorGroups, 1);

if TotGroups == Dims(1) % if there's one color per participant, so no special groups
    
    plot(nanmean(Data, 1), 'o-', 'LineWidth', Format.LW, 'Color', 'k',  'MarkerFaceColor', 'k')
    
    % conduct stats
    if ~isempty(StatsP)
        Stats = Pairwise(Data, StatsP);
        plotHangmanStars(Stats, XPoints, YLims, Format.Colors.SigStar, Format)
    end
elseif  TotGroups == 1 
      plot(nanmean(Data, 1), 'o-', 'LineWidth', Format.LW, 'Color', ColorGroups,  'MarkerFaceColor', ColorGroups)
    
    % conduct stats
    if ~isempty(StatsP)
        Stats = Pairwise(Data, StatsP);
        plotHangmanStars(Stats, XPoints, YLims, ColorGroups, Format)
    end
    
else
    % plot a separate mean for each color group
    for Indx_C = 1:TotGroups
        Color = ColorGroups(Indx_C, :);
        
        plot(nanmean(Data(Groups==Indx_C, :)),...
            'o-', 'LineWidth', Format.LW, 'Color', Color,  'MarkerFaceColor', Color)
    end
    
    %     % TODO: group stats
    %     if Stats
    %         Stats = groupStats();
    %     end
end

set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize)

