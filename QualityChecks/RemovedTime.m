% looks at how much of the task recording was removed with TMPREJ



clear
clc
close all

P = qcParameters();

Paths = P.Paths;
Participants = P.Participants;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
Channels = P.Channels;
StatsP = P.StatsP;


EEG_Triggers.Start = 'S  1';
EEG_Triggers.End = 'S  2';

TitleTag = strjoin({'RemovedTime'}, '_');


Results = fullfile(Paths.Results, 'RemovedTime');
if ~exist(Results, 'dir')
    mkdir(Results)
end

AllT = nan(numel(Participants), numel(Sessions.Labels), numel(AllTasks));

% gather info

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions.Labels)
        for Indx_T = 1:numel(AllTasks)
            Task = AllTasks{Indx_T};
            Filename_Core = strjoin({Participants{Indx_P}, Task, ...
                Sessions.( AllTasks{Indx_T}){Indx_S}}, '_');
            Filename_Cuts = [Filename_Core, '_Cuts.mat'];
            Filename = [Filename_Core, '_Clean.set'];
            
            Path_Cuts = fullfile(Paths.Preprocessed, 'Cutting', 'New_Cuts', Task, Filename_Cuts);
            Path_EEG = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task);
            
            if ~exist(Path_Cuts, 'file')
                continue
            end
            
            if ~exist(fullfile(Path_EEG, Filename), 'file')
                continue
            end
            
            EEG = pop_loadset('filename', Filename, 'filepath', Path_EEG);
            
            
            % remove beginning
            if any(strcmpi({EEG.event.type}, EEG_Triggers.Start))
                StartPoint = EEG.event(strcmpi({EEG.event.type}, EEG_Triggers.Start)).latency;
                EEG.data(:, 1:round(StartPoint)) = nan; %this gets removed in rmNoise, which removes anything that's a nan
            else
                warning('not removing beginning data...')
            end
            
            % remove ending
            if any(strcmpi({EEG.event.type},  EEG_Triggers.End))
                EndPoint =  EEG.event(strcmpi({EEG.event.type},  EEG_Triggers.End)).latency;
                EEG.data(:, round(EndPoint):end) = nan; %this gets removed in rmNoise, which removes anything that's a nan
            else
                warning('not removing end data...')
            end
            
            FullTime = nnz(~isnan(EEG.data(1, :)))/EEG.srate;
            
            EEG = rmNoise(EEG,  Path_Cuts);
            
            % remove all data changed to NaN (beginnings and ends
            EEG = rmNaN(EEG);
            
            RemainingTime = nnz(~isnan(EEG.data(1, :)))/EEG.srate;
            
            AllT(Indx_P, Indx_S, Indx_T, 1) = RemainingTime/60;
            AllT(Indx_P, Indx_S, Indx_T, 2) = FullTime/60;
        end
    end
end


%% Total time by task
Data = squeeze(nanmean(AllT(:, :, :, 2),2));

figure('units','normalized','outerposition',[0 0 .9 .3])
tiledlayout(1, 3, 'Padding', 'none', 'TileSpacing', 'compact');
nexttile
plotBars(Data, TaskLabels, Format.Colors.AllTasks, Format, 'vertical')
title('Total Recording Times by Task', 'FontSize', Format.TitleSize)

Data = squeeze(nanmean(AllT(:, :, :, 1),2));
nexttile
plotBars(Data, TaskLabels, Format.Colors.AllTasks, Format, 'vertical')
title('Clean Recording Times by Task', 'FontSize', Format.TitleSize)


setLimsTiles(2, 'y')


Data = 100*(squeeze(nanmean(AllT(:, :, :, 1),2))./ squeeze(nanmean(AllT(:, :, :, 2),2)));
nexttile
ylim([50 100])

plotBars(Data, TaskLabels, Format.Colors.AllTasks, Format, 'vertical', StatsP)
title('Clean Recording Times by Task', 'FontSize', Format.TitleSize)
saveFig(strjoin({TitleTag, 'Task'}, '_'), Results, Format)

%% plot removed data by task and session

Data = 100*(squeeze(AllT(:, :, :, 1))./ squeeze(AllT(:, :, :, 2)));

figure('units','normalized','outerposition',[0 0 .2 .6])
plotSpaghettiOs(Data, 1, Sessions.Labels, TaskLabels, Format.Colors.AllTasks, StatsP, Format);
ylim([80 100])
ylabel('% data kept')

saveFig(strjoin({TitleTag, 'TaskxSession'}, '_'), Results, Format);

