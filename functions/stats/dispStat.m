function dispStat(Stats, P, Label)
% displays as string a statistic of interest


Fieldnames = fieldnames(Stats);

if any(strcmp(Fieldnames, 't')) % paired t-test
    
    disp('*')
    disp(Label)
    disp(['(t = ', num2str(Stats.t(P(1), P(2)), '%.2f'), ', df = ', num2str(Stats.df(P(1), P(2))), ...
        ', p = ', num2str(Stats.p(P(1), P(2)), '%.3f'), ', g = ', num2str(Stats.hedgesg(P(1), P(2)), '%.2f'), ')'])
    disp('*')
elseif any(strcmp(Fieldnames, 'ranovatbl')) % 2 way rmANOVA
    Positions = [3, 5, 7]; % Session, Task, Interaction
    
    disp('Interpreting eta: .01 is small; .06 is medium; .14 is large')
        disp('*')
    disp(Label)
    for Indx = 1:3
        p = Stats.ranovatbl.pValueGG(Positions(Indx));
        DF1 = Stats.ranovatbl.DF(Positions(Indx));
        DF2 = Stats.ranovatbl.DF(Positions(Indx)+1);
        F = Stats.ranovatbl.F(Positions(Indx));
        eta = Stats.effects.eta2(Indx);
        

    disp(['F(', num2str(DF1), ', ', num2str(DF2), ') = ', num2str(F, '%.2f'), ...
        ', p = ', num2str(p, '%.3f'), ', eta2 = ', num2str(eta, '%.3f'), ')'])

    end
        disp('*')
end
