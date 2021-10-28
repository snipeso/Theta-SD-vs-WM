function AllData = loadLATmeta(P, Sessions, Refresh)
% script for loading metadata about the LAT sessions (P x S x T) Provides:
% - RT: reaction times (0-2s)
% - Tally: whether a trial is classified as a lapse, a correct response or
% late.
% - Lat: lateralization, 0 -> left, 1 -> right
% - Radius: distance from center of stimulus
% - Angle: angle of stimulus

Paths = P.Paths;
Participants = P.Participants;

Filepath_Table = fullfile(Paths.Data, 'Behavior');

if ~exist(Filepath_Table, 'dir')
    mkdir(Filepath_Table)
end

Filename_Table = 'LAT_AllAnswers.mat';

AllData = struct();

% get behavior data
if ~exist(fullfile(Filepath_Table, Filename_Table), 'file') || Refresh
    AllAnswers = importTask(Paths.Datasets, 'LAT', Filepath_Table);
else
    load(fullfile(Filepath_Table, Filename_Table), 'AllAnswers')
end

% make it in a nice table
Answers = cleanupLAT(AllAnswers);


% set it all up in matrices
TotBlockTrials = 14;
AllData.RT = nan(numel(Participants), numel(Sessions), TotBlockTrials*6); % use only first 100 trials
AllData.Tally = AllData.RT;
AllData.Lat = AllData.RT;
AllData.Block = AllData.RT;
AllData.Radius = AllData.RT;
AllData.Angle = AllData.RT;
AllData.ID = AllData.RT;

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions)
        Start = 1;
        for Indx_B = 1:6
            
            % gather subset of data
            Indexes = strcmp(Answers.Participant, Participants{Indx_P}) & ...
                strcmp(Answers.Session, Sessions{Indx_S}) & ...
                Answers.Block == Indx_B;
            
            if nnz(Indexes) == 0
                continue
            elseif nnz(Indexes) < TotBlockTrials
                error('not enough trials in a block')
            elseif nnz(Indexes) > TotBlockTrials
                Indexes = find(Indexes, TotBlockTrials, 'first');
            end
            
            RT = Answers.RT(Indexes);
            
            % create tally
            Tally = nan(nnz(Indexes), 1);
            Tally(RT <= .5) = 3;
            Tally(RT > .5 & RT <= 1) = 2;
            Tally(isnan(RT)) = 1;
            
            
            % load into structure
            End = Start + TotBlockTrials - 1;
            AllData.RT(Indx_P, Indx_S, Start:End) = RT;
            AllData.Tally(Indx_P, Indx_S, Start:End) = Tally;
            AllData.Lat(Indx_P, Indx_S, Start:End) = Answers.isRight(Indexes);
            AllData.Radius(Indx_P, Indx_S, Start:End) = Answers.Radius(Indexes);
            AllData.Angle(Indx_P, Indx_S, Start:End) = Answers.Angle(Indexes);
            AllData.Block(Indx_P, Indx_S, Start:End) = Answers.Block(Indexes);
            AllData.ID(Indx_P, Indx_S, Start:End) = Answers.Trial(Indexes);
            
            Start = End + 1;
        end
    end
end



