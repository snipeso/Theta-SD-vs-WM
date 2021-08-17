function plotBars(Data, xLabels, Colors, Format, Orientation, StatsP)
% Matrix is a P x whatever matrix. This plots the averages across the
% whatever dimention, and SEM error bars if requested.

% See PlotBars2 of original scripts to get inspiration on other dimentions

Dims = size(Data);

if any(Dims==1)
    nDims = numel(Dims)-1;
else
    nDims = numel(Dims);
end
hold on
switch nDims
    case 2 % e.g. P x S
        if exist('StatsP', 'var')
            
            % get standard mean error for error bars
            SEM = nanstd(Data)/sqrt(Dims(1));
            
            % plot bars
            drawBars(nanmean(Data)', xLabels, Colors, Orientation, [SEM', SEM'], Format)
            
            % plot pairwise comparison of bars
            Stats = Pairwise(Data, StatsP);
            plotHangmanStars(Stats, 1:numel(xLabels), [], Colors, Format);
        else
            drawBars(nanmean(Data)', xLabels, Colors, Orientation, [], Format)
        end
    otherwise
        disp('dont know what to do with these dimentions')
end

set(gca, 'FontSize', 15)
set(findobj(gca,'LineStyle','-'),'LineWidth',2)
set(findall(gca, 'type', 'text'), 'FontSize', 15)