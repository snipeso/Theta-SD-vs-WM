% all task performance things together just for the sake of the paper
% figure.


P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Format = P.Format;
Pixels = P.Pixels;

nParticipants = numel(Participants);
nSessions = numel(Sessions.Labels);


Source_Tables = fullfile(Paths.Data, 'Behavior');


%% Load data

%%% M2S

Answers_Path = fullfile(Source_Tables, 'Match2Sample_AllAnswers.mat');
load(Answers_Path, 'Answers')
M2S = Answers;


Levels = unique(M2S.level);
nLevels = numel(Levels);

% load data
M2S_Correct = nan(nParticipants, nSessions, nLevels); % percent correct
for Indx_P = 1:nParticipants
    for Indx_S = 1:nSessions
        for Indx_L = 1:nLevels
            T = M2S(strcmp(M2S.Participant, Participants{Indx_P}) & ...
                strcmp(M2S.Session, Sessions.Match2Sample{Indx_S}) & ...
                M2S.level == Levels(Indx_L), :);
            Tot = size(T, 1);
            C = nnz(T.correct==1);
            
            M2S_Correct(Indx_P, Indx_S, Indx_L) = 100*C/Tot;
        end
    end
end


%%% LAT

LAT = loadLATmeta(P, Sessions.LAT, false);
TotT = size(LAT.RT, 3);

LAT_RT = nanmean(LAT.RT, 3);
LAT_Correct = 100*(nansum(squeeze(LAT.Tally) == 3, 3)/TotT);
LAT_Lapses = 100*(nansum(squeeze(LAT.Tally) == 1, 3)/TotT);


%%% PVT

PVT = loadPVTmeta(P, Sessions.PVT, false);
TotT = size(PVT.RT, 3);

PVT_RT = nanmean(PVT.RT, 3);
PVT_Lapses = nansum(squeeze(PVT.Tally) == 2, 3);



%%
%%% SpFT
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


%% plot data

Pixels.PaddingExterior = 30; % reduce because of subplots
Grid = [2, 2];
Indx_B = 2; % theta
Indx = 1;
YLims = [-.3 1];

figure('units','centimeters','position',[0 0 Pixels.W Pixels.H*.4])


%%% M2S
miniGrid = [1 3];

Space = subaxis(Grid, [1 1], [], Pixels.Letters{Indx}, Pixels);
Indx= Indx+1;

for Indx_L = 1:nLevels
    Data = squeeze(M2S_Correct(:, :, Indx_L));
    
    subfigure(Space, miniGrid, [1, Indx_L], [], {}, Pixels);
    
    plotConfettiSpaghetti(Data, Sessions.Labels, [], [50 100], ...
        repmat(Format.Colors.Tasks.Match2Sample, nParticipants, 1), StatsP, Pixels);
    
    if Indx_L ==1
        ylabel(Format.Labels.Correct)
    end
    
    title(['Level ', num2str(Levels(Indx_L))])
end


%%% LAT
miniGrid = [1 3];

Space = subaxis(Grid, [1 2], [], Pixels.Letters{Indx}, Pixels);
Indx= Indx+1;


subfigure(Space, miniGrid, [1, 1], [], {}, Pixels);
plotConfettiSpaghetti(LAT_RT, Sessions.Labels, [], [], ...
    repmat(Format.Colors.Tasks.LAT, nParticipants, 1), StatsP, Pixels);
ylabel('Seconds')
title('Reaction Times')


subfigure(Space, miniGrid, [1, 2], [], {}, Pixels);
plotConfettiSpaghetti(LAT_Correct, Sessions.Labels, [], [], ...
    repmat(Format.Colors.Tasks.LAT, nParticipants, 1), StatsP, Pixels);
title('Correct')
ylabel('%')

subfigure(Space, miniGrid, [1, 3], [], {}, Pixels);
plotConfettiSpaghetti(LAT_Lapses, Sessions.Labels, [], [], ...
    repmat(Format.Colors.Tasks.LAT, nParticipants, 1), StatsP, Pixels);
title('Lapses')
ylabel('%')


%%% PVT
miniGrid = [1 2];

Space = subaxis(Grid, [2 1], [], Pixels.Letters{Indx}, Pixels);
Indx= Indx+1;

subfigure(Space, miniGrid, [1, 1], [], {}, Pixels);
plotConfettiSpaghetti(PVT_RT, Sessions.Labels, [], [], ...
    repmat(Format.Colors.Tasks.PVT, nParticipants, 1), StatsP, Pixels);
ylabel('Seconds')
title('Reaction Times')


subfigure(Space, miniGrid, [1, 2], [], {}, Pixels);
plotConfettiSpaghetti(PVT_Lapses, Sessions.Labels, [], [], ...
    repmat(Format.Colors.Tasks.PVT, nParticipants, 1), StatsP, Pixels);
title('Lapses')
ylabel('#')



%%% SpFT
miniGrid = [1 2];

Space = subaxis(Grid, [2 2], [], Pixels.Letters{Indx}, Pixels);
Indx= Indx+1;

subfigure(Space, miniGrid, [1, 1], [], {}, Pixels);
plotConfettiSpaghetti(SpFT_Correct, Sessions.Labels, [], [], ...
    repmat(Format.Colors.Tasks.SpFT, nParticipants, 1), StatsP, Pixels);
ylabel('Words/s')
title('Correct Words')


subfigure(Space, miniGrid, [1, 2], [], {}, Pixels);
plotConfettiSpaghetti(SpFT_Incorrect, Sessions.Labels, [], [], ...
    repmat(Format.Colors.Tasks.SpFT, nParticipants, 1), StatsP, Pixels);
title('Mistakes')
ylabel('Words/s')


saveFig('Behavior', Paths.Paper, Format)
