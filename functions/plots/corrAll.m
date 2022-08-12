function Stats = corrAll(Data1, Data2, StatsP, PlotProps)
% Data1 is a P x M matrix
% Data2 is a P x N matrix


Stats = correlation(Data1, Data2, StatsP);

imagesc(Stats.r)
A=1;