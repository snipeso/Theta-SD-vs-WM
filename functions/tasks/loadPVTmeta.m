function AllData = loadPVTmeta(P, Sessions, Refresh)
% script for loading metadata about the PVT sessions (P x S x T) Provides:
% - RT: reaction times (0-2s)
% - Tally: whether a trial is classified as a lapse, a correct response or
% late.

Paths = P.Paths;
Participants = P.Participants;

Filepath_Table = fullfile(Paths.Data, 'Behavior');

if ~exist(Filepath_Table, 'dir')
    mkdir(Filepath_Table)
end

Filename_Table = 'PVT_AllAnswers.mat';

AllData = struct();

% get behavior data
if ~exist(fullfile(Filepath_Table, Filename_Table), 'file') || Refresh
    AllAnswers = importTask(Paths.Datasets, 'PVT', Filepath_Table);
else
    load(fullfile(Filepath_Table, Filename_Table), 'AllAnswers')
end

% make it in a nice table
Answers = cleanupPVT(AllAnswers);


% set it all up in matrices
TotTrials = 75;
AllData.RT = nan(numel(Participants), numel(Sessions), TotTrials); % use only first 100 trials
AllData.Tally = AllData.RT;

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
       
            % gather subset of data
            Indexes = strcmp(Answers.Participant, Participants{Indx_P}) & ...
                strcmp(Answers.Session, Sessions{Indx_S});
            
            if nnz(Indexes) == 0
                continue
            elseif nnz(Indexes) < TotTrials
                error('not enough trials in a block')
            elseif nnz(Indexes) > TotTrials
                Indexes = find(Indexes, TotTrials, 'first');
            end
            
            RT = Answers.RT(Indexes);
            
            % create tally
            Tally = nan(nnz(Indexes), 1);
            Tally(RT <= .5) = 3;
            Tally(RT > .5) = 2;
            Tally(isnan(RT)) = 1;
            
            
            % load into structure

            AllData.RT(Indx_P, Indx_S, :) = RT;
            AllData.Tally(Indx_P, Indx_S, :) = Tally;
    end
end



