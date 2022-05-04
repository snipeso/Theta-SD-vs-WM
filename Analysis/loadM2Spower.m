function [AllData, Freqs, Chanlocs, AllTrials] = loadM2Spower(P, Source)
% load "locked" power from short term memory task.

Task = 'Match2Sample';

AllData = nan(numel(P.Participants), numel(P.Sessions.Labels));
AllTrials = struct();
AllTrials.level = nan(numel(P.Participants), numel(P.Sessions.Labels), 120);
AllTrials.correct = AllTrials.level;
AllTrials.RT = AllTrials.level;

for Indx_P = 1:numel(P.Participants)
    for Indx_S = 1:numel(P.Sessions.Labels)
        
        Filename = strjoin({P.Participants{Indx_P}, Task, P.Sessions.(Task){Indx_S}, 'Welch_Locked.mat'}, '_');
        Path = fullfile(Source, Filename);
        
        if ~exist(Path, 'file')
            warning(['Missing ', Filename])
            if not(Indx_P==1 && Indx_S ==1)
                AllData(Indx_P, Indx_S, 1:Dims(1), 1:Dims(2),  1:Dims(3), 1:Dims(4)) = nan; %#ok<NODEF>
            end
            continue
        end
        
        load(Path, 'Power', 'Freqs', 'Chanlocs', 'Trials')
        
        Dims = size(Power);
        
        if isempty(Power)
            AllData(Indx_P, Indx_S, 1:Dims(1), 1:Dims(2),  1:Dims(3), 1:Dims(4)) = nan;
            continue
        end
        
        AllData(Indx_P, Indx_S, 1:Dims(1), 1:Dims(2),  1:Dims(3), 1:Dims(4)) = Power;
        clear Power
        
        AllTrials.level(Indx_P, Indx_S, :) = Trials.level;
        AllTrials.correct(Indx_P, Indx_S, :) = Trials.correct;
        AllTrials.RT(Indx_P, Indx_S, :) = Trials.RT;
    end
end