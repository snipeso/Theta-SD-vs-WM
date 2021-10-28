
clear
clc
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

Task = 'PVT';

P = analysisParameters();

P.Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', ...
    'P09', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17'}; % without hte last one because missing BL
Sessions = P.Sessions;
StatsP = P.StatsP;
Tally = {'NaN', 'Lapse', 'Correct'};
Format = P.Format;
Paths = P.Paths;

Format.Colors.Participants = Format.Colors.Participants(1:17, :);

Refresh = false;

TitleTag = strjoin({Task, 'Performance'}, '_');

Results = fullfile(Paths.Results, 'Performance', Task);
if ~exist(Results, 'dir')
    mkdir(Results)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load data

AllData = loadPVTmeta(P, Sessions.(Task), Refresh);

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
