function [Trials, RT, Types, Tots] = loadBehavior(Participants, Sessions, Task, Paths, Refresh)
% single function to load main outcomes for PVT and LAT.
% LAT types are Lapses, Late, and Correct Responses.
% PVT types are Lapses (<.5), Correct Responses and Bugs.

Filepath_Table = fullfile(Paths.Data, 'Behavior');

if ~exist(Filepath_Table, 'dir')
    mkdir(Filepath_Table)
end

Filename_Table = [Task, '_AllAnswers.mat'];

AllData = struct();

% get behavior data
if ~exist(fullfile(Filepath_Table, Filename_Table), 'file') || Refresh
    AllAnswers = importTask(Paths.Datasets, Task, Filepath_Table);
else
    load(fullfile(Filepath_Table, Filename_Table), 'AllAnswers')
end

% make it in a nice table
switch Task
    case 'LAT'
        Answers = cleanupLAT(AllAnswers);
    case 'PVT'
        Answers = cleanupPVT(AllAnswers);
    otherwise
        error('unknown task')
end

% include only data in selected participants & sessions
Trials = Answers(ismember(Answers.Participant, Participants) & ...
    ismember(Answers.Session, Sessions), :);


% RT
[RT, ~] = tabulateTable(Trials, 'RT', 'mean', Participants, Sessions, []);


% lapses, correct responses, etc
[Types, ~] = tabulateTable(Trials, 'Type', 'tabulate', Participants, Sessions, []);

% total trials
Tots = squeeze(sum(Types, 3, 'omitnan'));



