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
Pixels = P.Pixels;

TitleTag = strjoin({'Task', 'Questionnaires'}, '_');



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

Main_Results = fullfile(Paths.Results, 'Task_Questionnaires');
if ~exist(Main_Results, 'dir')
    for Indx_Q = 1:numel(Questions)
        mkdir(fullfile(Main_Results, Questions{Indx_Q}))
    end
end


%%
% set to nan all answers for a questionnaire when more than 4 participants are missing data
for Indx_T = 1:numel(AllTasks)
   for Indx_Q = 1:numel(Questions)
       NanP = nnz(any(isnan(Answers.(Questions{Indx_Q})(:, :, Indx_T)), 2))
       
       if NanP > 4
           Answers.(Questions{Indx_Q})(:, :, Indx_T) = nan;
       end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paper Figure
%%

YLim = [-.05 1.05];
Questions_Order = {'KSS', 'Relaxing', 'Interesting'; ...
    'Focused',  'Difficult', 'Effortful';  ...
    'Performance',   'Motivation',  'Slept',};
Titles = {'Subjective Sleepiness', 'Relaxing', 'Engaging'; ...
    'Focus', 'Subjective Difficulty', 'Effort'; ...
    'Subjective Performance', 'Motivation', 'Slept',};

Labels.KSS(7:9) = {'Sleepy, but no effort to keep awake', 'Sleepy, some effort to keep awake', 'Fighting sleep'}; % Fix

Grid = [3, 6];

figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.5])

AxesIndexes = [2, 4, 6];
Indx = 1;
Indx_BL = 1;

for Indx_G1 = 1:Grid(1)
    for Indx_G2 = 1:3
        
        Q = Questions_Order{Indx_G1, Indx_G2};
        Data = Answers.(Q);
        L = Labels.(Q);
       
        
        Axis = subfigure([], Grid, [Indx_G1 AxesIndexes(Indx_G2)], [], {}, Pixels);
        shiftaxis(Axis, [], -Pixels.PaddingLabels/2)
        
        if strcmp(Q, 'Slept')
            plotSpaghettiOs(Answers.Motivation, Indx_BL, [], TaskLabels, ...
            Format.Colors.AllTasks, StatsP, Pixels);
        ylim([-10 -9])
        axis off
            continue
        end
        
        ylim(YLim)
        yticks(linspace(0, 1, numel(L)))
        yticklabels(L)
        
        Stats = plotSpaghettiOs(Data, Indx_BL, Sessions.Labels, TaskLabels, ...
            Format.Colors.AllTasks, StatsP, Pixels);
        
        legend off
        
        title([Pixels.Letters{Indx}, ': ' Titles{Indx_G1, Indx_G2}], 'FontSize', Pixels.TitleSize)
        Indx = Indx+1;
        
        
    end
end

saveFig(strjoin({TitleTag, 'Questionnaires'}, '_'), Paths.Paper, Format)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% ANOVA
Effects = -3:.5:3;

for Indx_Q = 1:numel(Questions)-1
    Data = Answers.(Questions{Indx_Q});
    Results = fullfile(Main_Results, Questions{Indx_Q});
    
    % 2 way repeated measures anova with factors Session and Task
    Stats = anova2way(Data, FactorLabels, Sessions.Labels, TaskLabels, StatsP);
    TitleStats = strjoin({'Stats', TitleTag,  Questions{Indx_Q} }, '_');
    saveStats(Stats, 'rmANOVA', Results, TitleStats, StatsP)
    
    % eta2 comparison for task and session to determine which has larger impact
    Title = strjoin({Questions{Indx_Q}, '2 way RANOVA Effect Sizes'}, ' ');
    
    figure('units','normalized','outerposition',[0 0 .3 .4])
    plotANOVA2way(Stats, FactorLabels, StatsP, Format)
    title(Title, 'FontSize', Format.TitleSize)
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
        title(strjoin({Questions{Indx_Q}, 'Hedges g'}, ' '), 'FontSize', Format.TitleSize)
        xlabel('Hedges g')
        
        saveFig(strjoin({TitleTag, 'hedgesg', Questions{Indx_Q} }, '_'), Results, Format)
    end
end



%% plot z data for BL tasks (sorted) next to z data for SD2-BL changes

YLim = [0 1];

for Indx_Q = 1:numel(Questions)-1
    Results = fullfile(Main_Results, Questions{Indx_Q});
    figure('units','normalized','outerposition',[0 0 1 .5])
    tiledlayout(1, 3, 'Padding', 'none', 'TileSpacing', 'compact');
    for Indx_S = 1:numel(Sessions.Labels)
        Data = squeeze(Answers.(Questions{Indx_Q})(:, Indx_S, :));
        
        %         subplot(1, numel(Sessions.Labels), Indx_S)
        nexttile
        L = Labels.(Questions{Indx_Q});
        ylim(YLim)
        yticks(linspace(0, 1, numel(L)))
        yticklabels(L)
        Stats = plotScatterBox(Data, TaskLabels, StatsP, ...
            Format.Colors.AllTasks, YLim, Format);
        title(strjoin({Sessions.Labels{Indx_S}, Questions{Indx_Q}}, ' '), 'FontSize', Format.TitleSize)
        
    end
    
    saveFig(strjoin({TitleTag, 'scatter', ...
        Questions{Indx_Q}}, '_'), Results, Format)
end



%% plot task averages across sessions showcasing changes with SD

Indx_BL = 1;
YLim = [0 1];

for Indx_Q = 1:numel(Questions)-1
    Results = fullfile(Main_Results, Questions{Indx_Q});
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
    title(Questions{Indx_Q}, 'FontSize', Format.TitleSize)
    legend off
    
    saveFig(strjoin({TitleTag, 'SD', 'Means', Questions{Indx_Q}}, '_'), Results, Format)
    
end



