function [Answers, Labels] = loadAllBAT(Filepath, Participants, Sessions, Tasks)
% loads all the questionnaire data into a struct, with each field
% representing a different question, and holding a P x S x T matrix

qIDs = {'BAT_1', 'BAT_3_0', 'BAT_3', ...
    'BAT_3_1', 'BAT_4', 'BAT_4_1', ...
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
for Indx_Q = 1:numel(qIDs)
   Answers.(Titles{Indx_Q}) = nan(numel(Participants), numel(Sessions.Labels), numel(Tasks)); 
end


for Indx_T = 1:numel(Tasks)
   CSV = readtable(fullfile(Filepath, [Tasks{Indx_T}, '_All.csv'])); 
   
    % Fix qID problem
   CSV.qID(strcmp(CSV.qLabels, 'Frustrating/Neutral/Relaxing')) = {'BAT_3_0'};
    
    for Indx_Q = 1:numel(qIDs)
        
        qID = qIDs{Indx_Q};
        
        % this was named differently just for P01
        if strcmp(qID, 'BAT_1') && nnz(strcmp(CSV.qID, 'BAT_6'))
            CSV.qID(strcmp(CSV.qID, 'BAT_6')) = {'BAT_1'};
        end
        
        [Data, L] = table2matrix(CSV, Participants, Sessions.(Tasks{Indx_T}), qID, 'numAnswer');
        
        if Indx_T == 1 % just once
           Labels.(Titles{Indx_Q}) = L; 
        end
        
        Answers.(Titles{Indx_Q})(:, :, Indx_T) = Data;
    end
end



