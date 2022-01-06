% scripts for looking at sleep scoring


clear
clc
close all

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
StatsP = P.StatsP;
Nights = P.Nights;


Variables = {'wake',  'n1', 'n2', 'n3', 'rem',};
sqVariables = {'sol', 'sd', 'waso', 'se', 'rol'};

TableLabels = {'Wake (min)', 'N1', 'N2', 'N3' 'REM', 'SOL', 'SD', 'WASO', 'SE', 'ROL'};


Results = fullfile(Paths.Results, 'Sleep');
if ~exist(Results, 'dir')
    mkdir(Results)
end


%%% gather data from everyone
Variables_Matrix = nan(numel(Participants), numel(Nights)+1, numel(Variables));
sqVariables_Matrix = nan(numel(Participants), numel(Nights)+1, numel(Variables));

for Indx_P = 1:numel(Participants)
    
    % get sleep data
    for Indx_N  = 1:numel(Nights)
        
        % get location
        Folder = strjoin({Participants{Indx_P}, 'Sleep', Nights{Indx_N}}, '_');
        Path = fullfile(Paths.Scoring, 'Sleep', Folder);
        
        % get scoring info
        [Percent, Minutes, SleepQuality] = loadScoring(Path);
        
        % load into matrices
        for Indx_V = 1:numel(Variables)
            Variables_Matrix(Indx_P, Indx_N, Indx_V) = Minutes.(Variables{Indx_V});
        end
        
        for Indx_sqV = 1:numel(sqVariables)
            sqVariables_Matrix(Indx_P, Indx_N, Indx_sqV) = SleepQuality.(sqVariables{Indx_sqV});
        end
    end
    
    % get MWT data
    
    
    Folder = strjoin({Participants{Indx_P}, 'MWT', 'Main'}, '_');
    Path = fullfile(Paths.Scoring, 'MWT', Folder);
    
    % get scoring info
    [Percent, Minutes, SleepQuality] = loadScoring(Path);
    if isempty(fieldnames(Percent))
        continue
    end
    
    % load into matrices
    for Indx_V = 1:numel(Variables)
        Variables_Matrix(Indx_P, end, Indx_V) = Minutes.(Variables{Indx_V});
    end
    
    for Indx_sqV = 1:numel(sqVariables)
        sqVariables_Matrix(Indx_P, end, Indx_sqV) = SleepQuality.(sqVariables{Indx_sqV});
    end
end

%%

% join variables
Matrix = cat(3, Variables_Matrix(:, 1:numel(Nights), :), sqVariables_Matrix(:, 1:numel(Nights), :));
Labels = [Variables, sqVariables];


% create table
Table = sleepArchitecture(Matrix, TableLabels, Nights);
disp(Table)

writetable(Table, fullfile(P.Paths.PaperStats, 'Sleep_Architecture.csv'));


%% create table with MWT
Matrix = cat(3, Variables_Matrix(:, [1 3 4], :), sqVariables_Matrix(:, [1 3 4], :));
Labels = [Variables, sqVariables];


% create table
Table = sleepArchitecture(Matrix, TableLabels, {'BL', 'Recovery', 'MWT'});
disp(Table)

writetable(Table, fullfile(Results, 'Sleep_Architecture_MWT.csv'));



%% Display change from baseline as average %
clc

for Indx_V = 1:numel(Variables)
   BL = squeeze(Variables_Matrix(:, 1, Indx_V));
   SD = squeeze(Variables_Matrix(:, 3, Indx_V));
    
    Change = nanmean(100*((SD-BL)./BL));
    disp([Variables{Indx_V}, ' SD change from BL: ', num2str(round(Change)), '%'])
end

