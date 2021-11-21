function EEG = loadEEGtoCut(Source, Destination, FilteredFilename, Subfolders, ifExists)
% loads EEG and specifies where cut information is saved. If only EEG
% folder is provided, then a randomly chosen EEG from those not done will
% get Cut.
% Source is the folder with the subfolders for each task containg the SET
% files (128Hz srate) for cleaning ("{core}_Cutting.set").
% Destination is the folder where to save the "{core}_Cuts.mat" files.
% FilteredFilename, if not empty, should contain a specific file to clean
% when needing to fix a specific file and are no longer concerned about
% anonymization.
% Randomize, if not empty, provides the list of subfolders to choose from.
% ifExists is either "Cuts" or "ICA"; depending on the answer, checks if
% there exists already a cuts file or the ICA file; this is for second-pass
% cleaning, since step E will delete all ICA files if "redo" was selected.

Extention = '_Cuts.mat';

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Randomly choose a file that hasn't been cut yet

if isempty(FilteredFilename)
    
    if isempty(Subfolders) % choose from all possible folders in Source
        Unchecked = string(ls(Source));
        Unchecked(contains(Unchecked, '.')) = [];
    else
        Unchecked = Subfolders;
    end
    
    while isempty(FilteredFilename) % find an uncut file
        
        % if there aren't any unchecked folders left, you're done!
        if isempty(Unchecked)
            disp(['You are finished with ', Source, ...
                '! If you want to redo one of the files, specify the filename.'])
            return
        end
        
        % randomly choose a task folder
        Indx = randi(numel(Unchecked));
        Folder = Unchecked{Indx};
        
        AllEEG = ls(fullfile(Source, Folder));
        AllEEG = AllEEG(contains(string(AllEEG), '.set'), :); % only take sets
        AllEEG = extractBefore(cellstr(AllEEG), '_Cutting.set'); % get filename cores
        
        % check if it has already been done
        switch ifExists
            case 'Cuts' % see if cuts file already exists
                All_Cuts = string(ls(fullfile(Destination, Folder))); % do the same for the cut files
                All_Cuts = All_Cuts(contains(All_Cuts, '.mat'), :);
                All_Cuts = extractBefore(cellstr(All_Cuts), Extention);
                
                % select list of all files that don't already have cuts file
                Uncut = AllEEG;
                Uncut(contains(AllEEG, intersect(AllEEG, All_Cuts))) = [];
                
            case 'ICA' % see if ICA file already exists
                ICA_Folder = fullfile(extractBefore(Destination, 'Cutting'), 'ICA', 'Components', Folder);
                
                All_ICA = string(ls(ICA_Folder)); % do the same for the ICA files
                All_ICA = All_ICA(contains(All_ICA, '.set'), :);
                All_ICA = extractBefore(cellstr(All_ICA), '_ICA_');
                
                % select list of all files that don't already have ICA file
                Uncut = AllEEG;
                Uncut(contains(AllEEG, intersect(AllEEG, All_ICA))) = [];
                
            otherwise % just choose randomly
                Uncut = AllEEG;
        end
        
        if ~isempty(Uncut) % randomly select one of the uncut files left
            FilteredFilename = [Uncut{randi(numel(Uncut))}, '_Cutting.set'];
            Source = fullfile(Source, Folder);
            Destination = fullfile(Destination, Folder);
        else % if no more uncut files, remove this folder from list
            Unchecked(Indx) = [];
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load the EEG file

CutFilename = [extractBefore(FilteredFilename, '_Cutting.set'), Extention];

% load EEG
EEG = pop_loadset('filename', FilteredFilename, 'filepath', Source);
clc % don't show filename info

% save the corresponding file inside the mat file.
if ~exist(Destination, 'dir')
    mkdir(Destination)
end

CutFilepath = fullfile(Destination, CutFilename);
m = matfile(CutFilepath,'Writable',true);
m.filename = FilteredFilename;
m.filepath = Source;
m.srate = EEG.srate;

EEG.CutFilepath = CutFilepath;

