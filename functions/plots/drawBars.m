function drawBars(Data, xLabels, Colors, Orientation, Errors, Format)
% function that just plots the bars and error bars. Basic averages and SEM
% are provided by PlotBars().
% 1 Dim: Data is n x 1. Errors is n x 2. Errors are relative to Data.

Dims = size(Data);

if any(Dims==1)
    nDims = numel(Dims)-1;
else
    nDims = numel(Dims);
end

if strcmp(Orientation, 'horizontal')
    h = barh(Data, 'grouped', 'EdgeColor', 'none', 'FaceColor', 'flat');
else
    h = bar(Data, 'grouped', 'EdgeColor', 'none', 'FaceColor', 'flat');
end

if exist('Colors', 'var') && ~isempty(Colors)
    h.CData = Colors;
else
    h.CData = [.5 .5 .5];
end

% plot error bars if requested
if isempty(Errors)
    return
end

% get error bars
nbars = Dims(1);
hold on
for Indx = 1:nbars
    switch nDims
        case 1
            x = Indx; % nothing fancy, just where bar midpoint is.
            errorbar(x, Data(Indx),  Errors(Indx, 1),  Errors(Indx,2), ...
                'k', 'linestyle', 'none', 'LineWidth', 1.5);
            xlim([.5 numel(xLabels)+.5]);
            xticks(1:numel(xLabels))
            xticklabels(xLabels)
            
            %     case 2
            %                         groupwidth = min(0.8, nbars/(nbars + 1.5));
            %             ngroups = size(Data, 2);
            %             x = (1:ngroups) - groupwidth/2 + (2*Indx-1) * groupwidth / (2*nbars);
            %         errorbar(x, Data(:,Indx),  Data(:,Indx)-Errors(:, 1),  Errors(:,2)-Data(:,Indx), ...
            %             'k', 'linestyle', 'none', 'LineWidth', 1.5);
        otherwise
            disp('dont know these dims')
    end
end

set(gca, 'FontName', Format.FontName)