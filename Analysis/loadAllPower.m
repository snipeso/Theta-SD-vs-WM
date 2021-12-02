function [AllData, Freqs, Chanlocs] = loadAllPower(P, Source, Tasks)
% [AllData, Freqs, Chanlocs] = loadAllPower(P, Source, Tasks)

% load all power from main tasks. Takes P from analysisParameters(), Source
% is the folder with the FFT data (split by task), and Tasks is the list
% of task folders to include.
% Results in variable "AllData": P x S x T x Ch x F; and Chanlocs and Freqs


AllData = nan(numel(P.Participants), numel(P.Sessions.Labels), numel(Tasks));

for Indx_P = 1:numel(P.Participants)
    for Indx_S = 1:numel(P.Sessions.Labels)
        
        for Indx_T = 1:numel(Tasks)
            Task = Tasks{Indx_T};

            %%% load data
            Filename = strjoin({P.Participants{Indx_P},Task, P.Sessions.(Task){Indx_S}, 'Welch.mat'}, '_');
            Path = fullfile(Source, Task, Filename);
            
            % deal with missing data
            if ~exist(Path, 'file')
                warning(['Missing ', Filename])
                if not(Indx_P==1 && Indx_S ==1 && Indx_T==1)
                    AllData(Indx_P, Indx_S, Indx_T, 1:numel(Chanlocs), 1:numel(Freqs)) = nan; %#ok<NODEF>
                end
                continue
            end
            
            load(Path, 'Power', 'Freqs', 'Chanlocs')
            
            % deal with weirdly missing data
            if isempty(Power)
                 AllData(Indx_P, Indx_S, Indx_T, 1:numel(Chanlocs), 1:numel(Freqs)) = nan;
                continue
            end
            
            % save
            AllData(Indx_P, Indx_S, Indx_T, 1:numel(Chanlocs), 1:numel(Freqs)) = Power;
            clear Power
        end
    end
end