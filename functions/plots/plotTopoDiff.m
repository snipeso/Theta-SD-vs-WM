function Stats = plotTopoDiff(Data1, Data2, Chanlocs, CLims, StatsP, Format)
% plots the t-values (color) and significant channels (white dots) of
% Data2 vs Data1.
% Data are P x Ch matrices.
% Chanlocs is an EEGLAB channel structure.
% CLims is the limits for the colormap. If none is provided, then the
% min/max is used, centered on 0.
% StatsP is a structure with statistics info (see analysisParameters).
% Format is a structure with plotting info.

%%% get t values & other info
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

% get colorlimits
if isempty(CLims)
    Max = max(abs([quantile(t_values, .01), quantile(t_values, .99)]));
    CLims = [-Max Max];
end


% plot
Chanlocs = shiftTopoChannels(Chanlocs, .06, 'y'); % little adjustment to center the chanlocs better
topoplot(Stats.t, Chanlocs, 'maplimits', CLims, 'whitebk', 'on', ...
    'style', 'map',  'plotrad', .73, 'headrad', 'rim', 'gridscale', Format.TopoRes, ...
    'electrodes', 'on', 'emarker2', {Indexes(logical(Sig)), 'o', 'w', Format.Topo.Sig, .05});

set(gca, 'FontName', Format.FontName)
xlim([-.55 .55])
ylim([-.55 .6])

% make all lines same thickness
A = gca;
set(A.Children, 'LineWidth', 1)

% change colormap
Colormap = reduxColormap(Format.Colormap.Divergent, Format.Steps.Divergent);
colormap(Colormap)

%%% save in stats the peaks of values
[pks, locs, prom, width] = peakfinder_topo(Stats.hedgesg, [Chanlocs.X], [Chanlocs.Y], [Chanlocs.Z], StatsP.minProminence);
Labels = str2double({Chanlocs.labels})';
Peaks = [pks, Labels(locs), prom, width];
Peaks(~Sig(locs), :) = []; % remove peaks when peak channel is not significant


Stats.ES_Peaks = Peaks;


