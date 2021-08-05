function [AllData, Freqs, Chanlocs] = loadAllPower(P)
% load all power from main tasks.
% Results in variable "AllData": P x S x T x Ch x F; and Chanlocs and Freqs

Filepath =  fullfile(P.Paths.Data, 'EEG', 'Unlocked');

AllData = nan(numel(P.Participants), numel(P.Sessions.LAT), numel(P.AllTasks));
for Indx_P = 1:numel(P.Participants)
    for Indx_S = 1:numel(P.Sessions.LAT)
        
        for Indx_T = 1:numel(P.AllTasks)
            Task = P.AllTasks{Indx_T};
            
            Filename = strjoin({P.Participants{Indx_P},Task, P.Sessions.(Task){Indx_S}, 'Welch.mat'}, '_');
            Path = fullfile(Filepath, Task, Filename);
            
            if ~exist(Path, 'file')
                warning(['Missing ', Filename])
                continue
            end
            
            load(Path, 'Power', 'Freqs', 'Chanlocs')
            if isempty(Power)
                continue
            end
            
            AllData(Indx_P, Indx_S, Indx_T, 1:numel(Chanlocs), 1:numel(Freqs)) = Power;
            clear Power
        end
    end
end