%%% Here I test specific hypotheses about a link between theta and
%%% behavior.



ROI = 'preROI';

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Sessions = P.Sessions;
Channels = P.Channels;
StatsP = P.StatsP;
AllTasks = P.AllTasks;
TaskLabels = P.TaskLabels;
Labels = P.Labels;

TitleTag = 'F_TaskTheta_ROI';



%%% Load EEG

Duration = 4;
WelchWindow = 8;

Tag = ['window',num2str(WelchWindow), 's_duration' num2str(Duration),'m'];

ChLabels = fieldnames(Channels.(ROI));
BandLabels = fieldnames(Bands);

Filepath =  fullfile(Paths.Data, 'EEG', 'Unlocked', Tag);
[AllData, Freqs, Chanlocs] = loadAllPower(P, Filepath, AllTasks);

% z-score it

% average channel data into 2 spots
chData = meanChData(Data, Chanlocs, Channels.(ROI), 4);

% average frequencies into bands
bData = bandData(chData, Freqs, Bands, 'last');



%%% Load performance

% SPFT
Answers_Path = fullfile(Source_Tables, 'SpFT_AllAnswers.mat');
load(Answers_Path, 'Answers')
SpFT = Answers;

SpFT_Correct = nan(nParticipants, nSessions); % percent correct
SpFT_Incorrect = SpFT_Correct;

for Indx_P = 1:nParticipants
    for Indx_S = 1:nSessions
            T = SpFT(strcmp(SpFT.Participant, Participants{Indx_P}) & ...
                strcmp(SpFT.Session, Sessions.SpFT{Indx_S}), :);
            C = nanmean(T.Correct);
            IC =  nanmean(T.Incorrect);
            
            SpFT_Correct(Indx_P, Indx_S) = C/10;
            SpFT_Incorrect(Indx_P, Indx_S) = IC/10;
    end
end

% LAT
LAT = loadLATmeta(P, Sessions.LAT, false);
TotT = size(LAT.RT, 3);

LAT_RT = nanmean(LAT.RT, 3);
LAT_Correct = 100*(nansum(squeeze(LAT.Tally) == 3, 3)/TotT);
LAT_Lapses = 100*(nansum(squeeze(LAT.Tally) == 1, 3)/TotT);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%% Change in theta vs change in # mistakes in Speech task
% prediction: theta will increase more in cases where speech did not
% improve much













%%% Change in theta vs change in RT in LAT
% prediction: theta will increase more in participants who got a lot worse


