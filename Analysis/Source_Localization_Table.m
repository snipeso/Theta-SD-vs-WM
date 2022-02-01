% This script takes the data in source space, identifies significant
% regions, and saves them in a table.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

Refresh = true;
ValueType = 'mean';


P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Bands = P.Bands;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run statistics

%%% load in data

TablePath = fullfile(Paths.Data, 'EEG', 'Source', 'Table');

switch ValueType
    case 'mean'
        File_All_sdTheta = 'mtrx_all_tasks.mat';
        File_fmTheta = 'mtrx_M2S_levels.mat';
        File_sdTheta = 'mtrx_M2S_BS_vs_S2_lvl1.mat';
        
    case 'median'
        File_All_sdTheta = 'mtrx_all_tasks_median.mat';
        File_fmTheta = 'mtrx_M2S_levels_median.mat';
        File_sdTheta = 'mtrx_M2S_BS_vs_S2_lvl1_median.mat';
        
    otherwise
        error('wrong ValueType')
end

% theta in all tasks
load(fullfile(TablePath, File_All_sdTheta), 'cortical_areas', 'mtrx_all_crtx')
AllTheta = nanmean(mtrx_all_crtx, 5);
Areas = cortical_areas;
Areas = replace(Areas, '_', ' ');

% theta in L3vsL1
load(fullfile(TablePath, File_fmTheta), 'mtrx_cortex')
fmTheta = nanmean(mtrx_cortex, 4);

% theta in BL vs SD of L1
load(fullfile(TablePath, File_sdTheta), 'mtrx_cortex')
sdTheta = nanmean(mtrx_cortex, 4);


% keep together for the following loops
Theta = cat(3, AllTheta, fmTheta, sdTheta);

Dims = size(Theta);

%%% get t-values
tValues = nan(Dims(3), Dims(4));
pValues = tValues;

for Indx_T = 1:Dims(3)
    Data1 = squeeze(Theta(:, 1, Indx_T, :));
    Data2 = squeeze(Theta(:, 2, Indx_T, :));
    Stats = pairedttest(Data1, Data2, P.StatsP);
    
    tValues(Indx_T, :) = Stats.t;
    pValues(Indx_T, :) = Stats.p_fdr;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot and save











