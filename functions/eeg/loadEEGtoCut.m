function EEG = loadEEGtoCut(Source, Destination, FilteredFilename, Randomize)
% loads EEG and specifies where cut information is saved. If only EEG
% folder is provided, then a randomly chosen EEG from those not done will
% get Cut.
Extention = '_Cuts.mat';
Done = false;

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Randomly choose a file that hasn't been cut yet

if Randomize && isempty(FilteredFilename)
    
    Unchecked = string(ls(Source));
    Unchecked(contains(Unchecked, '.')) = [];
    
    while isempty(FilteredFilename) % find an uncut file
        
        % if there aren't any unchecked folders left, you're done!
        if isempty(Unchecked)
            disp(['You are finished with ', Source, ...
                '! If you want to redo one of the files, specify the filename.'])
            return
        end
        
        % randomly choose a task folder
        Indx = randi(numel(Unchecked));
        Folder = Unchecked(Indx);
        
        AllEEG = ls(fullfile(Source, Folder));
        AllEEG = AllEEG(contains(string(AllEEG), '.set'), :); % only take sets
        AllEEG = extractBefore(cellstr(AllEEG), '_Cutting.set'); % get filename cores
        
        AllCuts = ls(fullfile(Destination, Folder)); % do the same for the cut files
        AllCuts = AllCuts(contains(string(AllCuts), '.mat'), :);
        AllCuts = extractBefore(cellstr(AllCuts), Extention);
        
        % select list of all files that don't already have cuts file
        Uncut = AllEEG;
        Uncut(contains(AllEEG, intersect(AllEEG, AllCuts))) = [];
        
        if ~isempty(Uncut) % randomly select one of the uncut files left
            FilteredFilename = [Uncut{randi(numel(Uncut))}, '_Cutting.set'];
            Source = fullfile(Source, Folder);
            Source = Source{1};
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

