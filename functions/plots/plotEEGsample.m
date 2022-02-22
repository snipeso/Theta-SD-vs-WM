function plotEEGsample(EEG, Start, Stop, HighlightChannels, HighlightColors, plotTriggers, Channels, Scale, PlotProps)
% plot a little window of EEG data.

% Channels is a Ch x 2 cell array, with the first colunm indicating the
% labels, and the second indicating the channel index according to 128
% channels. This can be found in P.Channels.Standard_10_20_All;


EEG = pop_select(EEG, 'time', [Start, Stop]);
HighlightChannels = labels2indexes(HighlightChannels, EEG.chanlocs);

if isempty(HighlightColors)
    HighlightColors = getColors(numel(HighlightChannels));
end

[nCh, nPnts] = size(EEG.data);
t = linspace(0, nPnts/EEG.srate, nPnts);

Events = EEG.event;

if plotTriggers % TODO
Events =  {'Stim', 1;
    'Response', 2;
    };
else
    Events = [];
end


YLabels = cell(1, nCh);
LabelIndexes = labels2indexes([Channels{:, 2}], EEG.chanlocs);
YLabels(LabelIndexes) = Channels(:, 1);

Data = double(EEG.data);

figure('units', 'normalized', 'outerposition', [0 0 1 1])
plotEpoch(Data, t, HighlightChannels, HighlightColors, YLabels, Events, Scale, PlotProps)
xlabel('Time (s)')
