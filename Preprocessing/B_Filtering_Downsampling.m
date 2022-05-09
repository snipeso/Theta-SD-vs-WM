% Sorts files by relevant folder, and applies selected preprocessing to
% selected task batch.

close all
clc
clear
Prep_Parameters


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tasks = {'LAT'}; % select this if you only need to filter one folder
% Tasks = allTasks;

Destination_Formats = {'Waves'}; % chooses which filtering to do
% options: 'Scoring', 'Cutting', 'ICA', 'Power'

Refresh = false; % redo files that are already in destination folder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Consider only relevant subfolders
Folders.Subfolders(~contains(Folders.Subfolders, Tasks)) = [];
Folders.Subfolders(~contains(Folders.Subfolders, 'EEG')) = [];


for Indx_DF = 1:numel(Destination_Formats)
    Destination_Format = Destination_Formats{Indx_DF};

    % set selected parameters
    new_fs = Parameters.(Destination_Format).fs;
    lowpass = Parameters.(Destination_Format).lp;
    highpass = Parameters.(Destination_Format).hp;
    hp_stopband = Parameters.(Destination_Format).hp_stopband;


    for Indx_D = 1:size(Folders.Datasets,1) % loop through participants
        for Indx_F = 1:size(Folders.Subfolders, 1) % loop through all subfolders

            %%%%%%%%%%%%%%%%%%%%%%%%
            %%% Check if data exists

            Path = fullfile(Paths.Datasets, deblank(Folders.Datasets{Indx_D}), Folders.Subfolders{Indx_F});

            % skip rest if folder not found
            if ~exist(Path, 'dir')
                warning([deblank(Path), ' does not exist'])
                continue
            end

            % identify meaningful folders traversed
            Levels = split(Folders.Subfolders{Indx_F}, '\');
            Levels(cellfun('isempty',Levels)) = []; % remove blanks
            Levels(strcmpi(Levels, 'EEG')) = []; % remove uninformative level that its an EEG

            Task = Levels{1}; % task is assumed to be the first folder in the sequence

            % if does not contain EEG, then skip
            Content = ls(Path);
            SET = contains(string(Content), '.set');
            if ~any(SET)
                if any(strcmpi(Levels, 'EEG')) % if there should have been an EEG file, be warned
                    %%% ELIAS: you remove the EEG information from Levels in line 55
                    %%% so you would never enter this if statement, no?
                    warning([Path, ' is missing SET file'])
                end
                continue
            elseif nnz(SET) > 1 % if there's more than one set file, you'll need to fix that
                warning([Path, ' has more than one SET file'])
                continue
            end

            Filename_SET = Content(SET, :);

            % set up destination location
            Destination = fullfile(Paths.Preprocessed, Destination_Format, 'MAT', Task);
            Filename_Core = join([deblank(Folders.Datasets{Indx_D}), Levels(:)', Destination_Format], '_');
            Filename_Destination = [Filename_Core{1}, '.mat'];

            % create destination folder
            if ~exist(Destination, 'dir')
                mkdir(Destination)
            end

            % skip filtering if file already exists
            if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
                disp(['***********', 'Already did ', Filename_Core, '***********'])
                continue
            end


            %%%%%%%%%%%%%%%%%%%
            %%% process the data

            EEG = pop_loadset('filepath', Path, 'filename', Filename_SET);

            % low-pass filter
            EEG = pop_eegfiltnew(EEG, [], lowpass); % this is a form of antialiasing, but it not really needed because usually we use 40hz with 256 srate

            % notch filter for line noise
            EEG = lineFilter(EEG, 50, false);

            % resample
            if EEG.srate ~= new_fs
                EEG = pop_resample(EEG, new_fs);
            end

            % high-pass filter
            % NOTE: this is after resampling, otherwise crazy slow.
            EEG = hpEEG(EEG, highpass, hp_stopband);

            EEG = eeg_checkset(EEG);


            % save preprocessing info in eeg structure
            EEG.setname = Filename_Core;
            EEG.filename = Filename_Destination;
            EEG.original.filename = Filename_SET;
            EEG.original.filepath = Path;
            EEG.filtering = Parameters.(Destination_Format);

            % save EEG
            pop_saveset(EEG, 'filename', Filename_Destination, ...
                'filepath', Destination, ...
                'check', 'on', ...
                'savemode', 'onefile', ...
                'version', '7.3');
            %             save(fullfile(Destination, Filename_Destination), 'EEG', '-v7.3')
        end

        disp(['************** Finished ',  Folders.Datasets{Indx_D}, '***************'])
    end
end