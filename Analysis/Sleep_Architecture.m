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

Participants = {'P01', 'P02', 'P04', 'P05', 'P06', 'P07', 'P08', ...
    'P09', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17', 'P19'};


Variables = {'wake',  'n1', 'n2', 'n3', 'rem',};
sqVariables = {'sol', 'sd', 'waso', 'se'};

TableLabels = {'Wake (min)', 'N1', 'N2', 'N3' 'REM', 'SOL', 'SD', 'WASO', 'SE'};


Results = fullfile(Paths.Results, 'Sleep');
if ~exist(Results, 'dir')
    mkdir(Results)
end


%%% gather data from everyone
Variables_Matrix = nan(numel(Participants), numel(Nights), numel(Variables));
sqVariables_Matrix = nan(numel(Participants), numel(Nights), numel(Variables));

for Indx_P = 1:numel(Participants)
    for Indx_N  = 1:numel(Nights)
        
        % get location
        Folder = strjoin({Participants{Indx_P}, 'Sleep', Nights{Indx_N}}, '_');
        Path = fullfile(Paths.Scoring, 'Sleep', Folder);
        
        % get scoring info
        [Percent, Minutes, SleepQuality] = loadVIS(Path);
        
        % load into matrices
        for Indx_V = 1:numel(Variables)
            Variables_Matrix(Indx_P, Indx_N, Indx_V) = Minutes.(Variables{Indx_V});
        end
        
        for Indx_sqV = 1:numel(sqVariables)
            sqVariables_Matrix(Indx_P, Indx_N, Indx_sqV) = SleepQuality.(sqVariables{Indx_sqV});
        end
        
    end
    disp(['Finished loading ', Participants{Indx_P}])
end

%%

% join variables
Matrix = cat(3, Variables_Matrix, sqVariables_Matrix);
Labels = [Variables, sqVariables];


% create table

Table = sleepArchitecture(Matrix, TableLabels, Nights)

writetable(Table, fullfile(Results, 'Sleep_Architecture.csv'));






