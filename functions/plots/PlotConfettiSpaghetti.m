function PlotConfettiSpaghetti(Matrix, SessionLabels, YLims, YLabels, ColorGroups, Format, Stats)
% PlotConfettiSpaghetti(Matrix, SessionLabels, YLims, Title, Labels, ColorGroups)
% plots a speghetti plot based on the matrix, with sessions on the x axis.
% A faded color indicates participants; either a unique color per person,
% or a seperate color for each group specified in last, optional variable.
% The mean is plotted in black

Tot_Peeps = size(Matrix, 1); % number of participants

Colors =  Format.Colors.Participants;
% select background colors for participants
if exist('ColorGroups', 'var') && ~isempty(ColorGroups)
    
    % get one color per group
    Groups = unique(ColorGroups);
    Tot_Groups = numel(Groups);
    Unique_Colors = Colors( floor(linspace(1, size(Colors, 1), Tot_Groups+1)), :);
    Unique_DarkColors = Colors( floor(linspace(1, size(Colors, 1), Tot_Groups+1)), :);
    
    % for each participant, assign group color
    Colors = zeros(Tot_Peeps, 3);
    for Indx_G = 1:Tot_Groups
        G = ismember(ColorGroups, Groups(Indx_G));
        Colors(G, :) = repmat(Unique_Colors(Indx_G, :), nnz(G), 1);
    end
end


% plot each participant
hold on
for Indx_P = 1:Tot_Peeps
%     plot(Matrix(Indx_P, :), 'o-', 'LineWidth', .7, ...
%         'MarkerFaceColor', Colors(Indx_P, :), 'MarkerFaceAlpha', .5, 'Color', Colors(Indx_P, :))

 plot(Matrix(Indx_P, :), 'LineWidth', .7, 'Color', [Colors(Indx_P, :),  Format.Alpha.Participants])
 scatter(1:numel(SessionLabels), Matrix(Indx_P, :), 50, ...
     'MarkerFaceColor', Colors(Indx_P, :), 'MarkerFaceAlpha',  Format.Alpha.Participants, ...
     'MarkerEdgeAlpha',  Format.Alpha.Participants, 'MarkerEdgeColor', Colors(Indx_P, :))
end


xlim([0.5, numel(SessionLabels) + .5])
xticks(1:numel(SessionLabels))
xticklabels(SessionLabels)

if ~isempty(YLims)
    ylim(YLims)
end

% plot mean
if exist('ColorGroups', 'var') && ~isempty(ColorGroups)
    for Indx_G = 1:Tot_Groups
        G = ismember(ColorGroups, Groups(Indx_G));
        Color = Unique_DarkColors(Indx_G, :);
        plot(nanmean(Matrix(G, :), 1), 'o-', 'LineWidth', 2.5, 'Color', Color,  'MarkerFaceColor', Color)
    end
    
    if Tot_Groups == 2 % TODO: maybe this can just be ANOVA
        pValues = [zeros(1, numel(SessionLabels)); 1:numel(SessionLabels)]';
        for Indx_S = 1:numel(SessionLabels)
            [~, pValues(Indx_S, 1)] = ttest2(Matrix(G, Indx_S), Matrix(not(G), Indx_S));
            
        end
        pValues(pValues(:, 1)>.1, :) = [];
        for Indx = 1:size(pValues, 1)
            sigstar({[pValues(Indx, 2)-.1, pValues(Indx, 2)+.1]},[pValues(Indx, 1)], {[0 0 0]})
        end
    end
    
else
    plot(nanmean(Matrix, 1), 'o-', 'LineWidth', 2.5, 'Color', 'k',  'MarkerFaceColor', 'k')
end


if exist('Labels', 'var') && ~isempty(YLabels)
    yticks(linspace(YLims(1), YLims(2), numel(YLabels)))
    yticklabels(YLabels)
end
%


if exist('Stats', 'var') && Stats
    Pairs = {};
    pValues = [];
    for Indx_S1 = 1:numel(SessionLabels)-1
       for Indx_S2 = Indx_S1+1:numel(SessionLabels)
              [~, pValue] = ttest(Matrix(:, Indx_S1), Matrix(:, Indx_S2));
              if pValue < .05
                 Pairs = cat(1, Pairs, [Indx_S1, Indx_S2]);
                 pValues = cat(1, pValues, pValue);
              end
    end
    end
 
    
    sigstar(Pairs, pValues, repmat({[0 0 0]}, size(Pairs)))
end


% if exist('ColorGroups', 'var') && ~isempty(ColorGroups)
%    legend(unique())
% end

set(gca, 'FontName', Format.FontName)



end




