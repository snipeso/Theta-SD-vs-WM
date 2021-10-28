function Answers = cleanupLAT(AllAnswers)
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

Answers.Block = cell2mat(AllAnswers.block);
Answers.Delay = cell2mat(AllAnswers.delay);
Answers.RT = cell2mat(AllAnswers.rt);
Answers.isRight = strcmp(AllAnswers.hemifield, 'right');

Answers.RT(Answers.RT<.1) = nan;


% convert coordinates into radius and angle
Coordinates = cell2mat(AllAnswers.coordinates');

[theta, rho] = cart2pol(Coordinates(1, :), Coordinates(2, :));
Answers.Radius = rho';
Answers.Angle = theta';