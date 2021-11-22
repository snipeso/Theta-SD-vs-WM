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

CSV = readtable(fullfile(Paths.Preprocessed, 'Final', 'Tables'));


%%
% Average and range of bed times
BedTimes = str2time(CSV.BL_sleep);
[~, BT_I_Min] = min(timeDiff(6, BedTimes));
[~, BT_I_Max] = max(timeDiff(6, BedTimes));

Mean_BT = mean(timeDiff(6, BedTimes));
Mean_BT = timeDiff(-6, Mean_BT);

disp(['Min Bed: ', CSV.BL_sleep{BT_I_Min}, '; Max Bed: ', CSV.BL_sleep{BT_I_Max}, '; Mean Bed: ', time2str(Mean_BT)])


% average and range of wake times

% average sleep durations


% Average BL, S1, SD

% average S1 - BL

% average S2-S1

% average S1 - Wakeup


