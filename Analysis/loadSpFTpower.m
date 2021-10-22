function [AllData, Freqs, Chanlocs, AllTrials] = loadSpFTpower(P, Source)


Task = 'SpFT';

AllData = nan(numel(P.Participants), numel(P.Sessions.Labels));
AllTrials = struct();
AllTrials.ID = nan(numel(P.Participants), numel(P.Sessions.Labels), 20);
AllTrials.correct = AllTrials.ID;
AllTrials.incorrect = AllTrials.ID;
AllTrials.RT =  AllTrials.ID;

for Indx_P = 1:numel(P.Participants)
    for Indx_S = 1:numel(P.Sessions.Labels)
        
        Filename = strjoin({P.Participants{Indx_P}, Task, P.Sessions.(Task){Indx_S}, 'Welch_Locked.mat'}, '_');
        Path = fullfile(Source, Filename);
        
        if ~exist(Path, 'file')
            warning(['Missing ', Filename])
            if not(Indx_P==1 && Indx_S ==1 && Indx_T==1)
                AllData(Indx_P, Indx_S, 1:Dims(1), 1:Dims(2),  1:Dims(3), 1:Dims(4)) = nan; %#ok<NODEF>
            end
            continue
        end
        
        load(Path, 'Power', 'Freqs', 'Chanlocs', 'Trials')
        
        Dims = size(Power);
        
        if isempty(Power)
            AllData(Indx_P, Indx_S, 1:Dims(1), 1:Dims(2),  1:Dims(3), 1:Dims(4)) = nan;
            continue
        elseif sum(isnan(squeeze(Power(:, 1, 1, 1)))) > 10 || sum(isnan(squeeze(Power(:, 2, 1, 1)))) > 10 % if more than half of trials are bad, remove session from participant
              AllData(Indx_P, Indx_S, 1:Dims(1), 1:Dims(2),  1:Dims(3), 1:Dims(4)) = nan;
              warning(['Too many bad trials for ', Filename])
        else     
        AllData(Indx_P, Indx_S, 1:Dims(1), 1:Dims(2),  1:Dims(3), 1:Dims(4)) = Power;
        end
      
        clear Power
        
        AllTrials.ID(Indx_P, Indx_S, :) = Trials.Sentence;
        AllTrials.correct(Indx_P, Indx_S, :) = Trials.Correct;
        AllTrials.incorrect(Indx_P, Indx_S, :) = Trials.Incorrect;
        AllTrials.RT(Indx_P, Indx_S, :) = Trials.RT;
    end
end