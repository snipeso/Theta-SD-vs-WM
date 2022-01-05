% scripts for calculating time differences in the schedule. Note: because
% of stupid 24h things, somtimes times get shifted by 1 or 6 hours so that
% the two time points fall within the same 24h cycle.

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
[~, BT_I_Min] = min(timeDiff(-6, BedTimes));
[~, BT_I_Max] = max(timeDiff(-6, BedTimes));
Mean_BT = mod(mean(timeDiff(-6, BedTimes))-6, 24);

disp(['BL bed time: ',  time2str(Mean_BT) ' [', CSV.(SleepLabels{1, 2}){BT_I_Min}, ' ',  CSV.(SleepLabels{1, 2}){BT_I_Max},']'])


% average and range of wake times
WakeTimes = str2time(CSV.(SleepLabels{1, 3}));
[~, WT_I_Min] = min(WakeTimes);
[~, WT_I_Max] = max(WakeTimes);
Mean_WT = mean(WakeTimes);

disp(['BL wake time: ',  time2str(Mean_WT) ' [', CSV.(SleepLabels{1, 3}){WT_I_Min}, ' ',   CSV.(SleepLabels{1, 3}){WT_I_Max},']'])


%%% Pre

% Average and range of bed times
BedTimes = str2time(CSV.(SleepLabels{2, 2}));
[~, BT_I_Min] = min(timeDiff(-6, BedTimes));
[~, BT_I_Max] = max(timeDiff(-6, BedTimes));
Mean_BT = mod(mean(timeDiff(-6, BedTimes))-6, 24);

disp(['SR bed time: ',  time2str(Mean_BT) ' [', CSV.(SleepLabels{2, 2}){BT_I_Min}, ' ',  CSV.(SleepLabels{2, 2}){BT_I_Max},']'])


% average and range of wake times
WakeTimes = str2time(CSV.(SleepLabels{2, 3}));
[~, WT_I_Min] = min(WakeTimes);
[~, WT_I_Max] = max(WakeTimes);
Mean_WT = mean(WakeTimes);

disp(['SR wake time: ',  time2str(Mean_WT) ' [', CSV.(SleepLabels{2, 3}){WT_I_Min}, ' ',   CSV.(SleepLabels{2, 3}){WT_I_Max},']'])


%%% Post

% Average and range of bed times
BedTimes = str2time(CSV.(SleepLabels{3, 2}));
[~, BT_I_Min] = min(BedTimes);
[~, BT_I_Max] = max(BedTimes);
Mean_BT = mean(BedTimes);

disp(['SD bed time: ',  time2str(Mean_BT) ' [', CSV.(SleepLabels{3, 2}){BT_I_Min}, ' ',  CSV.(SleepLabels{3, 2}){BT_I_Max},']'])


% average and range of wake times
WakeTimes = str2time(CSV.(SleepLabels{3, 3}));
[~, WT_I_Min] = min(WakeTimes);
[~, WT_I_Max] = max(WakeTimes);
Mean_WT = mean(WakeTimes);

disp(['SD wake time: ',  time2str(Mean_WT) ' [', CSV.(SleepLabels{3, 3}){WT_I_Min}, ' ',   CSV.(SleepLabels{3, 3}){WT_I_Max},']'])

disp('__________________________________')

%% average sleep durations
for Indx_N = 1:3
    Diff = timeDiff(timeDiff(-6, str2time(CSV.(SleepLabels{Indx_N, 2}))), timeDiff(-6, str2time(CSV.(SleepLabels{Indx_N, 3}))));
    disp([SleepLabels{Indx_N, 1}, ' mean sleep duration: ',  num2str(mean(Diff)), '; STD: ', num2str(std(Diff))])
end


disp('__________________________________')
%%
% Average BL, S1, SD

for Indx_T = 1:3
    L = TaskLabels{Indx_T};
    Times = str2time(CSV.(L));
    Mean = mean(Times);
    
    [~, Min] = min(Times);
    [~, Max] = max(Times);
    disp([L, ': ',  time2str(Mean), ' [', CSV.(L){Min} ', ',  CSV.(L){Max} ']'])
   
end

disp('__________________________________')
%% task block from WO
% BL - WO
Diff = timeDiff(CSV.(SleepLabels{1, 3}), CSV.(TaskLabels{1}));
Mean = mean(Diff);
disp([ 'BL time to task from sleep: ',  num2str(Mean), ' h; STD: ', num2str(std(Diff)),  ' [', num2str(min(Diff)) ' ', num2str(max(Diff)) ']'])


Diff = timeDiff(CSV.(SleepLabels{2, 3}), CSV.(TaskLabels{2}));
Mean = mean(Diff);
disp([ 'SR time to task from sleep: ',  num2str(Mean), ' h; STD: ', num2str(std(Diff)),  ' [', num2str(min(Diff)) ' ', num2str(max(Diff)) ']'])

Diff = timeDiff(CSV.(SleepLabels{2, 3}), CSV.(TaskLabels{3}));

 Diff = timeDiff(timeDiff(1, str2time(CSV.(SleepLabels{2, 3}))), mod(timeDiff(1, str2time(CSV.(TaskLabels{3}))), 24));
Mean = mean(Diff);
disp([ 'SD time to task from sleep: ',  num2str(Mean), ' h; STD: ', num2str(std(Diff)),  ' [', num2str(min(Diff)) ' ', num2str(max(Diff)) ']'])
disp('__________________________________')

%% task block time differences

% SD1-BL
Diff = timeDiff(CSV.(TaskLabels{1}), CSV.(TaskLabels{2}));
Mean = mean(Diff);
disp([ 'SR vs BL: ',  num2str(Mean*60), ' min; STD: ', num2str(std(Diff)*60),  ' [', num2str(min(Diff)*60) ' ', num2str(max(Diff)*60) ']'])


%  S2-S1
Diff = timeDiff(timeDiff(1, str2time(CSV.(TaskLabels{2}))), mod(timeDiff(1, str2time(CSV.(TaskLabels{3}))), 24));
Mean = mean(Diff);
disp([ 'SD vs SR: ',  num2str(Mean), ' h; STD: ', num2str(std(Diff)),  ' [', num2str(min(Diff)) ' ', num2str(max(Diff)) ']'])


% S2 - Pre SO
Diff = timeDiff(-6, str2time(CSV.(SleepLabels{2, 2})))-timeDiff(-6, str2time(CSV.(TaskLabels{3})));
Mean = mean(Diff);
disp([ 'SD - pre SO: ',  num2str(Mean*60), ' min; STD: ', num2str(std(Diff)*60),  ' [', num2str(min(Diff)*60) ' ', num2str(max(Diff)*60) ']'])

disp('__________________________________')


%% Time awake

WO = str2time(CSV.(SleepLabels{2, 3}));
SO = str2time(CSV.(SleepLabels{3, 2}));

Wake = SO+24 - WO;
disp([ 'Time awake: ',  num2str(mean(Wake)), ' h; STD: ', num2str(std(Wake)),  ' [', num2str(min(Wake)) ' ', num2str(max(Wake)) ']'])
disp('__________________________________')



