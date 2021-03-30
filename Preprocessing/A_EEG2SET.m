% first script is for converting eeg files so there's a .set with the data.
close all
clear
clc
Prep_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('StandardChanlocs128.mat') % has channel locations in StandardChanlocs

%%% loop through all EEG folders, and convert whatever files possible
for Indx_D = 1:size(Folders.Datasets, 1) % loop through participants
    for Indx_F = 1:size(Folders.Subfolders, 1) % loop through all subfolders
        
        % get path
        Path = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, Folders.Subfolders{Indx_F});
        
        % skip rest if path not found
        if ~exist(Path, 'dir')
            warning([deblank(Path), ' does not exist'])
            continue
        end
        
        % identify menaingful folders traversed
        Levels = split(Folders.Subfolders{Indx_F}, '\');
        Levels(cellfun('isempty',Levels)) = []; % remove blanks
        
        
        % if does not contain EEG, then skip
        Content = ls(Path);
        VHDR = contains(string(Content), '.vhdr');
        if ~any(VHDR)
            if any(strcmpi(Levels, 'EEG'))
                warning([Path, ' is missing EEG files'])
            end
            continue
        elseif nnz(VHDR) > 1 % or if there's more than 1 file
            warning([Path, ' has more than one eeg file'])
            continue
        end
        
        % load EEG file
        Filename.VHDR = Content(VHDR, :);
        Filename.Core = extractBefore(Filename.VHDR, '.');
        Filename.SET = [Filename.Core, '.set'];
        disp(['***********', 'Loading ', Filename.Core, '***********'])
        
        % if file exists, and don't want to refresh, then skip rest of code
        if ~Refresh &&  any(contains(cellstr(Content), Filename.SET))
            disp(['***********', 'Already did ', Filename.Core, '***********'])
            continue
        end
        
        % load EEG, skip if this fails for some reason
        try
            EEG = pop_loadbv(Path, Filename.VHDR);
        catch
            warning(['Failed to load ', Filename.VHDR])
            continue
        end
        
        % update EEG structure
        EEG.ref = 'CZ';
        EEG.chanlocs = StandardChanlocs;
        EEG.info.oldname = Filename.VHDR;
        EEG.info.oldpath = Path;
        
        % save
        try
            pop_saveset(EEG, 'filename', Filename.SET, ...
                'filepath', Path, ...
                'check', 'on', ...
                'savemode', 'onefile', ...
                'version', '7.3');
        catch
            warning(['Failed to save ', Filename.Core])
        end
    end
end