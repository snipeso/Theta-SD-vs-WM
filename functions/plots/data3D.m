function Stats = data3D(Data, Indx_BL, xLabels, Legend, Colors, StatsP, PlotProps)
% Stats = data3D(Data, Indx_BL, xLabels, CLabels, Colors, StatsP, PlotProps)
%
% Plots Data (P x S x T) averages across participants. S is on the x axis,
% and a separate line is for each T. Uses chART scripts.


%%% Get stats
Data1 = squeeze(Data(:, Indx_BL, :));
Data2 = Data;
Data2(:, Indx_BL, :) = [];
Stats = pairedttest(Data1, Data2, StatsP);


plotSpaghettiOs(Data, Stats, Indx_BL, xLabels, Legend, Colors, PlotProps)