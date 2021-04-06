% This script calculates the independent components on a specifically
% filtered data. It also uses the information from Cuts to remove bad
% channels and cut out bad time points. It uses the average reference, and
% has re-inserted CZ.

close all
clc
clear
Prep_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Tasks = {'Fixation'}; % select this if you only need to filter one folder

Refresh = false;

Source_Cuts_Folder = 'New_Cuts'; % 'Cuts'
Destination_Folder = 'Components'; % 'Components'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('Cz.mat', 'CZ')

for Indx_T = 1:numel(Tasks)
    Target = Tasks{Indx_T};
    % get files and paths
    Source = fullfile(Paths.Preprocessed, 'ICA', 'SET', Target);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', Source_Cuts_Folder, Target);
    Destination = fullfile(Paths.Preprocessed, 'ICA', Destination_Folder, Target);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files) % loop through files in target folder
        
        % get filenames
        Filename_Source = Files{Indx_F};
        Filename_Cuts =  [extractBefore(Filename_Source,'_ICA'), '_Cuts.mat'];
        Filename_Destination = [extractBefore(Filename_Source,'.set'), '_Components.set'];
        
        % skip if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['***********', 'Already did ', Filename_Destination, '***********'])
            continue
        elseif ~exist(fullfile(Source_Cuts, Filename_Cuts), 'file')
            disp(['***********', 'No cuts for ', Filename_Destination, '***********'])
            continue
        end
        
        % load dataset
        EEG = pop_loadset('filepath', Source, 'filename', Filename_Source);
        
        % load cuts
        load(fullfile(Source_Cuts, Filename_Cuts))
        if ~exist('badchans', 'var')
            badchans = [];
        end
        
        if ~exist('cutData', 'var')
            cutData = [];
        end
        
        
        % remove bad channels
        badchans(badchans<1 | badchans>128) = []; % this is a precaution from some previously badly written scripts
        EEG = pop_select(EEG, 'nochannel', unique(badchans));
        
        
        % clean data segments
        %         EEG = InterpolateSegments(EEG, badchans, cutData, srate);
        if ~isempty(cutData)
        EEG = interpolateSnippets(EEG, badchans, cutData, srate, true);
        end
        
        % add Cz
        EEG.data(end+1, :) = zeros(1, size(EEG.data, 2));
        EEG.chanlocs(end+1) = CZ;
        
        % remove bad segments
        if exist('TMPREJ', 'var')
            EEG = eeg_eegrej(EEG,eegplot2event(TMPREJ, -1));
        else
            A=1;
            error('breakpoint')
        end
        
        % rereference to average
        EEG = pop_reref(EEG, []);
        
        % run ICA (takes a while)
        EEG = pop_runica(EEG, 'runica');
        
        % save new dataset
        pop_saveset(EEG, 'filename', Filename_Destination, ...
            'filepath', Destination, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        
        disp(['***********', 'Finished ', Filename_Destination, '***********'])
    end
end