function dispStat(Stats, P, Label)
% displays as string a statistic of interest
% for t-values, p is coordinates
% for anovas, p is the factor labels

if isempty(Stats)
    return
end

Fieldnames = fieldnames(Stats);

if any(strcmp(Fieldnames, 't')) % paired t-test

    disp('*')
    disp(Label)
    disp(['(t = ', num2str(Stats.t(P(1), P(2)), '%.2f'), ', df = ', num2str(Stats.df(P(1), P(2))), ...
        ', p = ', num2str(Stats.p(P(1), P(2)), '%.3f'), ', g = ', num2str(Stats.hedgesg(P(1), P(2)), '%.2f'), ')'])
    disp('*')
elseif any(strcmp(Fieldnames, 'ranovatbl')) % 2 way rmANOVA

    Labels = Stats.labels;
    Positions = 3:2:size(Stats.ranovatbl, 1);


    disp('Interpreting eta: .01 is small; .06 is medium; .14 is large')
    disp('*')
    disp(Label)
    for Indx = 1:numel(Positions)
        pString = num2str(Stats.ranovatbl.pValueGG(Positions(Indx)), '%.3f');
        DF1 = Stats.ranovatbl.DF(Positions(Indx));
        DF2 = Stats.ranovatbl.DF(Positions(Indx)+1);
        F = Stats.ranovatbl.F(Positions(Indx));
        etaString = num2str(Stats.effects.eta2(Indx), '%.3f');


        disp([Labels{Indx}, ' F(', num2str(DF1), ', ', num2str(DF2), ') = ', num2str(F, '%.2f'), ...
            ', p = ', pString(2:end), ', eta2 = ', etaString(2:end), ')'])

    end
    disp('*')

elseif any(strcmp(Fieldnames, 'r')) % correlation

    disp('*')
    disp(Label)
    pString = num2str(Stats.p, '%.3f');
    R = num2str(Stats.r, '%.2f');
    if strcmp(R(1), '-')
        Sign = R(1);
    else
        Sign = '';
    end

    disp(['r(', num2str(Stats.df), ') = ', [Sign, '.', extractAfter(R, '.')], ...
        ', p = ', pString(2:end)])
    disp('*')

end
