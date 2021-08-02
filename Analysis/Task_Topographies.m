% this script plots the average topographies for BL, SD1 and SD2 z-scored
% for all the tasks. No statistics.

clear
close all
clc

Analysis_Parameters

WelchWindow = 10;
TitleTag = strjoin({'Task', 'Topos', 'Welch', num2str(WelchWindow), 'zScored'}, '_');

Results = fullfile(Paths.Results, 'Task_Topographies');
if ~exist(Results, 'dir')
    mkdir(Results)
end

Load_All_Power % results in variable "AllData"; P x S x T x Ch x F

% z-score it
zData = zScoreData(AllData, 'last');


% save it into bands
bData = bandData(zData, Freqs, Bands, 'last');

%% plot topographies by task
BandLabels = fieldnames(Bands);
FreqRes = Freqs(2)-Freqs(1);
CLims = [ -5 5;
    -12 12;
    -12 12;
    -20 20];

for Indx_T = 1:numel(AllTasks)
    figure('units','normalized','outerposition',[0 0 .5 1])
    Indx = 1;
    for Indx_B = 1:numel(BandLabels)
        for Indx_S = 1:numel(Sessions.Labels)
            
            % get data
            Data = nanmean(squeeze(bData(:, Indx_S, Indx_T, :, Indx_B)), 1);
            
            % plot topoplot
            subplot(numel(BandLabels), numel(Sessions.Labels), Indx)
            topoplot(Data, Chanlocs, 'style', 'map', 'headrad', 'rim', 'whitebk', 'on', ...
                'maplimits', CLims(Indx_B, :), 'gridscale', Format.TopoRes);
            title([Sessions.Labels{Indx_S}, ' ', BandLabels{Indx_B}, ' ', TaskLabels{Indx_T}])
            colorbar
            set(gca, 'FontName', Format.FontName, 'FontSize', 20)
            Indx = Indx+1;
        end
    end
    colormap(Format.Colormap.Divergent)
    
    % save
    saveFig(strjoin({TitleTag,  'All', 'Bands', AllTasks{Indx_T}}, '_'), Results, Format)
end



%% plot topographies by band

for Indx_B = 1:numel(BandLabels)
    figure('units','normalized','outerposition',[0 0 .3 1])
    Indx = 1;
    
    for Indx_T = 1:numel(AllTasks)
        for Indx_S = 1:numel(Sessions.Labels)
            
            % get data
            Data = nanmean(squeeze(bData(:, Indx_S, Indx_T, :, Indx_B)), 1);
            
            % plot topoplot
            subplot(numel(AllTasks), numel(Sessions.Labels), Indx)
            topoplot(Data, Chanlocs, 'style', 'map', 'headrad', 'rim', 'whitebk', 'on', ...
                'maplimits', CLims(Indx_B, :), 'gridscale', Format.TopoRes);
            title([Sessions.Labels{Indx_S}, ' ', BandLabels{Indx_B}, ' ', TaskLabels{Indx_T}])
            colorbar
            set(gca, 'FontName', Format.FontName)
            Indx = Indx+1;
        end
    end
    colormap(Format.Colormap.Divergent)
    
    % save
    saveFig(strjoin({TitleTag, 'All', 'Tasks', BandLabels{Indx_B}}, '_'), Results, Format)
end



%% plot representative topoplot with labels
% SD theta LAT, and SR theta game

% game theta SD1
figure
Data = nanmean(squeeze(bData(:, 2, 5, :, 2)), 1);
gridTopo(Data, Chanlocs, true)
caxis([-15 15])
title('SD Theta Game')
colormap(Format.Colormap.Divergent)

% save
saveFig(strjoin({TitleTag, 'exampleGrid','Theta', 'SD1'}, '_'), Results, Format)


% lat theta SD2
figure
Data = nanmean(squeeze(bData(:, 3, 2, :, 2)), 1);
gridTopo(Data, Chanlocs, true)
caxis([-15 15])
title('SD Theta LAT')
colormap(Format.Colormap.Divergent)

% save
saveFig(strjoin({TitleTag, 'exampleGrid', 'LAT', 'SD2'}, '_'), Results, Format)



%% identify theta peak location in hotspot

Peaks = nan(numel(Participants), numel(Sessions.Labels), numel(AllTasks));
Hotspot = labels2indexes(Channels.Hotspot, Chanlocs);

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Sessions.Labels)
        for Indx_T = 1:numel(AllTasks)
            Data = squeeze(bData(Indx_P, Indx_S, Indx_T, Hotspot, 2));
            [~, I] = max(Data);
            Peaks(Indx_P, Indx_S, Indx_T) = Channels.Hotspot(I);
        end
    end
end


% plot peak topographies
figure('units','normalized','outerposition',[0 0 1 .6])
Indx = 1;
for Indx_S = 1:numel(Sessions.Labels)
    for Indx_T = 1:numel(AllTasks)
        subplot(numel(Sessions.Labels), numel(AllTasks), Indx)
        Table = tabulate(Peaks(:, Indx_S, Indx_T));
        Data = zeros(numel(Chanlocs), 1);
        Data(1:size(Table, 1)) = Table(:, 2);
        gridTopo(Data, Chanlocs, false)
        colormap(Format.Colormap.Linear)
        title([AllTasks{Indx_T}, ' ', Sessions.Labels{Indx_S}], 'FontSize', 14)
        Indx = Indx+1;
    end
end
setLims(numel(Sessions.Labels), numel(AllTasks), 'c')

% save
saveFig(strjoin({TitleTag, 'PeakLoc'}, '_'), Results, Format)



%% Topography correlations

Combo = numel(Sessions.Labels)*numel(AllTasks);
R = nan(numel(Participants), Combo, Combo);

for Indx_P = 1:numel(Participants)
    Indx = 1;
    for Indx_S = 1:numel(Sessions)
        for Indx_T = 1:numel(AllTasks)
            Topo1 = 
            R(Indx_P, Indx, Indx) = corrcoef(Topo1, Topo2); 
            
            Indx = Indx+1;
        end
    end
end

