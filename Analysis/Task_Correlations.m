% script just to vaguely see if there's a relationship between subjective
% ratings and sdTheta

clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters


ROI = 'preROI';

P = analysisParameters();

Paths = P.Paths;
Participants = P.Participants;
Format = P.Format;
Bands = P.Bands;
Sessions = P.Sessions;
Channels = P.Channels;
StatsP = P.StatsP;
Pixels = P.Pixels;
AllTasks = P.AllTasks;

ChLabels = fieldnames(Channels.(ROI));
BandLabels = fieldnames(Bands);

Duration = 4;
WelchWindow = 8;

TitleTag = strjoin({'Task', 'Questionnaires'}, '_');
Tag = ['window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup data

% load questionnaire data
Filepath = fullfile(P.Paths.Data, 'Questionnaires');
[Answers, Labels] = loadAllBAT(Filepath, Participants, Sessions, AllTasks);

Questions = fieldnames(Answers);

Main_Results = fullfile(Paths.Results, 'Task_Questionnaires_Power');
if ~exist(Main_Results, 'dir')
    for Indx_Q = 1:numel(Questions)
        for Indx_B = 1:numel(BandLabels)
        mkdir(fullfile(Main_Results, Tag, BandLabels{Indx_B}, Questions{Indx_Q}))
        end
    end
end


% load EEG data

Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);

% z-score it
zData = zScoreData(AllData, 'last');

% average channel data into 2 spots
chData = meanChData(zData, Chanlocs, Channels.(ROI), 4);

% average frequencies into bands
bData = bandData(chData, Freqs, Bands, 'last');

chRawData = meanChData(AllData, Chanlocs, Channels.(ROI), 4);
bRawData = bandData(chRawData, Freqs, Bands, 'last');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot & analyze data

%% correlate sdTheta with answers raw power

for Indx_Q = 1:numel(Questions)-1
    Results = fullfile(Main_Results, Tag,  BandLabels{Indx_B}, Questions{Indx_Q});
    for Indx_B = 2%1:numel(BandLabels)
        for Indx_S = [1 3] % for answers, not for sdTheta
            for Indx_Ch = 1:numel(ChLabels)
                BL = squeeze(bRawData(:, 1, :, Indx_Ch, Indx_B));
                SD = squeeze(bRawData(:, 3, :, Indx_Ch, Indx_B));
                Data2 = (SD - BL)./BL; % sdBand
                Data1 = squeeze(Answers.(Questions{Indx_Q})(:, Indx_S, :));
                
                AxisLabels = {[Questions{Indx_Q}, ' ', Sessions.Labels{Indx_S}], ['\delta', BandLabels{Indx_B}]};
                
                figure('units','normalized','position',[0 0 .25 .45])
                Stats = plotSticksAndStones(Data1, Data2, AxisLabels, {}, Format.Colors.AllTasks, Format);
                xlim([0 1])
                title(strjoin({ Questions{Indx_Q}, BandLabels{Indx_B}, ChLabels{Indx_Ch}}, ' '))
                saveFig(strjoin({TitleTag, 'Raw', 'sdTheta', 'vs', 'Q', ...
                    Questions{Indx_Q}, BandLabels{Indx_B}, ChLabels{Indx_Ch}, Sessions.Labels{Indx_S}}, '_'), Results, Format)
            end
        end
    end
%     close all
end



%% correlate sdTheta with answers z-score power

for Indx_Q = 1:numel(Questions)-1
    Results = fullfile(Main_Results, Tag,  BandLabels{Indx_B}, Questions{Indx_Q});
    for Indx_B =  2%1:numel(BandLabels)
        for Indx_S = [1 3] % for answers, not for sdTheta
            for Indx_Ch = 1:numel(ChLabels)
                Data2 = squeeze(bData(:, 3, :, Indx_Ch, Indx_B)) - squeeze(bData(:, 1, :, Indx_Ch, Indx_B)); % sdBand
                Data1 = squeeze(Answers.(Questions{Indx_Q})(:, Indx_S, :));
                
                AxisLabels = {[Questions{Indx_Q}, ' ', Sessions.Labels{Indx_S}], ['\delta', BandLabels{Indx_B}]};
                
                figure('units','normalized','position',[0 0 .25 .45])
                Stats = plotSticksAndStones(Data1, Data2, AxisLabels, {}, Format.Colors.AllTasks, Format);
                xlim([0 1])
                title(strjoin({ Questions{Indx_Q}, BandLabels{Indx_B}, ChLabels{Indx_Ch}}, ' '))
                saveFig(strjoin({TitleTag, 'zscore', 'sdTheta', 'vs', 'Q', ...
                    Questions{Indx_Q}, BandLabels{Indx_B}, ChLabels{Indx_Ch}, Sessions.Labels{Indx_S}}, '_'), Results, Format)
            end
        end
    end
%     close all
end


%% correlate changes raw

for Indx_Q = 1:numel(Questions)-1
    Results = fullfile(Main_Results, Tag,  BandLabels{Indx_B}, Questions{Indx_Q});
    for Indx_B = 2%1:numel(BandLabels)
            for Indx_Ch = 1:numel(ChLabels)
                BL = squeeze(bRawData(:, 1, :, Indx_Ch, Indx_B));
                SD = squeeze(bRawData(:, 3, :, Indx_Ch, Indx_B));
                Data2 = (SD - BL)./BL; % sdBand
                BL =  squeeze(Answers.(Questions{Indx_Q})(:, 1, :));
                SD =  squeeze(Answers.(Questions{Indx_Q})(:, 3, :));
                Data1 = (SD-BL)./BL;
                
                AxisLabels = {['\delta', Questions{Indx_Q}], ['\delta', BandLabels{Indx_B}]};
                
                figure('units','normalized','position',[0 0 .25 .45])
                Stats = plotSticksAndStones(Data1, Data2, AxisLabels, {}, Format.Colors.AllTasks, Format);
                title(strjoin({ Questions{Indx_Q}, BandLabels{Indx_B}, ChLabels{Indx_Ch}}, ' '))
                saveFig(strjoin({TitleTag,  'Change', 'Raw', 'sdTheta', 'vs', 'Q', ...
                    Questions{Indx_Q}, BandLabels{Indx_B}, ChLabels{Indx_Ch}, Sessions.Labels{Indx_S}}, '_'), Results, Format)
            end
    end
%     close all
end



