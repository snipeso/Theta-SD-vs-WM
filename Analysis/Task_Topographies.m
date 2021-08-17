% this script plots the average topographies for BL, SD1 and SD2 z-scored
% for all the tasks. No statistics.

clear
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
Channels = P.Channels;
StatsP = P.StatsP;

WelchWindow = 8;
TitleTag = strjoin({'Task', 'Topos', 'Welch', num2str(WelchWindow), 'zScored'}, '_');

Results = fullfile(Paths.Results, 'Task_Topographies');
if ~exist(Results, 'dir')
    mkdir(Results)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

Filepath =  fullfile(P.Paths.Data, 'EEG', ['Unlocked_' num2str(WelchWindow)]);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);

% z-score it
zData = zScoreData(AllData, 'last');

% save it into bands
bData = bandData(zData, Freqs, Bands, 'last');
bAllData = bandData(AllData, Freqs, Bands, 'last');

BandLabels = fieldnames(Bands);
CLabel = 'A.U.';
FreqRes = Freqs(2)-Freqs(1);



%% plot topographies by task

for Indx_T = 1:numel(AllTasks)
    figure('units','normalized','outerposition',[0 0 .5 1])
    Indx = 1;
    
    MEAN =  nanmean(bData(:, :, Indx_T, :, :), 1);
    Max = max(abs(MEAN(:)));
    CLims = [-Max Max];
    
    for Indx_B = 1:numel(BandLabels)
        for Indx_S = 1:numel(Sessions.Labels)
            
            % get data
            Data = nanmean(squeeze(bData(:, Indx_S, Indx_T, :, Indx_B)), 1);
            
            % plot topoplot
            subplot(numel(BandLabels), numel(Sessions.Labels), Indx)
            plotTopo(Data, Chanlocs, CLims, CLabel, 'Divergent', Format)
            title([Sessions.Labels{Indx_S}, ' ', BandLabels{Indx_B}, ' ', TaskLabels{Indx_T}],  'FontSize', 20)
            
            Indx = Indx+1;
        end
    end
    
    % save
    saveFig(strjoin({TitleTag,  'All', 'Sessions', AllTasks{Indx_T}}, '_'), Results, Format)
end



%% plot topographies by band

for Indx_S = 1:numel(Sessions.Labels)
    
    figure('units','normalized','outerposition',[0 0 1 1])
    Indx = 1;
    
      MEAN =  nanmean(bData(:, Indx_S, :, :, :), 1);
    Max = max(abs(MEAN(:)));
    CLims = [-Max Max];
    
    
    for Indx_B = 1:numel(BandLabels)
        for Indx_T = 1:numel(AllTasks)
            % get data
            Data = nanmean(squeeze(bData(:, Indx_S, Indx_T, :, Indx_B)), 1);
            
            % plot topoplot
            subplot(numel(BandLabels), numel(AllTasks), Indx)
            plotTopo(Data, Chanlocs, CLims, CLabel, 'Divergent', Format)
            title(strjoin({TaskLabels{Indx_T}, BandLabels{Indx_B}, Sessions.Labels{Indx_S}}, ' '), 'FontSize', 14)
            
            Indx = Indx+1;
        end
    end
    
    % save
    saveFig(strjoin({TitleTag, 'All', 'Bands',  Sessions.Labels{Indx_S}}, '_'), Results, Format)
end



%% plot representative topoplots with bubbles

Type = {'2D', '3D'};
Size = [120 150];
Labels = [true false];


for Indx_B = 1:numel(BandLabels)
    % game theta SD1
    figure('units','normalized','outerposition',[0 0 .5 .4], 'Color', 'w')
    Data = nanmean(squeeze(bData(:, 2, 5, :, Indx_B)), 1);
    Max = max(abs(Data));
    for Indx = 1:2
        subplot(1, 2, Indx)
        bubbleTopo(Data, Chanlocs, Size(Indx), Type{Indx}, Labels(Indx), Format)
        caxis([-Max Max])
        title(['SD ', BandLabels{Indx_B}, ' Game'])
        colormap(Format.Colormap.Divergent)
        h = colorbar;
        ylabel(h, 'z-score', 'FontName', Format.FontName, 'FontSize', 14)
        
        set(gca, 'FontSize', 14)
    end
    
    % save
    saveFig(strjoin({TitleTag, 'exampleBubble', 'Game' , BandLabels{Indx_B}, 'SD1'}, '_'), Results, Format)
    
    
    % lat theta SD2
    figure('units','normalized','outerposition',[0 0 .5 .4], 'Color', 'w')
    Data = nanmean(squeeze(bData(:, 3, 2, :, Indx_B)), 1);
    Max = max(abs(Data));
    for Indx = 1:2
        subplot(1, 2, Indx)
        bubbleTopo(Data, Chanlocs, Size(Indx), Type{Indx}, Labels(Indx), Format)
        caxis([-Max Max])
        title(['SD ', BandLabels{Indx_B}, ' LAT'])
        colormap(Format.Colormap.Divergent)
        h = colorbar;
        ylabel(h, 'z-score', 'FontName', Format.FontName, 'FontSize', 14)
        
        set(gca, 'FontSize', 14)
    end
    
    % save
    saveFig(strjoin({TitleTag, 'exampleBubble', 'LAT', BandLabels{Indx_B}, 'SD2'}, '_'), Results, Format)
end


%% identify theta peak location in hotspot

Peaks = nan(numel(Participants), numel(Sessions.Labels), numel(AllTasks));
Hotspot = labels2indexes(Channels.preROI.Frontspot, Chanlocs);

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions.Labels)
        for Indx_T = 1:numel(AllTasks)
            Data = squeeze(bData(Indx_P, Indx_S, Indx_T, Hotspot, 2));
            [~, I] = max(Data);
            Peaks(Indx_P, Indx_S, Indx_T) = Channels.preROI.Frontspot(I);
        end
    end
end

%%

% plot peak topographies
figure('units','normalized','outerposition',[0 0 1 .6])
Indx = 1;
for Indx_S = 1:numel(Sessions.Labels)
    for Indx_T = 1:numel(AllTasks)
        subplot(numel(Sessions.Labels), numel(AllTasks), Indx)
        Table = tabulate(Peaks(:, Indx_S, Indx_T));
        Data = zeros(numel(Chanlocs), 1);
        Data(1:size(Table, 1)) = Table(:, 2);
        bubbleTopo(Data(Hotspot), Chanlocs(Hotspot), 200, '2D', true, Format)
        colorbar
        colormap(reduxColormap(flip(Format.Colormap.Linear), 17))
        caxis([-1 16])
        title([TaskLabels{Indx_T}, ' ', Sessions.Labels{Indx_S}], 'FontSize', 14)
        Indx = Indx+1;
    end
end
setLims(numel(Sessions.Labels), numel(AllTasks), 'c');

% save
saveFig(strjoin({TitleTag, 'PeakLoc'}, '_'), Results, Format)



%% Topography correlations

Combo = numel(Sessions.Labels)*numel(AllTasks); % comination of all sessions and tasks

%%% gather correlations for each band
for Indx_B = 1:numel(BandLabels)
    R = nan(numel(Participants), Combo, Combo);
    SessionLabels = cell([2, Combo]);
    
    for Indx_P = 1:numel(Participants)
        AllTopos = nan(numel(Chanlocs), Combo);
        Indx = 1;
        for Indx_S = 1:numel(Sessions.Labels)
            for Indx_T = 1:numel(AllTasks)
                AllTopos(:, Indx) = squeeze(bData(Indx_P, Indx_S, Indx_T, :, Indx_B));
                
                SessionLabels(1, Indx) = Sessions.Labels(Indx_S);
                SessionLabels(2, Indx) = TaskLabels(Indx_T);
                Indx = Indx+1;
            end
        end
        R(Indx_P, :, :) = corrcoef(AllTopos);
    end
    
    % plot matrix of averages of correlations
    figure
    Data = squeeze(nanmean(R, 1));
    PlotCorrMatrix_AllSessions(Data, SessionLabels(2, :), Sessions.Labels, numel(AllTasks), Format)
    title(strjoin({'Corr', BandLabels{Indx_B}, 'Raw Topographies'}, ' '))
    saveFig(strjoin({TitleTag, 'TopoCorr', BandLabels{Indx_B}}, '_'), Results, Format)
    
    
    %%% plot averages for tasks & sessions
    
    % gather data
    DataS = nan(numel(Participants), numel(Sessions.Labels));
    DataT = nan(numel(Participants), numel(AllTasks));
    for Indx_P = 1:numel(Participants)
        
        % sessions
        for Indx_S = 1:numel(Sessions.Labels)
            Indexes = strcmp(SessionLabels(1, :), Sessions.Labels{Indx_S});
            R_temp  = squeeze(R(Indx_P, Indexes, Indexes));
            R_temp(logical(tril(ones(size(R_temp))))) = nan; % set to nan the diagonal and below, since it repeats
            DataS(Indx_P, Indx_S) = nanmean(R_temp(:));
        end
        
        % tasks
        for Indx_T = 1:numel(AllTasks)
            Indexes = strcmp(SessionLabels(2, :), TaskLabels{Indx_T});
            R_temp  = squeeze(R(Indx_P, Indexes, Indexes));
            R_temp(logical(tril(ones(size(R_temp))))) = nan; % set to nan the diagonal and below, since it repeats
            DataT(Indx_P, Indx_T) = nanmean(R_temp(:));
        end
    end
    
    
    figure('units','normalized','outerposition',[0 0 1 .6])
    
    % plot average corr for each session
    subplot(1, 3, 1)
    plotBars(DataS, Sessions.Labels, [0 0 0; .4 .4 .4; .8 .8 .8], Format, 'vertical', StatsP);
    title(strjoin({'Average' 'Corr', BandLabels{Indx_B}, ' Across' 'Sessions'}, ' '))
    
    % plot average corr for each task
    subplot(1, 3, 2)
    plotBars(DataT, TaskLabels, Format.Colors.AllTasks, Format, 'vertical',StatsP);
    title(strjoin({'Average' 'Corr', BandLabels{Indx_B}, ' Across' 'Tasks'}, ' '))
    
    % plot average corr for sessions vs tasks
    Data = [nanmean(DataS, 2),  nanmean(DataT, 2)];
    subplot(1, 3, 3)
    plotBars(Data, {'Sessions', 'Tasks'}, [.5 .5 .5; Format.Colors.Dark1], Format, 'vertical', StatsP);
    title(strjoin({'Average' 'Corr', BandLabels{Indx_B}, ' Across' 'Tasks'}, ' '))
    
    
    setLims(1, 3, 'y');
    
    saveFig(strjoin({TitleTag, 'TopoCorrAverages', BandLabels{Indx_B}}, '_'), Results, Format)
end


%%
%%% For reference, correlation across bands for different sessions
figure('units','normalized','outerposition',[0 0 1 .6])
Indx = 1;
for Indx_S = 1:numel(Sessions.Labels)
    for Indx_T = 1:numel(AllTasks)
        R = nan(numel(Participants), numel(BandLabels), numel(BandLabels));
        for Indx_P = 1:numel(Participants)
            Data = squeeze(bData(Indx_P, Indx_S, Indx_T, :, :));
            R(Indx_P, :, :) = corrcoef(Data);
        end
        
        Data = squeeze(nanmean(R, 1));
        subplot(numel(Sessions.Labels), numel(AllTasks), Indx)
        PlotCorrMatrix_AllSessions(Data, BandLabels, [], [], Format)
        title(strjoin({Sessions.Labels{Indx_S}, TaskLabels{Indx_T}}, ' '))
        Indx = Indx+1;
    end
end
setLims(numel(Sessions.Labels), numel(AllTasks), 'c');
colormap(Format.Colormap.Monochrome)

saveFig(strjoin({TitleTag, 'TopoCorr', 'AllBands'}, '_'), Results, Format)



%% Plot Fix, Game, LAT at BL, SD1, and SD2 for everyone


Tasks = {'Fixation', 'Game', 'LAT'};
Tasks = find(ismember(AllTasks, Tasks));

for Indx_P = 1:numel(Participants)
    Band = 2;
    Data = squeeze(bAllData(Indx_P, :, :, :, Band));
    CLimsQ = quantile(Data(:), [ .01 1]);
    
    figure('units','normalized','outerposition',[0 0 .41 .625])
    Indx = 1;
    for Indx_S = 1:numel(Sessions.Labels)
        for Indx_T = Tasks
            
            Data = squeeze(bAllData(Indx_P, Indx_S, Indx_T, :, Band));
            
            subplot(numel(Sessions.Labels), numel(Tasks), Indx)
            plotTopo(Data, Chanlocs, CLimsQ, CLabel, 'Linear', Format)
            title(strjoin({Participants{Indx_P}, TaskLabels{Indx_T}, Sessions.Labels{Indx_S}}, ' '))
            set(gca, 'FontSize', 16)
            Indx = Indx+1;
        end
    end
    
    saveFig(strjoin({TitleTag, 'Example', 'Theta', Participants{Indx_P} }, '_'), Results, Format)
end


