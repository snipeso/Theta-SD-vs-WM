function AllAnswers = importTask(DatasetPaths, Task, Destination)
% TEMP: old function to load in task data

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

% find all paths
[Subfolders, Datasets] = AllFolderPaths(DatasetPaths, 'PXX', false, {'CSVs', 'Lazy', 'P00'});

if isempty(Datasets) || isempty(Subfolders)
    error('Did not find any data during task import')
end

% get only paths related to task
Subfolders(~contains(Subfolders, Task)) = [];
Subfolders(~contains(Subfolders, 'Behavior')) = [];

AllAnswers = table();
for Indx_P = 1:size(Datasets, 1)
    for Indx_S = 1:numel(Subfolders)
        
        %%% get filename
        Participant = deblank(Datasets(Indx_P, :));
        Folder = fullfile(DatasetPaths, Participant, Subfolders{Indx_S});
        Files = cellstr(ls(Folder));
        
        Files(~contains(Files, '.log')) = [];
        Files(contains(Files, 'configuration')) = [];
        
        % skip if there's a problem
        if numel(Files) < 1
            
            warning(strjoin([Participant, Subfolders{Indx_S}, ' is empty']))
            
            continue
        elseif numel(Files)>1

         warning(strjoin([Folder, ' has too many files']))
            continue
        end
        
        % get from path session info etc
        Session = extractBetween(Subfolders{Indx_S}, [Task, '\'], '\Behavior');
        extraFields = {'Participant', 'Task', 'Session', 'Filename';
            Participant, Task, Session{1}, Files{1}};
        
        Output = importOutput(fullfile(Folder, Files{1}), 'table', extraFields);
        
        % deal with stupid exceptions
        OutputColNames = Output.Properties.VariableNames;
        CurrentColNames = AllAnswers.Properties.VariableNames;
        for Indx_C = 1:numel(OutputColNames)
            ColName = OutputColNames{Indx_C};
            Col = Output.(ColName);
            if ~iscell(Col)
                Output.(ColName) = num2cell(Col);
            end
            
            % add new column to mega table if it doesn't already have it
            if ~any(ismember(CurrentColNames, OutputColNames{Indx_C}))
                AllAnswers.(ColName) = cell([size(AllAnswers, 1), 1]);
            end
        end
        
        % add missing columns to Output
        MissingCol = setdiff(CurrentColNames, OutputColNames);
        for Indx_C = 1:numel(MissingCol)
            Output.(MissingCol{Indx_C}) = cell([size(Output, 1), 1]);
        end
        
        
        
        AllAnswers = [AllAnswers; Output];
    end
    
end

% deal with stupid empty cells
for Indx_C = 1:numel(CurrentColNames)
    emptyCells = cellfun('isempty', AllAnswers.(CurrentColNames{Indx_C}));
    if nnz(emptyCells) < 1
        continue
    end
    AllAnswers.(CurrentColNames{Indx_C})(emptyCells) = {nan};
end


% save
save(fullfile(Destination, [Task, '_AllAnswers.mat']), 'AllAnswers')