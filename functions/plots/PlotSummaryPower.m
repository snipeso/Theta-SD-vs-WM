function PlotSummaryPower(Power, Freqs, Chanlocs, Bands, Format)
% plot a little figure with the power bands

BandLabels = fieldnames(Bands);
FreqRes = Freqs(2)-Freqs(1);

figure('units','normalized','outerposition',[0 0 .3 .5])

for Indx_B = 1:numel(BandLabels)
    
    Band = Bands.(BandLabels{Indx_B});
    Band = dsearchn(Freqs', Band'); % get index of band limits
    
    Data = Power(:, Band(1):Band(2));
    Data = log(Data);
    Data = nansum(Data, 2).*FreqRes;
    Min = min(Data);
    Max = max(Data);
    
   subplot(2, 2, Indx_B)
   topoplot(Data, Chanlocs, 'style', 'map', 'headrad', 'rim', ...
      'maplimits', [Min, Max], 'gridscale', Format.TopoRes);
   title(BandLabels{Indx_B})

    colorbar
    set(gca, 'FontName', Format.FontName, 'FontSize', 14)
end

colormap(Format.Colormap.Linear)