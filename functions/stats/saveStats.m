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
        
    case 'Pairwise' % pairwise t-tests between all the conditions from Pairwise
        T = table();
        T.t = Stats.t;
        T.p = Stats.p;
        T.sig = Stats.sig; % fdr corrected
        T.df = Stats.df;
        T.CI_low = Stats.CI(:, 1);
        T.CI_high = Stats.CI(:, 2);
        T = Stats.p;
        writematrix(T, fullfile(Destination,  [Title, '_pValues.csv']));
        T = Stats.t;
        writematrix(T, fullfile(Destination,  [Title, '_tValues.csv']));
        T = Stats.df;
        writematrix(T, fullfile(Destination,  [Title, '_df.csv']));
        T = squeeze(Stats.CI(:, :, 1));
        writematrix(T, fullfile(Destination,  [Title, '_CIlow.csv']));
        T = squeeze(Stats.CI(:, :, 2));
        writematrix(T, fullfile(Destination,  [Title, '_CIhigh.csv']));
        T = Stats.sig;
        writematrix(T, fullfile(Destination,  [Title, '_fdr.csv']));
        
    case 'Spectrum'
        Variables = {'p', 'p_fdr', 'sig', 't', 'df'};
        T = table();
        T.freqs = Stats.freqs';
        
        for Indx_L = 1:numel(Stats.lines)
            for Indx_V = 1:numel(Variables)
                T.([Variables{Indx_V}, '_', Stats.lines{Indx_L}]) = ...
                    reshape(Stats.(Variables{Indx_V})(Indx_L, :), [], 1);
            end
        end
        
        writetable(T, fullfile(Destination,  [Title, '.csv']));
    otherwise
        error('dont know this stats')
end


save(fullfile(Destination, [Title, '.mat']), 'Stats')