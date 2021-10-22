% does what "importTask" does for the standard tasks; saves all the answers
% into one big table in the destination folder

clear
clc
close all

P = spft_Parameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;

Destination = fullfile(Paths.Data, 'Behavior');
if ~exist(Destination, 'dir')
    mkdir(Destination)
end

File = 'SpFT_AllAnswers.mat';

% get all sentences and assign a number
All = readtable('All_Sentences.csv');
All = table2cell(All);

Answers = table();

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        
        Scoring_Path = fullfile(Paths.Datasets, Participants{Indx_P}, 'SpFT', Sessions{Indx_S}, 'Scoring');
        Content = deblank(string(ls(Scoring_Path)));
        Content(~contains(Content, '.csv')) = [];
        
        if isempty(Content)
            warning([Path, ' is empty'])
            continue
        elseif numel(Content) ~= 20 % if there arent all the trials
           warning([Path ' is missing files!'])
           continue
        end
        
        for Indx_T = 1:numel(Content)
            CSV = readtable(fullfile(Scoring_Path, Content(Indx_T)));
            A= 1;
            
            ID = find(sum(ismember(All, CSV.Sentence))==numel(CSV.Sentence));
            if isempty(ID)
                error('mistake!')
            elseif numel(ID)==2 % stupid hack to deal with "cooks cook" sentence
                ID = ID(1);
            end
            
            Score = table2cell(CSV(:, 2:end));
            Correct = nnz(strcmp(Score, 'o'));
            Incorrect = nnz(strcmp(Score, 'x'));
            
            MetaData = split(Content(Indx_T), '_');
            Order = str2double(MetaData(4));
            
            Answers = [Answers; {Participants{Indx_P}, Sessions{Indx_S}, Order, ID, Correct, Incorrect}];
            
        end
        
        
    end
end

Answers.Properties.VariableNames = {'Participant', 'Session', 'Trial', 'Sentence', 'Correct', 'Incorrect'};

save(fullfile(Destination, File), 'Answers')
