% Scripts for looking at sleep scoring. Saves a table in the Stats folder
% of the paper.

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load and set parameters

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
Nights = P.Nights;

% sleep architecture specific labels
Stages = {'wake',  'n1', 'n2', 'n3', 'rem',};
ExtraVariables = {'sol', 'sd', 'waso', 'se', 'rol'};
TableLabels = {'Wake (min)', 'N1', 'N2', 'N3' 'REM', 'SOL', 'SD', 'WASO', 'SE', 'ROL'};

Results = fullfile(Paths.Results, 'Sleep');
if ~exist(Results, 'dir')
    mkdir(Results)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% gather data from everyone

Stages_Matrix = nan(numel(Participants), numel(Nights)+1, numel(Stages));
ExtraVariables_Matrix = nan(numel(Participants), numel(Nights)+1, numel(Stages));

for Indx_P = 1:numel(Participants)
    
    % get sleep data
    for Indx_N  = 1:numel(Nights)
        
        % get location
        Folder = strjoin({Participants{Indx_P}, 'Sleep', Nights{Indx_N}}, '_');
        Path = fullfile(Paths.Scoring, 'Sleep', Folder);
        
        % get scoring info
        [Percent, Minutes, SleepQuality] = loadScoring(Path);
        
        % load into matrices
        for Indx_S = 1:numel(Stages)
            Stages_Matrix(Indx_P, Indx_N, Indx_S) = Minutes.(Stages{Indx_S});
        end
        
        for Indx_eV = 1:numel(ExtraVariables)
            ExtraVariables_Matrix(Indx_P, Indx_N, Indx_eV) = SleepQuality.(ExtraVariables{Indx_eV});
        end
    end
    
    %%% get MWT data (for potential future reference)
    Folder = strjoin({Participants{Indx_P}, 'MWT', 'Main'}, '_');
    Path = fullfile(Paths.Scoring, 'MWT', Folder);
    
    % get scoring info
    [Percent, Minutes, SleepQuality] = loadScoring(Path);
    if isempty(fieldnames(Percent))
        continue
    end
    
    % load into matrices
    for Indx_S = 1:numel(Stages)
        Stages_Matrix(Indx_P, end, Indx_S) = Minutes.(Stages{Indx_S});
    end
    
    for Indx_eV = 1:numel(ExtraVariables)
        ExtraVariables_Matrix(Indx_P, end, Indx_eV) = SleepQuality.(ExtraVariables{Indx_eV});
    end
end

%% Table 1

% join variables
Matrix = cat(3, Stages_Matrix(:, 1:numel(Nights), :), ExtraVariables_Matrix(:, 1:numel(Nights), :));
Labels = [Stages, ExtraVariables];


% create table
Table = sleepArchitecture(Matrix, TableLabels, Nights);
disp(Table)

writetable(Table, fullfile(P.Paths.PaperStats, 'Sleep_Architecture.csv'));


%% Display change from baseline as average
clc

for Indx_S = 1:numel(Stages)
   BL = squeeze(Stages_Matrix(:, 1, Indx_S));
   SD = squeeze(Stages_Matrix(:, 3, Indx_S));
    
    Change = nanmean(100*((SD-BL)./BL));
    disp([Stages{Indx_S}, ' SD change from BL: ', num2str(round(Change)), '%'])
end

