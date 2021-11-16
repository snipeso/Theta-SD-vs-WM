% This script gets looped in "E_RemoveComponents" until the user is
% satisfied with cleanliness of the file.

close all
clc

% run classification if it doesn't exist
if ~isfield(EEG.etc, 'ic_classification') % this is for those hundred-odd files that got ICA components before I implemented this in part D
    EEG = iclabel(EEG); % this is an EEGLAB function
end

% automatically identify bad components if there no components selected
if ~any(EEG.reject.gcompreject)
    disp('********** Automatically selecting components to remove **********')
    
    % mark as bad anything with brain < threshold
    EEG.reject.gcompreject = ...
        EEG.etc.ic_classification.ICLabel.classifications(:, 1)' < IC_Brain_Threshold;
    
    % switch to good any of the bad channels with "other" too high
    Other = EEG.reject.gcompreject & ...
        EEG.etc.ic_classification.ICLabel.classifications(:, end)' > IC_Other_Threshold;
    EEG.reject.gcompreject(Other) = 0;
    
    EEG.reject.gcompreject(IC_Max+1:end) = 0; % don't do anything to smaller components
end


%%% show components removed
if CheckOutput
    
    % open interface for selecting components
    Pix = get(0,'screensize');
    
    % turn red all the bad components
    nComps = size(EEG.icaweights,1);
    Colors = repmat(StandardColor, nComps, 1);
    Colors(find(EEG.reject.gcompreject)) =  {[1, 0, 0]}; %#ok<FNDSB>
    
    % plot in time all the components
    tmpdata = eeg_getdatact(EEG, 'component', 1:nComps);
    eegplot( tmpdata, 'srate', EEG.srate,  'spacing', 5, 'dispchans', 40, ...
        'winlength', 20, 'position', [0 0 Pix(3) Pix(4)*.97], ...
        'color',Colors, 'limits', [EEG.xmin EEG.xmax]*1000);
end

%%% merge data with component structure
NewEEG = EEG; % gets everything from IC structure
NewEEG.data = Data.data; % replaces data
NewEEG.pnts = Data.pnts; % replaces data related fields
NewEEG.srate = Data.srate;
NewEEG.xmax = Data.xmax;
NewEEG.times = Data.times;
NewEEG.event = Data.event;
NewEEG.icaact = [];

%%% remove components
badcomps = find(EEG.reject.gcompreject); % get indexes of selected components
NewEEG = pop_subcomp(NewEEG, badcomps);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot outcome
if CheckOutput
    
    % load post-ICA bad channels if they alread exist
    badchans_postICA = []; %#ok<NASGU>
    load(fullfile(Source_Cuts, Filename_Cuts), 'badchans_postICA')
    BC = badchans_postICA;
    badchans_postICA = labels2indexes(badchans_postICA, NewEEG.chanlocs);
    
    % color in red channels to remove after ICA
    Colors = repmat(StandardColor, size(NewEEG.data, 1), 1);
    Colors(badchans_postICA) = {[1 0 0]};
    Pix = get(0,'screensize');
    
    % plot pre and post data
    eegplot(Data.data, 'spacing', 20, 'srate', NewEEG.srate, ...
        'winlength', 20, 'position', [0 0 Pix(3) Pix(4)*.97],  'eloc_file', Data.chanlocs)
    eegplot(NewEEG.data,'spacing', 20, 'srate', NewEEG.srate, ...
        'winlength', 20, 'position', [0 0 Pix(3) Pix(4)*.97], 'eloc_file', ...
        NewEEG.chanlocs,  'winrej',  TMPREJ, 'color', Colors)
    
    % plot standard power bands topography to detect final outliers in
    % clean parts of data
    [EEGTMP, ~] = eeg_eegrej(NewEEG, eegplot2event(TMPREJ, -1));
    EEGTMP = pop_select(EEGTMP, 'nochannel', badchans_postICA); % remove bad channels from topography
    PlotSpectopo(EEGTMP, 1, EEGTMP.xmax);
    
    % plot data as image to spot outliers
    figure('units','normalized','outerposition',[0 .70 1 .35])
    imagesc(abs(EEGTMP.data)); caxis([0 100]); colorbar
    colormap(colorcet('L8'))
    
    %%%%%%%%%%%%%%%
    %%% User input
    
    %%% Is component selection ok
    % if selection has problems, go over the components again
    clc
    disp('Instructions: First check if any major noisy components were missed or miss-removed. If...')
    disp('Comp selection is ok, type y and press enter, or just press enter')
    disp('Some missing comps, make a list of all the bad comps, and then press enter. Must be at least 2')
    disp('Its all terrible, type n and press enter')
    disp('__________________________________________________________________________________________')
    xComp = input('Is the COMPONENT selection ok? ');
    
    if isempty(xComp)
        xComp = y;
    end
    
    if isnumeric(xComp) % if list of components
        
        % plot single component windows
        pop_prop(EEG, 0, xComp, gcbo, { 'freqrange', [1 40]});
        
        % print IC weights to figure out what went wrong with classification
        %  classes: {'Brain'  'Muscle'  'Eye'  'Heart'  'Line Noise'  'Channel Noise'  'Other'}
        clc
        disp([[1:nComps]', EEG.etc.ic_classification.ICLabel.classifications])
        
        % wait, only proceed when prompted
        disp('press enter to proceed')
        pause
        
        % save IC dataset, now containing new components to remove
        pop_saveset(EEG, 'filename', Filename_Comps,  'filepath', Source_Comps, ...
            'check', 'on', 'savemode', 'onefile', 'version', '7.3');
        
    elseif ~strcmp(xComp, 'y') % if answered n, or anything else
        
        pop_selectcomps(EEG, 1:IC_Max); % plot grid of all components
        
        % wait, only proceed when prompted
        disp('press enter to proceed')
        pause
        
        % save IC dataset, now containing new components to remove
        pop_saveset(EEG, 'filename', Filename_Comps,  'filepath', Source_Comps, ...
            'check', 'on', 'savemode', 'onefile', 'version', '7.3');
    end
    
    %%% Is final product ok?
    if strcmp(xComp, 'y') % if component selection was ok, see if final product is ok
        clc
        disp('Instructions: look at final EEG.')
        disp('If all is good, type y and press enter')
        disp('If you want to try comp selection again, type n')
        disp('If its unfixable, or cutting was done wrong, type redo')
        disp('If you dont want to deal with it now, press s')
        disp('If its mostly fine, but you want to remove a few extra channels, just list them.')
        disp(['bad ch: ', num2str(BC)])
        xEEG = input('Is the EEG ok? (y/n/s/redo/channel list) ');
        
        % add new bad channels to the list
        if isnumeric(xEEG)
            rmCh_postICA(fullfile(Source_Cuts, Filename_Cuts), xEEG)
            xEEG = 'y';
        end
    else
        xEEG = 'n';
    end
else
    xEEG = 'auto';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% save or loop, depending on response

% if it's good, interpolate bad channels and save
if strcmp(xEEG, 'y') || strcmp(xEEG, 'auto')
    
    % remove bad channels
    badchans_postICA = []; %#ok<NASGU>, just in case this variable is not present below
    load(fullfile(Source_Cuts, Filename_Cuts), 'badchans_postICA') % manually selected bad channels
    
    NotEEGCh = labels2indexes([EEG_Channels.notEEG, badchans_postICA], NewEEG.chanlocs); % convert based on already removed channels
    
    NewEEG = pop_select(NewEEG, 'nochannel', [badchans_postICA, NotEEGCh]);
    
    % interpolate channels
    FinalChanlocs = StandardChanlocs;
    FinalChanlocs(ismember({StandardChanlocs.labels}, string(EEG_Channels.notEEG))) = [];
    FinalChanlocs(end+1) = CZ;
    NewEEG = pop_interp(NewEEG, FinalChanlocs);
    
    % save new dataset
    pop_saveset(NewEEG, 'filename', Filename_Destination, ...
        'filepath', Destination, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
    close all
    clc
    disp(['***********', 'Finished ', Filename_Destination, '***********'])
end

% determine what happens next
switch xEEG
    case 'y' % end
        Break = true;
        disp(['Completed in: ', num2str(toc(StartTic)/60)])
        
    case 's' % go to another file
        Break = false;
        
    case 'auto' % go to another file
        % save it and move on to the next one
        Break = false;
        
    case 'redo' % end
        % completely deletes components file
        delete(fullfile(Source_Comps, Filename_Comps))
        
        % restore "bad" channels to remove after ICA
        badchans_postICA = []; %#ok<NASGU>
        load(fullfile(Source_Cuts, Filename_Cuts), 'badchans_postICA')
        BC = badchans_postICA;
        rsCh_postICA(fullfile(Source_Cuts, Filename_Cuts), badchans_postICA)
        
        disp(['***********', 'Deleting ', Filename_Destination, '***********'])
        close all
        Break = true;
        
    otherwise % loop again
        % re-do
        RemoveComps
end


% To fix if removed wrong channel, run the following, and rerun this section
% rsCh_postICA(fullfile(Source_Cuts, Filename_Cuts), [])
% CheckOutput = false;

