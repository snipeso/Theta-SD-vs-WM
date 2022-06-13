% get set files, save to mat

% first script is for converting eeg files so there's a .set with the data.
close all
clear
clc
Prep_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = false;
Type = 'Sleep';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('StandardChanlocs128.mat', 'StandardChanlocs') % has channel locations in StandardChanlocs

Folders.Subfolders(~contains(Folders.Subfolders, Type)) = [];
Folders.Subfolders(~contains(Folders.Subfolders, 'EEG')) = [];

%%% loop through all EEG folders, and convert whatever files possible
for Indx_D = 1 %:size(Folders.Datasets, 1) % loop through participants
    for Indx_F = 1:3 %size(Folders.Subfolders, 1) % loop through all subfolders
        
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
        Content = getContent(Path);
        Filename_SET = Content(contains(Content, '.set'));
        Filename_MAT = replace(Filename_SET, '.set', '.mat');
        if isempty(Filename_SET)
                warning([Path, ' is missing SET files'])
            continue
        end
        
        % if file exists, and don't want to refresh, then skip rest of code
        if ~Refresh && exist(fullfile(Path, Filename_MAT), 'file')
            disp(['***********', 'Already did ', Filename.Core, '***********'])
            continue
        end
        
        % load EEG
        EEG = pop_loadset('filepath', Path, 'filename', char(Filename_SET));
        
        EEG = pop_resample(EEG, 200);
        
        % save
        try
        save(fullfile(Path, Filename_MAT), 'EEG', '-v7.3')
        catch
            warning(['Failed to save ', Filename.Core])
        end
    end
end