% this script plots the average topographies for BL, SD1 and SD2 z-scored.

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
zData = ZscoreData(AllData, 'last');


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
        Band = Bands.(BandLabels{Indx_B});
        Band = dsearchn(Freqs', Band');
        
        for Indx_S = 1:numel(Sessions.Labels)
            
            % get data
            Data = zData(:, Indx_S, Indx_T, :, Band(1):Band(2));
            Data = squeeze(nansum(Data, 5).*FreqRes); % integral of band
            Data = nanmean(Data, 1);
            
            % plot topoplot
            subplot(numel(BandLabels), numel(Sessions.Labels), Indx)
            topoplot(Data, Chanlocs, 'style', 'map', 'headrad', 'rim', ...
                'maplimits', CLims(Indx_B, :), 'gridscale', Format.TopoRes);
            title([Sessions.Labels{Indx_S}, ' ', BandLabels{Indx_B}, ' ', TaskLabels{Indx_T}])
            colorbar
            set(gca, 'FontName', Format.FontName, 'FontSize', 20)
            Indx = Indx+1;
        end
    end
    colormap(Format.Colormap.Divergent)
    
    % save
    Fig_Title = strjoin({TitleTag,  'All', 'Bands', AllTasks{Indx_T}}, '_');
    saveas(gcf,fullfile(Results, [Fig_Title, '.svg']))
    saveas(gcf,fullfile(Results, [Fig_Title, '.png']))
    
end



%% plot topographies by band

    for Indx_B = 1:numel(BandLabels)
    figure('units','normalized','outerposition',[0 0 .3 1])
    Indx = 1;

        Band = Bands.(BandLabels{Indx_B});
        Band = dsearchn(Freqs', Band');
        
        for Indx_T = 1:numel(AllTasks)
            
        for Indx_S = 1:numel(Sessions.Labels)
            
            % get data
            Data = zData(:, Indx_S, Indx_T, :, Band(1):Band(2));
            Data = squeeze(nansum(Data, 5).*FreqRes); % integral of band
            Data = nanmean(Data, 1);
            
            % plot topoplot
            subplot(numel(AllTasks), numel(Sessions.Labels), Indx)
            topoplot(Data, Chanlocs, 'style', 'map', 'headrad', 'rim', ...
                'maplimits', CLims(Indx_B, :), 'gridscale', Format.TopoRes);
            title([Sessions.Labels{Indx_S}, ' ', BandLabels{Indx_B}, ' ', TaskLabels{Indx_T}])
            colorbar
            set(gca, 'FontName', Format.FontName)
            Indx = Indx+1;
        end
    end
    colormap(Format.Colormap.Divergent)
    
    % save
    Fig_Title = strjoin({TitleTag, 'All', 'Tasks', BandLabels{Indx_B}}, '_');
    saveas(gcf,fullfile(Results, [Fig_Title, '.svg']))
    saveas(gcf,fullfile(Results, [Fig_Title, '.png']))
    
end
