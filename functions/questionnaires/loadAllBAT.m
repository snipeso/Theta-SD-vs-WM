function [Answers, Labels] = loadAllBAT(Filepath, Participants, Sessions, Tasks)
% loads all the questionnaire data into a struct, with each field
% representing a different question, and holding a P x S x T matrix. Needs
% a CSV file with all the questionnaire data.

qIDs = {'BAT_1', 'BAT_3_s11', 'BAT_3_sl2', ...
    'BAT_3.1', 'BAT_4', 'BAT_4.1', ...
    'BAT_5', 'BAT_8'};

Titles = {'KSS';
    'Relaxing';
    'Interesting';
    
    'Focused';
    'Difficult';
    'Effortful';
    
    'Performance';
    'Motivation'};


% set up structures
Answers = struct();
Labels = struct();
Blank = nan(numel(Participants), numel(Sessions.(Tasks{1})), numel(Tasks));
for Indx_Q = 1:numel(qIDs)
    Answers.(Titles{Indx_Q}) = Blank;
end

Answers.Slept = Blank;

for Indx_T = 1:numel(Tasks)
    CSV = readtable(fullfile(Filepath, [Tasks{Indx_T}, '_All.csv']));
    
    % Fix qID problem
    CSV.qID(strcmp(CSV.qLabels, 'Frustrating/Neutral/Relaxing')) = {'BAT_3_s11'};
    
    for Indx_Q = 1:numel(qIDs)
        
        qID = qIDs{Indx_Q};
        
        % this was named differently just for P01
        if strcmp(qID, 'BAT_1') && nnz(strcmp(CSV.qID, 'BAT_6'))
            CSV.qID(strcmp(CSV.qID, 'BAT_6')) = {'BAT_1'};
        end
        
        [Data, L] = table2matrix(CSV, Participants, Sessions.(Tasks{Indx_T}), qID, 'numAnswer');
        
        if Indx_T == 1 % just once
            
            % deal with problem labels for "interesting"
            if strcmp(Titles{Indx_Q}, 'Interesting')
                Labels.(Titles{Indx_Q}) = {'Boring', 'Neutral', 'Fun/Interesting'};
            else
                Labels.(Titles{Indx_Q}) = L;
            end
        end
        
        Answers.(Titles{Indx_Q})(:, :, Indx_T) = Data;
    end
    
    % special case for question on sleep
    [Data, L] = table2matrix(CSV, Participants, Sessions.(Tasks{Indx_T}), 'BAT_7', 'numAnswer');
    
    Answers.Slept(:, :, Indx_T) = Data;
    Labels.Slept = L;
end

% set to nan all answers for a questionnaire when more than 4 participants are missing data
for Indx_T = 1:numel(Tasks)
    for Indx_Q = 1:numel(Titles)
        NanP = nnz(any(isnan(Answers.(Titles{Indx_Q})(:, :, Indx_T)), 2));
        
        if NanP > 4
            Answers.(Titles{Indx_Q})(:, :, Indx_T) = nan;
        end
    end
end

% adjust KSS labels
Labels.KSS(7:9) = {'Sleepy, but no effort to keep awake', 'Sleepy, some effort to keep awake', ...
    'Fighting sleep'}; % Fix

