function plotSpectrumFlames(Data, Freqs, xLog, xLims, Format)
% plots spectrum changes of all participants, with mean change on top in
% black.
% Data is a P x 2 x F matrix.

Dims = size(Data);

for Indx_P = 1:Dims(1)
    figure
    plotPatch(squeeze(Data(Indx_P, :, :)), Freqs, 'pos', Format.Colors.Participants(Indx_P, :), ...
        0.2, 0.5, xLog, xLims, Format) % little numbers are alpha and linewidth
end

% plot mean
Data = squeeze(nanmean(Data, 1));
plotPatch(Data, Freqs, 'pos', 'k', 0.3, 1, xLog, xLims, Format)