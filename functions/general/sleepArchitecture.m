function Table = sleepArchitecture(Matrix, Variables, Nights)
% creates a pretty table for publication with all the sleep infos and
% stats.
% Matrix is a P x N x V, Labels is 1 x V, and nights is 1 x N

% get averages and variances
Means = squeeze(nanmean(Matrix, 1));
SD = squeeze(nanstd(Matrix, 0, 1));

Table = table();
Table.Variables = Variables(:);

for Indx_V = 1:numel(Variables)
    for Indx_N1 = 1:numel(Nights)
        
        % descriptives
        Table.(Nights{Indx_N1})(Indx_V) = {[num2str(Means(Indx_N1, Indx_V), '%.1f'), ' ', char(177) ' ', num2str(SD(Indx_N1, Indx_V), '%.1f')]};

        % stats
        for Indx_N2 = Indx_N1+1:numel(Nights)
            N2 = Matrix(:, Indx_N2, Indx_V);
            N1 = Matrix(:, Indx_N1, Indx_V);
            [~, p] = ttest(N2-N1);
            pstring = num2str(p, '%.3f');
            Table.([Nights{Indx_N2}, 'vs', Nights{Indx_N1}])(Indx_V) = {pstring(2:end)};
        end
    end
end


Table = Table(:, [1 2 5 7 3 4 6]);