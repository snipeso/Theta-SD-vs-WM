function Answers = cleanupPVT(AllAnswers)
% Take table from AllAnswers, save relevant information and make it in the
% correct format type.

Answers = AllAnswers(:, {'Participant', 'Session'});

Answers.Participant = string(Answers.Participant);
Answers.Session = string(Answers.Session);
Answers.Trial = cell2mat(AllAnswers.sequence_number);

% get trial ID
TotTrials = numel(Answers.Trial);
Answers.Trigger = cell(TotTrials, 1);
for Indx_T = 1:TotTrials
    Struct = AllAnswers.trialID{Indx_T};

    Answers.Trigger(Indx_T) = {Struct.triggers};

end

Answers.Delay = cell2mat(AllAnswers.delay);
Answers.RT = cell2mat(AllAnswers.rt);

% deal with false alarms and bugs
Bugs = Answers.RT<.1;
Answers.RT(Bugs) = nan;
Answers.Type = ones(TotTrials, 1);
Answers.Type(Answers.RT<.5) = 2;
Answers.Type(Bugs) = 3;