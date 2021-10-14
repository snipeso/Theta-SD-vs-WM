% script for taking all audio files, saving them to a new location with a
% number for a filename, along with a blank CSV. The researcher then goes
% through all of them and does the scoring
clear
clc
close all

%%% Load parameters
P = spft_Parameters();

Participants = P.Participants;
Sessions = P.Sessions;
Paths = P.Paths;
nTrials = P.nTrials;

%%% assemble table of filepaths
AllData = table();

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        
        % get all audio files
        Folder = string(fullfile(Paths.Datasets, Participants{Indx_P}, 'SpFT', Sessions{Indx_S}, 'Recordings'));
        Files = deblank(string(ls(Folder)));
        Files(~contains(Files, '.wav')) = [];
        
        if isempty(Files)
            warning(['Missing files for ', Participants{Indx_P}, ' ', Sessions{Indx_S}])
            continue
        end
        
        % sort files by actual trial order
        Meta = split(Files, '_');
        Indx = str2double(Meta(:, 4));
        [~, Order] = sort(Indx);
        Files = Files(Order);
        
        
        % get associated text
        JSON_Folder = replace(Folder, 'Recordings', 'Behavior');
        Content = deblank(string(ls(JSON_Folder)));
        Content(~contains(Content, '.log')) = [];
        JSON_File = Content(~contains(Content, '_configuration'));
        
        if numel(JSON_File) ~= 1
            warning(['Wrong behavior for ', Participants{Indx_P}, ' ', Sessions{Indx_S}])
            continue
        end
        
        Output = importOutput(fullfile(JSON_Folder, JSON_File), 'table');
        
        % save to mega table
        T = table();
        T.Path = repmat(Folder, numel(Files), 1);
        T.Filename = Files;
        T.Sentences = string(Output.sentence);
        AllData = [AllData; T]; %#ok<AGROW>
        
        
        
    end
end

%%% Randomize
NFiles = size(AllData, 1);
AllData.ID = randperm(NFiles, NFiles)';
AllData = sortrows(AllData, 'ID');

%%% go through table, get audio, copy into destination folder with CSV

% create folder
Destination = fullfile(Paths.Scoring, 'Scoring_Anonymized');
if ~exist(Destination, 'dir')
    mkdir(Destination)
else
    error('Folder already exists! You dont want to overwrite scoring')
end

% save table in the folder
AllData.Path = replace(AllData.Path, '\', '/');
writetable(AllData, fullfile(Destination, 'All_Paths.csv'))

% save anonymized file
for Indx_F = 1:NFiles
    Old = fullfile(AllData.Path(Indx_F), AllData.Filename(Indx_F));
    Core = ['SpFT_',num2str(AllData.ID(Indx_F), '%03.f')];
    New = fullfile(Destination, [Core, '.wav']);
    
    copyfile(Old, New)
    
    % save csv of sentences
    Columns =  ['Sentence', append('Round', string(1:20))];
    Sentence = split(AllData.Sentences(Indx_F));
    T = cell2table(cell(numel(Sentence),numel(Columns)), 'VariableNames', Columns);
    T.Sentence = Sentence;
    writetable(T, fullfile(Destination, [Core, '.csv']))
end

