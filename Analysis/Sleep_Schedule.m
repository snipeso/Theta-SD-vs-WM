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

CSV = readtable(fullfile(Paths.Data, 'Logs', 'Schedule.csv'));
CSV(~ismember(CSV.ParticipantID, Participants), :) = [];

%%
%%% BL

SleepLabels = {
    'BL', 'BL_sleep', 'BL_wake_';
    'Pre', 'Main1_sleep', 'Main1_wake';
    'Post', 'Main2_sleep', 'Main2_wake';
    };

TaskLabels = {'BL_tasks', 'Session1', 'Session2'};

clc

% Average and range of bed times
BedTimes = str2time(CSV.(SleepLabels{1, 2}));
[~, BT_I_Min] = min(timeDiff(6, BedTimes));
[~, BT_I_Max] = max(timeDiff(6, BedTimes));
Mean_BT = mean(timeDiff(6, BedTimes));
Mean_BT = timeDiff(-6, Mean_BT);

disp(['BL Min Bed: ', CSV.(SleepLabels{1, 2}){BT_I_Min}, '; Max Bed: ', CSV.(SleepLabels{1, 2}){BT_I_Max}, '; Mean Bed: ', time2str(Mean_BT)])


% average and range of wake times
WakeTimes = str2time(CSV.(SleepLabels{1, 3}));
[~, WT_I_Min] = min(WakeTimes);
[~, WT_I_Max] = max(WakeTimes);
Mean_WT = mean(WakeTimes);

disp(['BL Min Wake: ', CSV.(SleepLabels{1, 3}){WT_I_Min}, '; Max Wake: ', CSV.(SleepLabels{1, 3}){WT_I_Max}, '; Mean Wake: ', time2str(Mean_WT)])


%%% Pre

% Average and range of bed times
BedTimes = str2time(CSV.(SleepLabels{2, 2}));
[~, BT_I_Min] = min(timeDiff(6, BedTimes));
[~, BT_I_Max] = max(timeDiff(6, BedTimes));
Mean_BT = mean(timeDiff(6, BedTimes));
Mean_BT = timeDiff(-6, Mean_BT);

disp(['Pre Min Bed: ', CSV.(SleepLabels{2, 2}){BT_I_Min}, '; Max Bed: ', CSV.(SleepLabels{2, 2}){BT_I_Max}, '; Mean Bed: ', time2str(Mean_BT)])


% average and range of wake times
WakeTimes = str2time(CSV.(SleepLabels{2, 3}));
[~, WT_I_Min] = min(WakeTimes);
[~, WT_I_Max] = max(WakeTimes);
Mean_WT = mean(WakeTimes);

disp(['Pre Min Wake: ', CSV.(SleepLabels{2, 3}){WT_I_Min}, '; Max Wake: ', CSV.(SleepLabels{2, 3}){WT_I_Max}, '; Mean Wake: ', time2str(Mean_WT)])

%%% Post

% Average and range of bed times
BedTimes = str2time(CSV.(SleepLabels{3, 2}));
[~, BT_I_Min] = min(BedTimes);
[~, BT_I_Max] = max(BedTimes);
Mean_BT = mean(BedTimes);

disp(['Post Min Bed: ', CSV.(SleepLabels{3, 2}){BT_I_Min}, '; Max Bed: ', CSV.(SleepLabels{3, 2}){BT_I_Max}, '; Mean Bed: ', time2str(Mean_BT)])


% average and range of wake times
WakeTimes = str2time(CSV.(SleepLabels{3, 3}));
[~, WT_I_Min] = min(WakeTimes);
[~, WT_I_Max] = max(WakeTimes);
Mean_WT = mean(WakeTimes);

disp(['Post Min Wake: ', CSV.(SleepLabels{3, 3}){WT_I_Min}, '; Max Wake: ', CSV.(SleepLabels{3, 3}){WT_I_Max}, '; Mean Wake: ', time2str(Mean_WT)])



%% average sleep durations
for Indx_N = 1:3
    Diff = timeDiff(CSV.(SleepLabels{Indx_N, 2}), CSV.(SleepLabels{Indx_N, 3}));
    Mean = mean(Diff);
    disp([SleepLabels{Indx_N, 1}, ' mean sleep duration: ',  time2str(Mean) ' [', time2str(min(Diff)) ' ', time2str(max(Diff)) ']'])
end


%%
% Average BL, S1, SD

for Indx_T = 1:3
    L = TaskLabels{Indx_T};
    Times = str2time(CSV.(L));
    Mean = mean(Times);
    
    [~, Min] = min(Times);
    [~, Max] = max(Times);
    disp([L, ' Min: ', CSV.(L){Min}, '; Max: ', CSV.(L){Max}, '; Mean: ', time2str(Mean)])
end

%%
% BL - WO
Diff = timeDiff(CSV.(SleepLabels{1, 3}), CSV.(TaskLabels{1}));
Mean = mean(Diff);
disp([ 'BL time to task: ',  num2str(Mean*60), '; STD: ', num2str(std(Diff)*60),  ' [', num2str(min(Diff)*60) ' ', num2str(max(Diff)*60) ']'])


% average S1 - BL

% average S2-S1

% average S1 - Wakeup


