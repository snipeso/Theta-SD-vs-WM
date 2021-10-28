
clear
clc
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

Task = 'LAT';

P = analysisParameters();

Participants = P.Participants;
Sessions = P.Sessions;
StatsP = P.StatsP;
Tally = {'Lapses', 'Late', 'Correct'};
Format = P.Format;
Paths = P.Paths;

Refresh = false;

TitleTag = strjoin({Task, 'Performance'}, '_');

Results = fullfile(Paths.Results, 'Performance', Task);
if ~exist(Results, 'dir')
    mkdir(Results)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load data

AllData = loadLATmeta(P, Sessions.(Task), Refresh);

TotT = size(AllData.RT, 3);


%% % of hits/misses as seperate confettispaghetti plots + statistics

for Indx_T = 1:numel(Tally)
    
    Data = 100*(nansum(squeeze(AllData.Tally) == Indx_T, 3)/TotT);
    figure('units','normalized','outerposition',[0 0 .15 .4])
    Stats = plotConfettiSpaghetti(Data, Sessions.Labels, [], [], Format.Colors.Participants, StatsP, Format);
    ylabel(['% '  Tally{Indx_T}])
    saveFig(strjoin({TitleTag, 'meanTally', Tally{Indx_T}}, '_'), Results, Format)
end

%% mean reaction times

Data = nanmean(AllData.RT, 3);
figure('units','normalized','outerposition',[0 0 .15 .4])
Stats = plotConfettiSpaghetti(Data, Sessions.Labels, [], [], Format.Colors.Participants, StatsP, Format);
ylabel('mean RT (s)')
saveFig(strjoin({TitleTag, 'meanRT'}, '_'), Results, Format)
