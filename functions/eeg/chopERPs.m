function ERPs = chopERPs(EEG, Trigger, Window, BL_Window)
% function for extracting all the ERPs around a certain trigger

fs = EEG.srate;

AllTriggers =  {EEG.event.type};
AllTriggerTimes =  [EEG.event.latency];

TriggerTimes = AllTriggerTimes(strcmp(AllTriggers, Trigger));

Starts = round(TriggerTimes + Window(1)*fs);
Points = round(fs*(Window(2)-Window(1)));


ERPs = nan(numel(Starts), numel(EEG.chanlocs), Points );
for Indx_E = 1:numel(Starts)
    Start = Starts(Indx_E);
    Stop = Start+Points-1;
    
    if Start <= 0
        continue
    end
    if Stop > size(EEG.data, 2)
        continue
    end
    
    Epoch = EEG.data(:, Start:Stop);

                                                                                        
    % remove all epochs with 1/3 nan values
    if nnz(isnan(Epoch(1, :))) >  Points/3
        continue
    end
    
    % baseline correction
    if exist('BL_Window', 'var')
        BL_Points = round(fs*(BL_Window(2)-BL_Window(1)));
        Start_BL = round(fs*BL_Window(1)) - round(fs*Window(1));
        Stop_BL = Start_BL+BL_Points-1;
        
        BL = nanmean(Epoch(:, Start_BL:Stop_BL), 2);
        STD_BL = nanstd(Epoch(:, Start_BL:Stop_BL), 0, 2);
        Epoch = (Epoch - BL)./STD_BL;
    end
    
    ERPs(Indx_E, :, :) = Epoch;
end
