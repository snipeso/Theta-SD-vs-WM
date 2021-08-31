function AllStats = PlotTopoANOVA2(Data, Chanlocs, FactorLabels, Factor1Labels, Factor2Labels, Title, StatsP, Format)
% plots eta2 for every factor and interaction for every channel. Data is a
% P x S x T x Ch matrix

Dims = size(Data);
Indexes = 1:numel(Chanlocs);
Eta2 = nan(Dims(end), numel(FactorLabels)+1); % ch x factors
pValues = Eta2;

CLabel = StatsP.ANOVA.ES;

for Indx_Ch = 1:Dims(end)
    D = squeeze(Data(:, :, :, Indx_Ch));
    Stats = anova2way(D, FactorLabels, Factor1Labels, Factor2Labels,  StatsP);
    Eta2(Indx_Ch, :) = Stats.effects.(StatsP.ANOVA.ES);
    P = Stats.ranovatbl.(StatsP.ANOVA.pValue);
    pValues(Indx_Ch, :) = P([3 5 7]);
    
    if Indx_Ch == 1
        AllStats = Stats;
    else
        AllStats(Indx_Ch) = Stats;
    end
end


FactorLabels = [FactorLabels, 'Interaction'];
CLims = [
    -.03, .43;
    -.03, .43;
    -.01, .11;
    ];

figure('units','normalized','outerposition',[0 0 .65 .4])
for Indx_F = 1:3
    Sig = pValues(:, Indx_F) <= StatsP.Alpha;
    
    subplot(1, 3, Indx_F)
    topoplot(Eta2(:, Indx_F), Chanlocs, 'whitebk', 'on',  'maplimits', CLims(Indx_F, :), ...
        'style', 'map', 'headrad', 'rim', 'gridscale', Format.TopoRes, ...
        'electrodes', 'on', 'emarker2', {Indexes(logical(Sig)), 'o', 'w', 5, .01}); %
  
    h = colorbar;
    ylabel(h, CLabel, 'FontName', Format.FontName, 'FontSize', 20)
    set(gca, 'FontName', Format.FontName, 'FontSize', 20)
      title([Title, ' ', FactorLabels{Indx_F}, ' Effects'], 'FontSize', 30)
    xlim([-.55 .55])
    ylim([-.55 .6])
    
    set(gca, 'FontName', Format.FontName)
    
    colormap(reduxColormap(flip(Format.Colormap.Monochrome), Format.Steps.Topo/2))
    
    
end