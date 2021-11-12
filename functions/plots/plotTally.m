function Tally = plotTally(Data, XLabels, CLabels, Colors, Order, Format)
% plot stacked bar plot for representing tally of answers. Data is a P x S
% x T matrix, and a bar is made for every S. Labels should be the same
% number of unique items being tallied, and colors the same number as
% labels.

Dims = size(Data);
Categories = unique(Data);
Categories(isnan(Categories)) = [];

Tally = nan(Dims(1), Dims(2), numel(Categories));

if isempty(Colors)
    Colors = reduxColormap(Format.Colormap.Rainbow, numel(Categories));
end

for Indx_C = 1:numel(Categories)
       for Indx_P = 1:Dims(1)
    for Indx_S = 1:Dims(2)
     
        D = squeeze(Data(Indx_P, Indx_S, :));
        if all(isnan(D)) % skip if participant didn't do session
            continue
        end
    Sum = nansum(D == Categories(Indx_C));
    

    Tally(Indx_P, Indx_S, Indx_C) = Sum;
    end
       end
end

Tally = 100*(Tally./Dims(3));

Tally = squeeze(nanmean(Tally, 1));

% sort
if ~isempty(Order)
    Tally = Tally(:, Order);
    Colors = Colors(Order, :);
    CLabels = CLabels(Order);
end

h = bar(Tally, 'stacked');

ylim([0 100])
for Indx = 1:size(Colors, 1)
    h(Indx).EdgeColor = 'none';
    h(Indx).FaceColor = 'flat';
    h(Indx).CData = Colors(Indx, :);
end

set(gca, 'FontName', Format.FontName, 'FontSize', Format.FontSize)


set(gca,'TickLength',[0 0])
box off
xlim([.5, numel(XLabels)+.5])
xticks(1:numel(XLabels))
xticklabels(XLabels)
ylabel('% of Responses')
% ylim([0 100])

if ~isempty(CLabels)
    legend(CLabels)
end