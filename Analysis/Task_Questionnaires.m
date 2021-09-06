% script for analyzing and plotting questionnaire data from the tasks.

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;

Format = P.Format;
Sessions = P.Sessions;
AllTasks = {'Match2Sample', 'LAT', 'PVT', 'SpFT', 'Game', 'Music'};
TaskLabels = {'STM', 'LAT', 'PVT', 'Speech', 'Game', 'Music'};
StatsP = P.StatsP;

TitleTag = strjoin({'Task', 'Questionnaires'}, '_');

Results = fullfile(Paths.Results, 'Task_Questionnaires');
if ~exist(Results, 'dir')
    mkdir(Results)
end

FactorLabels = {'Session', 'Task'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

% load questionnaire data
Filepath = fullfile(P.Paths.Data, 'Questionnaires');
[Answers, Labels] = loadAllBAT(Filepath, Participants, Sessions, AllTasks);

Format.Colors.AllTasks =  Format.Colors.AllTasks(1:numel(AllTasks), :);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot & analyze data

Questions = fieldnames(Answers);

%% ANOVA
Effects = -3:.5:3;

for Indx_Q = 1:numel(Questions)
    Data = Answers.(Questions{Indx_Q});
    
    % 2 way repeated measures anova with factors Session and Task
    Stats = anova2way(Data, FactorLabels, Sessions.Labels, TaskLabels, StatsP);
    
    % eta2 comparison for task and session to determine which has larger impact
    Title = strjoin({Questions{Indx_Q}, '2 way RANOVA Effect Sizes'}, ' ');
    
    figure('units','normalized','outerposition',[0 0 .2 .3])
    plotANOVA2way(Stats, FactorLabels, StatsP, Format)
    title(Title)
    saveFig(strjoin({TitleTag, 'eta2', Questions{Indx_Q}}, '_'), Results, Format)
    
    % if interaction, identify which task has the largest increase
    P = Stats.ranovatbl.(StatsP.ANOVA.pValue);
    Interaction = P(7);
    if Interaction < StatsP.Alpha
        
        % get hedge's g stats (because <50 participants)
        BL = Data(:, 1, :);
        BL = permute(repmat(BL, 1, 2, 1), [1 3 2]);
        
        SD = permute(Data(:, 2:3, :), [1 3 2]);
        StatsH = hedgesG(BL, SD, StatsP);
        
        figure('units','normalized','outerposition',[0 0 .2 .6])
        
        % plot effect size lines
        hold on
        for E = Effects
            plot( [0, numel(TaskLabels)+1], [E, E], 'Color', [.9 .9 .9], 'HandleVisibility', 'off')
        end
        
        plotUFO(StatsH.hedgesg, StatsH.hedgesgCI, TaskLabels, {'SR-BL', 'SD-BL'}, ...
            Format.Colors.AllTasks, 'vertical', Format)
        title(strjoin({Questions{Indx_Q}, 'Hedges g'}, ' '))
        xlabel('Hedges g')
        
        saveFig(strjoin({TitleTag, 'hedgesg', Questions{Indx_Q} }, '_'), Results, Format)
    end
end



%% plot z data for BL tasks (sorted) next to z data for SD2-BL changes

YLim = [0 1];

for Indx_Q = 1:numel(Questions)
    figure('units','normalized','outerposition',[0 0 1 .5])
    for Indx_S = 1:numel(Sessions.Labels)
        Data = squeeze(Answers.(Questions{Indx_Q})(:, Indx_S, :));
        
        subplot(1, numel(Sessions.Labels), Indx_S)
        L = Labels.(Questions{Indx_Q});
        ylim(YLim)
        yticks(linspace(0, 1, numel(L)))
        yticklabels(L)
        Stats = plotScatterBox(Data, TaskLabels, StatsP, ...
            Format.Colors.AllTasks, YLim, Format);
        title(strjoin({Sessions.Labels{Indx_S}, Questions{Indx_Q}}, ' '))
        
    end
    
    saveFig(strjoin({TitleTag, 'scatter', ...
        Questions{Indx_Q}}, '_'), Results, Format)
end



%% plot task averages across sessions showcasing changes with SD

Indx_BL = 1;
YLim = [0 1];

for Indx_Q = 1:numel(Questions)
    
    Data = Answers.(Questions{Indx_Q});
    
    % plot spaghetti-o plot of tasks x sessions for each ch and each band
    figure('units','normalized','outerposition',[0 0 .4 .45])
    L = Labels.(Questions{Indx_Q});
    ylim(YLim)
    yticks(linspace(0, 1, numel(L)))
    yticklabels(L)
    Stats = plotSpaghettiOs(Data, Indx_BL, Sessions.Labels, TaskLabels, ...
        Format.Colors.AllTasks, StatsP, Format);
    axis square
    title(Questions{Indx_Q})
    legend off
    
    saveFig(strjoin({TitleTag, 'SD', 'Means', Questions{Indx_Q}}, '_'), Results, Format)
    
end



