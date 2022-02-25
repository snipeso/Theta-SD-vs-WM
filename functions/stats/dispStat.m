function dispStat(Stats, P, Label)
% displays as string a statistic of interest


disp('*')
disp(Label)
disp(['(t = ', num2str(Stats.t(P(1), P(2)), '%.2f'), ', df = ', num2str(Stats.df(P(1), P(2))), ...
    ', p = ', num2str(Stats.p(P(1), P(2)), '%.3f'), ', g = ', num2str(Stats.hedgesg(P(1), P(2)), '%.2f'), ')'])
disp('*')
