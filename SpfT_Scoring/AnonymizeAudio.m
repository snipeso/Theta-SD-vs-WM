% script for taking all audio files, saving them to a new location with a
% number for a filename, along with a blank CSV. The researcher then goes
% through all of them and does the scoring


P = spft_Parameters();

Participants = P.Participants;
Sessions = P.Sessions;
Paths = P.Paths;
nTrials = P.nTrials;

% assemble table of filepaths
AllData = table();

for Indx_P = 1:numel(Participants)
   for Indx_S = 1:numel(Sessions) 
     Folder = string(fullfile(Paths.Datasets, Participants{Indx_P}, 'SpFT', Sessions{Indx_S}, 'Recordings'));
     Files = deblank(string(ls(Folder)));
     Files(~contains(Files, '.wav')) = [];
     T = table();
     T.Path = repmat(Folder, numel(Files), 1);
     T.Filename = Files;
     AllData = [AllData; T];
       
   end
end

% randomize and assign number
NFiles = size(AllData, 1);
AllData.ID = randperm(NFiles, NFiles);
AllData = sortrows(AllData, 'ID');

% go through table, get audio, copy into destination folder with CSV

Destination = fullfile(Paths.Scoring, 'Scoring_Anonymized');
if ~exist(Destination, 'dir')
    mkdir(Destination)
end
    
for Indx_F = 1:NFiles
    Old = fullfile(AllData.Path(Indx_F), AllData.Filename(Indx_F));
    Core = ['SpFT_',num2str(AllData.ID(Indx_F), '%03.f')];
    New = fullfile(Destination, [Core, '.wav']);
    
    copyfile(Old, New)
    writetable(table(), fullfile(Destination, [Core, '.csv']))
    
end


% save table in the folder
writetable(AllData, fullfile(Destination, 'All_Paths.csv'))
