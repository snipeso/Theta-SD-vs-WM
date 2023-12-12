% This script calculates the independent components on a specifically
% filtered data. It also uses the information from Cuts to remove bad
% channels and cut out bad time points. It uses the average reference, and
% has re-inserted CZ.

close all
clc
clear
Prep_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'Oddball'}; % select this if you only need to filter one folder
Dataset = 'Providence';
Refresh = false;

Source_Cuts_Folder = 'Cuts'; % 'Cuts'
Destination_Folder = 'Manual'; % 'Components'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('Cz.mat', 'CZ')

if ~exist('Tasks', 'var')
    Tasks = allTasks;
end

for Indx_T = 1:numel(Tasks)
    
    Task = Tasks{Indx_T};
    
    % get files and paths
    Source = fullfile(Paths.Preprocessed, 'ICA', 'MAT', Dataset, Task);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', Source_Cuts_Folder, Dataset, Task);
    Destination = fullfile(Paths.Preprocessed, 'ICA', Destination_Folder, Dataset, Task);
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.mat')) = [];
    
    for Indx_F = 1:numel(Files) % loop through files in target folder
        
        % get filenames
        Filename = Files{Indx_F};

        % skip if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename), 'file')
            disp(['***********', 'Already did ', Filename, '***********'])
            continue
        elseif ~exist(fullfile(Source_Cuts, Filename), 'file')
            disp(['***********', 'No cuts for ', Filename, '***********'])
            continue
        end
        
        % load dataset
        load(fullfile(Source, Filename), 'EEG')
        
        % convert to double
        EEG.data = double(EEG.data);
        
        % interpote bad snippets and remove bad channels
        [EEG, TMPREJ] = cleanCuts(EEG, fullfile(Source_Cuts, Filename));
        
        % add Cz
        EEG.data(end+1, :) = zeros(1, size(EEG.data, 2));
        EEG.chanlocs(end+1) = CZ;
        EEG = eeg_checkset(EEG);
        
        % remove bad segments in time
        if ~isempty(TMPREJ)
            EEG = eeg_eegrej(EEG, eegplot2event(TMPREJ, -1));
        end
        
        % rereference to average
        EEG = pop_reref(EEG, []);
        
        % run ICA (takes a while)
        Rank = sum(eig(cov(double(EEG.data'))) > 1E-7);
        if Rank ~= size(EEG.data, 1)
            warning(['Applying PCA reduction for ', Filename])
        end
        
        % calculate components
        EEG = pop_runica(EEG, 'runica', 'pca', Rank);
        
        % classify components
        EEG = iclabel(EEG);
        
        % save new dataset
        save(fullfile(Destination, Filename), 'EEG')
        disp(['***********', 'Finished ', Filename, '***********'])
        clear cutData srate badchans TMPREJ
    end
end