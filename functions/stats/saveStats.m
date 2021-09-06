function saveStats(Stats, Type, Destination, TitleTag, StatsP)
Title = [TitleTag, '_', Type];

switch Type
    case 'rmANOVA'
        T = cell2table(Stats.effects.table(2:end, :));
        T.Properties.VariableNames = Stats.effects.table(1, :);
        T.SOURCE = replace(T.SOURCE, '- ', '');
        writetable(T, fullfile(Destination, [Title, '.csv']));
        
        T = Stats.summary;
        writetable(T, fullfile(Destination, [Title, '_Summary.csv']));
        
        T = Stats.normality.sw_p;
        writematrix(T, fullfile(Destination,  [Title, '_Normality.csv']));
        
        % assemble table of effect sizes
        T = table();
        T.(StatsP.ANOVA.ES) = Stats.effects.(StatsP.ANOVA.ES);
        T.CI_low =  Stats.effects.([StatsP.ANOVA.ES, 'Ci'])(:, 1);
        T.CI_high =  Stats.effects.([StatsP.ANOVA.ES, 'Ci'])(:, 2);
        writetable(T, fullfile(Destination,  [Title, '_',StatsP.ANOVA.ES, '.csv']));
        
    case 'Paired' % series of paired t-tests, typical for plotTopoDiff
        T = table();
        T.t = Stats.t;
        T.p = Stats.p;
        T.sig = Stats.sig; % fdr corrected
        T.df = Stats.df;
        T.CI_low = Stats.CI(:, 1);
        T.CI_high = Stats.CI(:, 2);
        T.(StatsP.Paired.ES) = Stats.(StatsP.Paired.ES);
        
        T.mean1 = Stats.mean1;
        T.std1 =Stats.std1;
        T.mean2 = Stats.mean2;
        T.std2 = Stats.mean2;
        T.mean_diff = Stats.mean_diff;
        T.std_diff = Stats.std_diff;
        
         writetable(T, fullfile(Destination,  [Title, '.csv']));
       
        
    otherwise
        error('dont know this stats')
end


save(fullfile(Destination, [Title, '.mat']), 'Stats')