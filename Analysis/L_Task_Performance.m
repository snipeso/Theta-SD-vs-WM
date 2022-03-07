% all task performance things together just for the sake of the paper
% figure.


P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Format = P.Format;
Manuscript = P.Manuscript;
StatsP = P.StatsP;
Labels = P.Labels;

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

clc

Manuscript.Figure.Padding = 30; % reduce because of subplots
Grid = [2, 2];
Indx_B = 2; % theta
Indx = 1;
YLims = [-.3 1];

figure('units','centimeters','position',[0 0 Manuscript.Figure.Width Manuscript.Figure.Height*.4])

%%% M2S
miniGrid = [1 3];

Space = subaxis(Grid, [1 1], [], Manuscript.Indexes.Letters{Indx}, Manuscript);
Indx= Indx+1;

for Indx_L = 1:nLevels
    Data = squeeze(M2S_Correct(:, :, Indx_L));
    
    subfigure(Space, miniGrid, [1, Indx_L], [], true, {}, Manuscript);
    Stats = data2D(Data, Sessions.Labels, [], [35 100], ...
        repmat(Format.Color.Tasks.Match2Sample, nParticipants, 1), StatsP, Manuscript);
    
    dispStat(Stats, [1 3], ['M2S L',  num2str(Levels(Indx_L))])
    
    if Indx_L ==1
        ylabel(Labels.Correct)
    end
    
    title(['Level ', num2str(Levels(Indx_L))])
end


%%% LAT
miniGrid = [1 3];

% RTs
Space = subaxis(Grid, [1 2], [], Manuscript.Indexes.Letters{Indx}, Manuscript);
Indx= Indx+1;


subfigure(Space, miniGrid, [1, 1], [],true, {}, Manuscript);
Stats = data2D(LAT_RT, Sessions.Labels, [], [], ...
    repmat(Format.Color.Tasks.LAT, nParticipants, 1), StatsP, Manuscript);
ylabel('Seconds')
title('Reaction Times')

dispStat(Stats, [1 3], 'LAT RTs')


% correct
subfigure(Space, miniGrid, [1, 2], [], true, {}, Manuscript);
Stats = data2D(LAT_Correct, Sessions.Labels, [], [], ...
    repmat(Format.Color.Tasks.LAT, nParticipants, 1), StatsP, Manuscript);
title('Correct')
ylabel('%')

disp('LAT Correct:')
disp(['(t = ', num2str(Stats.t(1, 3), '%.2f'), ', df = ', num2str(Stats.df(1, 3)), ...
    ', p < ', num2str(Stats.p(1, 3), '%.3f'), ', g = ', num2str(Stats.hedgesg(1, 3), '%.2f'), ')'])


% lapses
subfigure(Space, miniGrid, [1, 3], [], true, {}, Manuscript);
Stats = data2D(LAT_Lapses, Sessions.Labels, [], [], ...
    repmat(Format.Color.Tasks.LAT, nParticipants, 1), StatsP, Manuscript);
title('Lapses')
ylabel('%')

disp('LAT lapses:')
disp(['(t = ', num2str(Stats.t(1, 3), '%.2f'), ', df = ', num2str(Stats.df(1, 3)), ...
    ', p < ', num2str(Stats.p(1, 3), '%.3f'), ', g = ', num2str(Stats.hedgesg(1, 3), '%.2f'), ')'])


%%% PVT
miniGrid = [1 2];

Space = subaxis(Grid, [2 1], [], Manuscript.Indexes.Letters{Indx}, Manuscript);
Indx= Indx+1;

% RTs
subfigure(Space, miniGrid, [1, 1], [], true, {}, Manuscript);
Stats = data2D(PVT_RT, Sessions.Labels, [], [], ...
    repmat(Format.Color.Tasks.PVT, nParticipants, 1), StatsP, Manuscript);
ylabel('Seconds')
title('Reaction Times')

dispStat(Stats, [1 3], 'PVT RTs')


% lapses
subfigure(Space, miniGrid, [1, 2], [], true, {}, Manuscript);
Stats = data2D(PVT_Lapses, Sessions.Labels, [], [], ...
    repmat(Format.Color.Tasks.PVT, nParticipants, 1), StatsP, Manuscript);
title('Lapses')
ylabel('#')

disp('PVT lapses:')
disp(['(t = ', num2str(Stats.t(1, 3), '%.2f'), ', df = ', num2str(Stats.df(1, 3)), ...
    ', p < ', num2str(Stats.p(1, 3), '%.3f'), ', g = ', num2str(Stats.hedgesg(1, 3), '%.2f'), ')'])

%%% SpFT
miniGrid = [1 2];

Space = subaxis(Grid, [2 2], [], Manuscript.Indexes.Letters{Indx}, Manuscript);
Indx= Indx+1;

% correct
subfigure(Space, miniGrid, [1, 1], [], true, {}, Manuscript);
Stats = data2D(SpFT_Correct, Sessions.Labels, [], [], ...
    repmat(Format.Color.Tasks.SpFT, nParticipants, 1), StatsP, Manuscript);
ylabel('Words/s')
title('Correct Words')

disp('SpFT correct:')
disp(['(t = ', num2str(Stats.t(1, 3), '%.2f'), ', df = ', num2str(Stats.df(1, 3)), ...
    ', p < ', num2str(Stats.p(1, 3), '%.3f'), ', g = ', num2str(Stats.hedgesg(1, 3), '%.2f'), ')'])


% mistakes
subfigure(Space, miniGrid, [1, 2], [], true, {}, Manuscript);
Stats = data2D(SpFT_Incorrect, Sessions.Labels, [], [], ...
    repmat(Format.Color.Tasks.SpFT, nParticipants, 1), StatsP, Manuscript);
title('Mistakes')
ylabel('Words/s')

disp('SpFT mistakes:')
disp(['(t = ', num2str(Stats.t(1, 3), '%.2f'), ', df = ', num2str(Stats.df(1, 3)), ...
    ', p < ', num2str(Stats.p(1, 3), '%.3f'), ', g = ', num2str(Stats.hedgesg(1, 3), '%.2f'), ')'])

saveFig('Behavior', Paths.Paper, Format)
