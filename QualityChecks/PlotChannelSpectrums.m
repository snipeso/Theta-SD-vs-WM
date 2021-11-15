% plot for every recording the log-log spectrums of every channel

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


Duration = 4;
WelchWindow = 8;

Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];
TitleTag = strjoin({'ChannelSpectrums', 'LogLog', num2str(WelchWindow), 'zScored'}, '_');

Results = fullfile(Paths.Results, 'Task_Spectrums', Tag);
if ~exist(Results, 'dir')
    mkdir(Results)
end

Format.Labels.Bands = log(Format.Labels.Bands);

%%

for Indx_P = 1:numel(Participants)
    figure('units','normalized','outerposition',[0 0 1 1])
    tiledlayout( numel(Sessions.Labels), numel(AllTasks), 'Padding', 'none', 'TileSpacing', 'compact');
    for Indx_T = 1:numel(AllTasks)
        for Indx_S = 1:numel(Sessions.Labels)
            
            Filename = strjoin({Participants{Indx_P}, AllTasks{Indx_T}, ...
                Sessions.( AllTasks{Indx_T}){Indx_S}, 'Welch.mat'}, '_');
            Path = fullfile(Paths.Data, 'EEG', 'Unlocked', Tag, AllTasks{Indx_T}, ...
                Filename);
            
            % load file
            if ~exist(Path, 'file')
                nexttile
                  title(strjoin({Participants{Indx_P}, TaskLabels{Indx_T}, Sessions.Labels{Indx_S}}, ' ') )
                continue
            end
            load(Path, 'Power', 'Freqs')
            
            % plot
            nexttile
            plotSpectrum(log(Power), log(Freqs), '', [0 0 0], ...
                .1, 1, Format)
            legend off
            axis tight
            ylabel('log(Power)')
            xlabel('log(Frequency)')
            xticklabels([1 4 8 15 25 35 40])
            title(strjoin({Participants{Indx_P}, TaskLabels{Indx_T}, Sessions.Labels{Indx_S}}, ' ') )
        end
    end
    setLimsTiles(numel(Sessions.Labels)*numel(AllTasks), 'y')
    saveFig(strjoin({TitleTag, Participants{Indx_P}}, '_'), Results, Format)
end



