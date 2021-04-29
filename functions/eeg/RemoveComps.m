% This script gets looped in "E_RemoveComponents" until the user is
% satisfied with cleanliness of the file.

close all
clc

if ~Automate
    
    % automatically identify bad components if there are no other components
    if ~any(EEG.reject.gcompreject)
        
        % run classification
        if ~isfield(EEG.etc, 'ic_classification')
            EEG = iclabel(EEG);
        end
        
        % mark as bad any "non brain" artifact with a confidence > IC_Threshold
        %         EEG.reject.gcompreject = max(EEG.etc.ic_classification.ICLabel.classifications(:, 2:end)') > IC_Threshold;
        % mark as bad anything with brain < .
        EEG.reject.gcompreject = EEG.etc.ic_classification.ICLabel.classifications(:, 1)' < IC_Threshold;
        EEG.reject.gcompreject(IC_Max+1:end) = 0;
    end
    
    % open interface for selecting components
    Pix = get(0,'screensize');
    
    % turn red all the components selected
    StandardColor = {[0.19608  0.19608  0.51765]};
    Colors = repmat(StandardColor, size(EEG.data, 1), 1);
    Colors(find(EEG.reject.gcompreject)) =  {[1, 0, 0]};
    
    % plot in time all the components
    tmpdata = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
    eegplot( tmpdata, 'srate', EEG.srate,  'spacing', 10, 'dispchans', IC_Max, ...
        'winlength', 20, 'position', [0 0 Pix(3) Pix(4)*.97], ...
        'color',Colors, 'limits', [EEG.xmin EEG.xmax]*1000);
    
    % if selection has problems, go over the components again
    y = 'y';
    n = 'n';
    x = input('Is the comp selection ok? (y/n/ or list of comps to plot) ');
    if isnumeric(x)
        pop_prop( EEG, 0, x, gcbo, { 'freqrange', [1 40] });
        
        % wait, only proceed when prompted
        disp('press enter to proceed')
        pause
    elseif ~strcmp(x, 'y')
        pop_selectcomps(EEG, 1:IC_Max);
        
        % wait, only proceed when prompted
        disp('press enter to proceed')
        pause
    end
    
    
end

badcomps = find(EEG.reject.gcompreject); % get indexes of selected components
clc
close all

if ~Automate % TODO: check if this really needs to happen after identifying "badcomps"
    
    % save dataset, now containing new components to remove
    pop_saveset(EEG, 'filename', Filename_Comps, ...
        'filepath', Source_Comps, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
end

% merge data with component structure
NewEEG = EEG;
NewEEG.data = Data.data;
NewEEG.pnts = Data.pnts;
NewEEG.srate = Data.srate;
NewEEG.xmax = Data.xmax;
NewEEG.times = Data.times;
NewEEG.event = Data.event;

% remove components
NewEEG = pop_subcomp(NewEEG, badcomps);

% low-pass filter
NewEEG = pop_eegfiltnew(NewEEG, [], Parameters.(Data_Type).lp); % for whatever reason, sometimes ICA removal introduces high frequency noise

% plot outcome
if CheckOutput
    Pix = get(0,'screensize');
    
    eegplot(Data.data, 'spacing', 20, 'srate', NewEEG.srate, ...
        'winlength', 20, 'position', [0 0 Pix(3) Pix(4)*.97],  'eloc_file', Data.chanlocs)
    eegplot(NewEEG.data,'spacing', 20, 'srate', NewEEG.srate, ...
        'winlength', 20, 'position', [0 0 Pix(3) Pix(4)*.97], 'eloc_file', NewEEG.chanlocs,  'winrej',  TMPREJ)
    
    [EEGTMP, ~] = eeg_eegrej(NewEEG,eegplot2event(TMPREJ, -1));
    PlotSpectopo(EEGTMP, 1, EEGTMP.xmax);
    
    pause(5) % wait a little so person can look
    x = input('Is the file ok? (y/n/s/redo)', 's');
else
    x = 'auto';
end

% interpolate channels
FinalChanlocs = StandardChanlocs;
FinalChanlocs(ismember({StandardChanlocs.labels}, string(EEG_Channels.notEEG))) = [];
FinalChanlocs(end+1) = CZ;
NewEEG = pop_interp(NewEEG, FinalChanlocs);

% save or loop, depending on response
switch x
    case 'y'
        % save new dataset
        pop_saveset(NewEEG, 'filename', Filename_Destination, ...
            'filepath', Destination, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        
        disp(['***********', 'Finished ', Filename_Destination, '***********'])
        close all
        Break = true;
        
    case 's'
        % skip this file, do another one
        Break = false;
        
    case 'auto'
        % save it and move on to the next one
        pop_saveset(NewEEG, 'filename', Filename_Destination, ...
            'filepath', Destination, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        clc
        close all
        Break = false;
    case 'redo'
        delete(fullfile(Source_Comps, Filename_Comps))
        disp(['***********', 'Deleting ', Filename_Destination, '***********'])
%         close all
        Break = true;
    otherwise
        % re-do
        RemoveComps
end

