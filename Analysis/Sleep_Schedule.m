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
CSV(~ismember(CSV.ParticipantID, Participants), :) = [];

%%
%%% BL

Labels = {
'BL', 'BL_sleep', 'BL_wake_';
'Pre', 'Main1_sleep', 'Main1_wake';
'Post', 'Main2_sleep', 'Main2_wake';
};

clc

% Average and range of bed times
BedTimes = str2time(CSV.(Labels{1, 2}));
[~, BT_I_Min] = min(timeDiff(6, BedTimes));
[~, BT_I_Max] = max(timeDiff(6, BedTimes));
Mean_BT = mean(timeDiff(6, BedTimes));
Mean_BT = timeDiff(-6, Mean_BT);

disp(['BL Min Bed: ', CSV.(Labels{1, 2}){BT_I_Min}, '; Max Bed: ', CSV.(Labels{1, 2}){BT_I_Max}, '; Mean Bed: ', time2str(Mean_BT)])


% average and range of wake times
WakeTimes = str2time(CSV.(Labels{1, 3}));
[~, WT_I_Min] = min(WakeTimes);
[~, WT_I_Max] = max(WakeTimes);
Mean_WT = mean(WakeTimes);

disp(['BL Min Wake: ', CSV.(Labels{1, 3}){WT_I_Min}, '; Max Wake: ', CSV.(Labels{1, 3}){WT_I_Max}, '; Mean Wake: ', time2str(Mean_WT)])


%%% Pre

% Average and range of bed times
BedTimes = str2time(CSV.(Labels{2, 2}));
[~, BT_I_Min] = min(timeDiff(6, BedTimes));
[~, BT_I_Max] = max(timeDiff(6, BedTimes));
Mean_BT = mean(timeDiff(6, BedTimes));
Mean_BT = timeDiff(-6, Mean_BT);

disp(['Pre Min Bed: ', CSV.(Labels{2, 2}){BT_I_Min}, '; Max Bed: ', CSV.(Labels{2, 2}){BT_I_Max}, '; Mean Bed: ', time2str(Mean_BT)])


% average and range of wake times
WakeTimes = str2time(CSV.(Labels{2, 3}));
[~, WT_I_Min] = min(WakeTimes);
[~, WT_I_Max] = max(WakeTimes);
Mean_WT = mean(WakeTimes);

disp(['Pre Min Wake: ', CSV.(Labels{2, 3}){WT_I_Min}, '; Max Wake: ', CSV.(Labels{2, 3}){WT_I_Max}, '; Mean Wake: ', time2str(Mean_WT)])

%%% Post

% Average and range of bed times
BedTimes = str2time(CSV.(Labels{3, 2}));
[~, BT_I_Min] = min(BedTimes);
[~, BT_I_Max] = max(BedTimes);
Mean_BT = mean(BedTimes);

disp(['Post Min Bed: ', CSV.(Labels{3, 2}){BT_I_Min}, '; Max Bed: ', CSV.(Labels{3, 2}){BT_I_Max}, '; Mean Bed: ', time2str(Mean_BT)])


% average and range of wake times
WakeTimes = str2time(CSV.(Labels{3, 3}));
[~, WT_I_Min] = min(WakeTimes);
[~, WT_I_Max] = max(WakeTimes);
Mean_WT = mean(WakeTimes);

disp(['Post Min Wake: ', CSV.(Labels{3, 3}){WT_I_Min}, '; Max Wake: ', CSV.(Labels{3, 3}){WT_I_Max}, '; Mean Wake: ', time2str(Mean_WT)])



%% average sleep durations
for Indx_N = 1:3
    Diff = timeDiff(CSV.(Labels{Indx_N, 2}), CSV.(Labels{Indx_N, 3}));
    Mean = mean(Diff);
    disp([Labels{Indx_N, 1}, ' mean sleep duration: ',  time2str(Mean) ' [', time2str(min(Diff)) ' ', time2str(max(Diff)) ']'])
end


%%
% Average BL, S1, SD

% average S1 - BL

% average S2-S1

% average S1 - Wakeup


