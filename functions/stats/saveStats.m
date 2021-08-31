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
        
    case 'ttest'
        
    otherwise
        error('dont know this stats')
end


save(fullfile(Destination, [Title, '.mat']), 'Stats')