function Stats = plotTopoDiff(Data1, Data2, Chanlocs, CLims, StatsP, Format)
% Plot t values of difference between two conditions (Data2 - Data1)
% Each matrix needs the same number of dimentions; participant x ch

% get t values
Stats = pairedttest(Data1, Data2, StatsP);

ES = Stats.(StatsP.Paired.ES);
Sig =  Stats.sig;
t_values = Stats.t;

% save max significant Hedge's g, # of sig channels, and # channels with
% G>1
Stats.ES_top1 = nnz(ES >= 1);

ES(~Sig) = nan; % only consider significant channels for rest
[Stats.ES_maxG, Indx] = max(ES);
Stats.ES_maxGch = Chanlocs(Indx).labels;
Stats.sigtot = nnz(Sig);

Indexes = 1:numel(Chanlocs);

if isempty(CLims)
    Max = max(abs([quantile(t_values, .01), quantile(t_values, .99)]));
    CLims = [-Max Max];
end

topoplot(stats.(StatsP.Paired.ES), Chanlocs, 'maplimits', CLims, 'whitebk', 'on', ...
    'style', 'map',  'plotrad', .72, 'headrad', 'rim', 'gridscale', Format.TopoRes, ...
    'electrodes', 'on', 'emarker2', {Indexes(logical(Sig)), 'o', 'w', Format.Topo.Sig, .05});

% topoplot(Stats.t, Chanlocs, 'maplimits', CLims, 'whitebk', 'on', ...
%     'style', 'map',  'plotrad', .72, 'headrad', 'rim', 'gridscale', Format.TopoRes, ...
%     'electrodes', 'on', 'emarker2', {Indexes(logical(Sig)), 'o', 'w', Format.Topo.Sig, .05});

% topoplot(nanmean(Data2./Data1), Chanlocs, 'maplimits', CLims, 'whitebk', 'on', ...
%     'style', 'map',  'plotrad', .72, 'headrad', 'rim', 'gridscale', Format.TopoRes, ...
%     'electrodes', 'on', 'emarker2', {Indexes(logical(Sig)), 'o', 'w', Format.Topo.Sig, .05});
%


% topoplot(Stats.mean2-Stats.mean1, Chanlocs, 'maplimits', CLims, 'whitebk', 'on', ...
%     'style', 'map',  'plotrad', .72, 'headrad', 'rim', 'gridscale', Format.TopoRes, ...
%     'electrodes', 'on', 'emarker2', {Indexes(logical(Sig)), 'o', 'w', Format.Topo.Sig, .05});

set(gca, 'FontName', Format.FontName)
xlim([-.55 .55])
ylim([-.55 .6])

set(gca, 'FontName', Format.FontName)

Colormap = reduxColormap(Format.Colormap.Divergent, Format.Steps.Divergent);
colormap(Colormap)



%%% save in stats the peaks of values

[pks, locs, prom, width] = peakfinder_topo(Stats.hedgesg, [Chanlocs.X], [Chanlocs.Y], [Chanlocs.Z], StatsP.minProminence);
Labels = str2double({Chanlocs.labels})';
Peaks = [pks, Labels(locs), prom, width];
Peaks(~Sig(locs), :) = []; % remove peaks when peak channel is not significant


Stats.ES_Peaks = Peaks;


