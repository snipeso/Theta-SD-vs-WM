function Answers = cleanupMatch2Sample(AllAnswers)
% take table from AllAnswers, save relevant information

Answers = AllAnswers(:, {'Participant', 'Session', 'block', 'trial', 'startTime', ...
    'level'});

% remove from cell structure
Answers.Participant = string(Answers.Participant);
Answers.Session = string(Answers.Session);
Answers.block = cell2mat(Answers.block);
Answers.trial = cell2mat(Answers.trial);
Answers.startTime = cell2mat(Answers.startTime);
Answers.level = cell2mat(Answers.level);


Answers.response = strcmp(AllAnswers.responseTrigger, 'CorrectAnswer');
Answers.missed = ~isnan([AllAnswers.missed{1:end}])';

