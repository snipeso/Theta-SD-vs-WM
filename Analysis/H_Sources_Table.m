% This script takes the data in source space, identifies significant
% regions, and saves them in a table.

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

ValueType = 'median';

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Bands = P.Bands;

TitleTag = 'H_Sources_Table';


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
AllTheta = nanmean(mtrx_all_crtx, 5); % average the different frequencies (4-8)
Areas = cortical_areas;
Areas = replace(Areas, '_', ' ');

Dims = size(AllTheta);

% theta in L3vsL1
load(fullfile(TablePath, File_fmTheta), 'mtrx_cortex')
fmTheta = reshape(nanmean(mtrx_cortex, 4), Dims(1), Dims(2), 1, Dims(4));

% theta in BL vs SD of L1
load(fullfile(TablePath, File_sdTheta), 'mtrx_cortex')
sdTheta = reshape(nanmean(mtrx_cortex, 4), Dims(1), Dims(2), 1, Dims(4));

% keep together for the following loops
Theta = cat(3, AllTheta, fmTheta, sdTheta);

Dims = size(Theta);

%%% get t-values
tValues = nan(Dims(3), Dims(4));
pValues = tValues;

for Indx_T = 1:Dims(3) % loop through contrasts
    Data1 = squeeze(Theta(:, 1, Indx_T, :));
    Data2 = squeeze(Theta(:, 2, Indx_T, :));
    Stats = pairedttest(Data1, Data2, P.StatsP);
    
    tValues(Indx_T, :) = Stats.t;
    pValues(Indx_T, :) = Stats.p_fdr;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot paper figures
%% Figure 9: table of significant areas

Keep = ~all(pValues > .05);
Sig = pValues <.05;

PlotProps = P.Manuscript;
PlotProps.Text.AxisSize = 10;
PlotProps.Text.TitleSize = 10;
PlotProps.Axes.xPadding = 5;

Grid = [1 10];

figure('units','centimeters','position',[0 0 PlotProps.Figure.W3 PlotProps.Figure.Height])

% all tasks
subfigure([], Grid, [1, 3], [1 Grid(2)-4], false, '', PlotProps);
plotExcelTable(tValues(1:numel(TaskLabels), Keep)', Sig(1:numel(TaskLabels), Keep)', Areas(Keep), ...
    TaskLabels,  't values', PlotProps)
colorbar off

% sdTheta vs fmTheta comparison
A = subfigure([], Grid, [1, Grid(2)-1], [1 2], false, '', PlotProps);
plotExcelTable(tValues(end-1:end, Keep)', Sig(end-1:end, Keep)', [], ...
    {'fmTheta', 'sdTheta'},  't values', PlotProps)
colorbar off

% save
saveFig([TitleTag, '_', ValueType], Paths.Paper, PlotProps)
