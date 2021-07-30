% load all power from main tasks.
% Results in variable "AllData": P x S x T x Ch x F; and Chanlocs and Freqs

Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked');

AllData = nan(numel(Participants), numel(Sessions.LAT), numel(AllTasks));
for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions.LAT)
        
        for Indx_T = 1:numel(AllTasks)
            Task = AllTasks{Indx_T};
            
            Filename = strjoin({Participants{Indx_P},Task, Sessions.(Task){Indx_S}, 'Welch.mat'}, '_');
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