function plotEEGsample(EEG, ProtoChannel, Triggers, Channels, Scale, ProtoChannelColors, Format)
% function for plotting EEG data

if all(isnan(EEG.data(:)))
    error('No data!')
else
    EEG.data = double(EEG.data);
end

C =  [.75 .75 .75];
[nCh, nPnts] = size(EEG.data);

ProtoChannel = labels2indexes(ProtoChannel, EEG.chanlocs);

if isempty(Scale)
    Y_Gap = 4.5*nanmean(std(EEG.data'));
else
    Y_Gap = Scale;
end

Y = Y_Gap*nCh:-Y_Gap:0;

Min = -Y_Gap/2;
Max = Y(1)+Y_Gap;


t = linspace(0, nPnts/EEG.srate, nPnts);



hold on

% plot events
if ~isempty(Triggers)
    
TriggerLabels = fieldnames(Triggers);
TriggerStrings = struct2cell(Triggers);
    Events = EEG.event;
    
    for Indx_E = 1:numel(Events)
        String = Events(Indx_E).type;
        Indx = strcmp(TriggerStrings, String);
        
        if nnz(Indx) ~=1
            continue
        else
            Label = TriggerLabels{Indx};
        end
        
        x = Events(Indx_E).latency/EEG.srate;
        plot([x, x], [Min Max], 'Color', C, 'LineWidth', 1)
        text(x, Max+Y_Gap*1.5, Label, 'HorizontalAlignment', 'center', 'Color', C, 'FontName', Format.FontName, 'FontSize', Format.FontSize)
    end
    
end

% plot all the data
YLabels = {};


for Indx_Ch = 1:nCh
    % gather indexes
    if ~isempty(Channels) && any(ChannelIndexes==Indx_Ch)
        ChannelLabels = fieldnames(Channels);
ChannelIndexes = labels2indexes(struct2array(Channels), EEG.chanlocs);

        Label = ChannelLabels(ChannelIndexes==Indx_Ch);
        YLabels = cat(2, string(Label), YLabels);
        LC = 'k';
            
    yticks(sort(Y(ChannelIndexes)))
yticklabels(YLabels)

    else
        LC = [.3 .3 .3];
    end
    
    if ~isempty(ProtoChannel) && any(Indx_Ch == ProtoChannel)
        plot(t, EEG.data(Indx_Ch, :)+Y(Indx_Ch), ...
            'Color', ProtoChannelColors(Indx_Ch == ProtoChannel, :), 'LineWidth', 2)
    else
        plot(t, EEG.data(Indx_Ch, :)+Y(Indx_Ch), 'Color', LC, 'LineWidth', .5)
    end

end


ylim([Min Max+Y_Gap*2])
xlim([0, nPnts/EEG.srate])
xlabel('Time (s)')



% set(gca, 'FontSize', Format.FontSize, 'FontName', Format.FontName)



