function [Answers, Correct] = loadM2Sbehavior(Path, Participants, Sessions)

Answers_Path = fullfile(Path, 'Match2Sample_AllAnswers.mat');
load(Answers_Path, 'Answers')

Levels = unique(Answers.level);
nLevels = numel(Levels);
nParticipants = numel(Participants);
nSessions = numel(Sessions.Match2Sample);

% load data
Correct = nan(nParticipants, nSessions, nLevels); % percent correct
for Indx_P = 1:nParticipants
    for Indx_S = 1:nSessions
        for Indx_L = 1:nLevels
            T = Answers(strcmp(Answers.Participant, Participants{Indx_P}) & ...
                strcmp(Answers.Session, Sessions.Match2Sample{Indx_S}) & ...
                Answers.level == Levels(Indx_L), :);
            Tot = size(T, 1);
            C = nnz(T.correct==1);
            
            Correct(Indx_P, Indx_S, Indx_L) = 100*C/Tot;
        end
    end
end