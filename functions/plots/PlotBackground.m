function PlotBackground(EEG, Start, Stop)
% plots a nice dramatic thick lined figure to use as a background

Ch = [15 6 11 124 55 51 71 95];

Ch = labels2indexes(Ch, EEG.chanlocs);
Ch = flip(Ch);
Tot = numel(Ch);

Data = pop_select(EEG, 'time', [Start, Stop]);

YShift = 10*nanmean(nanstd(Data.data(Ch, :), 0, 2));
Y = 0:YShift:YShift*(Tot-1);
figure('units','normalized','position',[0 0 .9 .9], 'Color', 'k')
hold on
for Indx_Ch = 1:Tot
   plot(Y(Indx_Ch)+Data.data(Ch(Indx_Ch), :), 'Color', 'w',  'LineWidth', 8) 
    
end

axis off
axis tight
set(gca, 'Position', [0 0 1 1])


