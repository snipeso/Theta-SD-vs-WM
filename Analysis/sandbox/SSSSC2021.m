
close all
clear
clc

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Bands = P.Bands;
Format = P.Format;
Sessions = P.Sessions;
Channels = P.Channels;

WelchWindow = 5;
TitleTag = strjoin({'SSSSC', 'Abstract', num2str(WelchWindow)}, '_');

Results = fullfile(Paths.Results, 'SSSSC');
if ~exist(Results, 'dir')
    mkdir(Results)
end

Load_All_Power

% z-score it
zData = ZscoreData(AllData, 'last');

%%
% plot Fix vs BL tasks and SD2 tasks topoplots and hotspot effect sizes
CLims = [-10 10];
Theta = dsearchn(Freqs', Bands.Theta');
Fix = squeeze(nanmean(zData(:, 1, end, :, Theta(1):Theta(2)), 5));
ES_Ch = 11;
ES_Ch = labels2indexes(ES_Ch, Chanlocs);
for Indx_S = 1 %:numel(Sessions.LAT)
    for Indx_T = 1:numel(AllTasks)
        figure('units','normalized','outerposition',[0 0 .2 .4])
        
        Topo = squeeze(nanmean(zData(:, Indx_S, Indx_T, :, Theta(1):Theta(2)), 5));
        
        if Indx_S == 1 && Indx_T == numel(AllTasks)
            continue
        end
        [p, Sig] = plotTopoDiff(Fix, Topo, Chanlocs, CLims, Format);
        title([TaskLabels{Indx_T}, ' ', Sessions.Labels{Indx_S}])
        saveas(gcf,fullfile(Results, strjoin({TitleTag, 'FixBL_vs', AllTasks{Indx_T}, [Sessions.Labels{Indx_S}, '.png']}, '_')))
        
        % Fz effect sizes:
        statsHedges = mes(Topo(:, ES_Ch), Fix(:, ES_Ch), 'hedgesg', 'isDep', 1, 'nBoot', 1000);
        
        disp([TaskLabels{Indx_T} ' ' Sessions.Labels{Indx_S}, ...
            ' sig channels: ' num2str(round(100*(nnz(Sig)/numel(Sig)))), ...
            '%; hedges g: ', num2str(statsHedges.hedgesg)
            ])
        
    end
end


%% plot Bl vs SD for each task


for Indx_T = 1:numel(AllTasks)
    
    figure('units','normalized','outerposition',[0 0 .4 .4])
    BL =  squeeze(nanmean(zData(:, 1, Indx_T, :, Theta(1):Theta(2)), 5));
    for Indx_S = 2:numel(Sessions.LAT)
        
        SD = squeeze(nanmean(zData(:, Indx_S, Indx_T, :, Theta(1):Theta(2)), 5));
        
        if Indx_S == 1 && Indx_T == numel(AllTasks)
            continue
        end
        subplot(1, 2, Indx_S-1)
        [p, Sig] = plotTopoDiff(BL, SD, Chanlocs, CLims, Format);
        title([TaskLabels{Indx_T}, ' ', Sessions.Labels{Indx_S}])
        
        % Fz effect sizes:
        statsHedges = mes(SD(:, ES_Ch), BL(:, ES_Ch), 'hedgesg', 'isDep', 1, 'nBoot', 1000);
        
        disp([TaskLabels{Indx_T} ' ' Sessions.Labels{Indx_S}, ...
            ' sig channels: ' num2str(round(100*(nnz(Sig)/numel(Sig)))), ...
            '%; hedges g: ', num2str(statsHedges.hedgesg)
            ])
        
    end
    saveas(gcf,fullfile(Results, strjoin({TitleTag, 'BL_vs', [AllTasks{Indx_T}, '.png']}, '_')))
end


%% Change in peak frequency
% freq: confetti spaghetti of BL theta vs SD2 theta peak freq for each task

Ch = Channels.Sample;
Ch = labels2indexes(Ch, Chanlocs);
ChLabels = Channels.Sample_Titles;
YLims = [4 8];
for Indx_Ch = 1:numel(Ch)
    figure('units','normalized','outerposition',[0 0 1 .5])
    
    for Indx_T = 1:numel(AllTasks)-1
        Theta_Peak = nan(numel(Participants), numel(Sessions.Labels));
        for Indx_P = 1:numel(Participants)
            for Indx_S = 1:numel(Sessions.Labels)
                
                Data = squeeze(zData(Indx_P, Indx_S, Indx_T, Ch(Indx_Ch), :));
                [Peak, Amp] = bandPeak(Data, Freqs, Bands.Theta);
                Theta_Peak(Indx_P, Indx_S) = Peak;
            end
        end
        
        subplot(1, numel(AllTasks)-1, Indx_T)
        PlotConfettiSpaghetti(Theta_Peak, Sessions.Labels, YLims, [], [], Format, true);
        ylabel('Peak Frequency')
        title([TaskLabels{Indx_T}, ' ', ChLabels{Indx_Ch} ])

    end
    saveas(gcf,fullfile(Results, [TitleTag, '_PeakTheta_', ChLabels{Indx_Ch}, '.png']))
    
end


