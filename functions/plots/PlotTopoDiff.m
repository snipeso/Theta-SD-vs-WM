function [p, Sig] = plotTopoDiff(Data1, Data2, Chanlocs, CLims, Format)
% Plot t values of difference between two conditions (Data2 - Data1)
% Each matrix needs the same number of dimentions; participant x ch

% get t values
[~, p, ~, stats] = ttest((Data2 - Data1));
[~, Sig] = fdr(p, .05);
% Sig = p< 0.01;
t_values = stats.tstat';

CLabel = 't values';
Indexes = 1:numel(Chanlocs);


if isempty(CLims)
    Max = max(abs([quantile(t_values(:), .01), quantile(t_values(:), .99)]));
    CLims = [-Max Max];
end

topoplot(t_values, Chanlocs, 'maplimits', CLims, 'whitebk', 'on', ...
    'style', 'map', 'headrad', 'rim', 'gridscale', Format.TopoRes, ...
   'electrodes', 'on', 'emarker2', {Indexes(logical(Sig)), 'o', 'w', 3, .01});
h = colorbar;
ylabel(h, CLabel, 'FontName', Format.FontName, 'FontSize', 12)
set(gca, 'FontName', Format.FontName, 'FontSize', 12)

set(gca, 'FontName', Format.FontName)
colormap(Format.Colormap.Divergent)

% TODO: seperately plot markers if significiant for p<.05, and for cluster
% correction