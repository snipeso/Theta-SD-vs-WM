function plotPatch(Data, X, Direction, Color, xLog, xLims, Format)
% plots a patch of either the increase or decrease between 2 conditions.
% Data is a 2 x F matrix. Direction is either 'pos' or 'neg'. xLog is true
% or false.

hold on


if xLog
    X = log(X);
    
    % ignore all negative values, they won't get patched (sorry)
    RM = X<=0;
    X(RM) = [];
    D1 = Data(1, ~RM);
    D2 = Data(2, ~RM);
    
        xticks(log(Format.Labels.logBands))
    xticklabels(Format.Labels.logBands)
    
    if ~isempty(xLims)
        xlim(log(xLims))
    end
else
    D1=Data(1, :);
    D2=Data(2, :);
    
        xticks(Format.Labels.Bands)
    xticklabels(Format.Labels.Bands)
    
    if ~isempty(xLims)
        xlim(xLims)
    end
end


% identify continuous segments of either a positive or negative increase
switch Direction
    case 'pos'
        Patches = (D2-D1) >= 0;
    case 'neg'
        Patches = (D2-D1) <= 0;
    otherwise
        error('invalid direction')
end

[Starts, Ends] = data2windows(Patches);


hold on
plot(X, D1, 'Color', [Color, Format.Alpha.Patch], 'LineWidth', .5,  'HandleVisibility', 'off')

for Indx_P = 1:numel(Starts)
    
    x = X(Starts(Indx_P):Ends(Indx_P));
    y1 = D1(Starts(Indx_P):Ends(Indx_P));
    y2 = D2(Starts(Indx_P):Ends(Indx_P));
    
    if Indx_P ==1
        HV = 'on';
    else
        HV = 'off';
    end
    
    patch([x fliplr(x)], [y1 fliplr(y2)], Color, 'FaceAlpha',Format.Alpha.Patch, ...
        'EdgeColor', 'none', 'HandleVisibility', HV)
    hold off
end

set(gca,'FontName', Format.FontName, 'FontSize', Format.FontSize, 'XGrid', 'on')
% if xLog
%     set(gca, 'XScale', 'log')
% end