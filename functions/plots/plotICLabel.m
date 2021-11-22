function plotICLabel(Values, Labels, Format)
% plots scatter of IC values, split by column and colorcoded by Labels

Dims = size(Values);
Classes = {'Brain'  'Muscle'  'Eye'  'Heart'  'Line Noise'  'Channel Noise'  'Other'};

IC_Brain_Threshold = 0.1; % %confidence of automatic IC classifier in determining a brain artifact
IC_Other_Threshold = 0.6; % %confidence of automatic IC classifier in determining a brain artifact

IC_Max = 60; % limit of components automatically considered for elimination


X = repmat([1:Dims(1)]'*.005, 1, Dims(2));

X = X + [1:Dims(2)]-.25;

hold on

% plot automatic limit of components to check
x =  X(IC_Max, :);
y = [0; 1];
plot([x;x], repmat(y, 1, Dims(2)), ':', 'Color', 'k', 'LineWidth', .3)

% plot brain limit
y = [IC_Brain_Threshold, IC_Brain_Threshold];
x = [min(X(:, 1)), max(X(:, 1))];
plot(x, y,  'Color', 'k', 'LineWidth', .3)

% plot other limits
for Indx_C = 2:Dims(2)
    y = [IC_Other_Threshold, IC_Other_Threshold];
    x = [min(X(:, Indx_C)), max(X(:, Indx_C))];
    plot(x, y,  'Color', 'k', 'LineWidth', .3)
end


% kept components
for Indx_C = 1:Dims(2)
    
    scatter(X(~Labels, Indx_C), Values(~Labels, Indx_C), Format.ScatterSize, [.5 .5 .5], 'filled', 'MarkerFaceAlpha', .1)
    
    % removed components
    scatter(X(Labels, Indx_C), Values(Labels, Indx_C), Format.ScatterSize, getColors(1, 'rainbow', 'red'), 'filled', 'MarkerFaceAlpha', .2)
    
end

xticks(1:Dims(2))
xticklabels(Classes)

set(gca, 'FontSize', Format.FontSize, 'FontName', Format.FontName)

% TODO: if I ever need a similar plot, make the basic plot a function