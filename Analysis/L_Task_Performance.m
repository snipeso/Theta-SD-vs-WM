% all task performance things together just for the sake of the paper
% figure.

clear
clc
close all

P = analysisParameters();
Paths = P.Paths;
Participants = P.Participants;
Sessions = P.Sessions;
Format = P.Format;
Format = P.Manuscript;
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

[Trials, LAT_RT, Types, TotT] = loadBehavior(Participants, Sessions.LAT, 'LAT', Paths, false);
LAT_Lapses = 100*(squeeze(Types(:, :, 1))./TotT);
LAT_Correct = 100*(squeeze(Types(:, :, 3))./TotT);



%%% PVT

[Trials, PVT_RT, Types, ~] = loadBehavior(Participants, Sessions.PVT, 'PVT', Paths, false);
PVT_Lapses = squeeze(Types(:, :, 1));


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


%% Suppl. Figure BEHZ

clc
Format = P.Manuscript;
Format.Figure.Padding = 6; % reduce because of subplots
Format.Axes.yPadding = 15;
Format.Axes.xPadding = 20;
Grid = [2, 5];
Indx_B = 2; % theta
Indx = 1;
YLims = [-.3 1];
StatsP = P.StatsP;
Colors = 'Participants'; % either 'Task' or 'Participants' or 'Order'


figure('units','centimeters','position',[0 0 Format.Figure.W3*1.2 Format.Figure.Height*.5])

%%% M2S
miniGrid = [1 3];

switch Colors
    case 'Task'
        Color = repmat(Format.Color.Tasks.Match2Sample, nParticipants, 1);
    case 'Order'
        Color = repmat(getColors(1, '', 'yellow'), nParticipants, 1);
        Color([1 5 12 end], :) = repmat(getColors(1, '', 'blue'), 4, 1);
        StatsP = [];
    otherwise
        Color = Format.Color.Participants;
end

Space = subaxis(Grid, [1 1], [1 3], Format.Indexes.Letters{Indx}, Format);
Indx= Indx+1;

for Indx_L = 1:nLevels
    Data = squeeze(M2S_Correct(:, :, Indx_L));

    subfigure(Space, miniGrid, [1, Indx_L], [], true, {}, Format);
    Stats = data2D('line', Data, Sessions.Labels, [], [35 105], Color, StatsP, Format);

    dispStat(Stats, [1 3], ['M2S L',  num2str(Levels(Indx_L))])

    if Indx_L ==1
        ylabel(Labels.Correct)
    end
    padAxis('y')


    title(['L', num2str(Levels(Indx_L))], 'FontSize', Format.Text.TitleSize)
end


%%% PVT
miniGrid = [1 2];
if strcmp(Colors, 'Task')
    Color = repmat(Format.Color.Tasks.PVT, nParticipants, 1);
end

Space = subaxis(Grid, [1 4], [1 2], Format.Indexes.Letters{Indx}, Format);
Indx= Indx+1;

% RTs
subfigure(Space, miniGrid, [1, 1], [], true, {}, Format);
Stats = data2D('line', PVT_RT, Sessions.Labels, [], [], Color, StatsP, Format);
ylabel('Seconds')
title('PVT RTs',  'FontSize', Format.Text.TitleSize)
padAxis('y')

dispStat(Stats, [1 3], 'PVT RTs')


% lapses
subfigure(Space, miniGrid, [1, 2], [], true, {}, Format);
Stats = data2D('line', PVT_Lapses, Sessions.Labels, [], [], Color, StatsP, Format);
title('PVT Lapses',  'FontSize', Format.Text.TitleSize)
ylabel('#')

dispStat(Stats, [1 3], 'PVT lapses')


%%% LAT
miniGrid = [1 3];
if strcmp(Colors, 'Task')
    Color = repmat(Format.Color.Tasks.LAT, nParticipants, 1);
end

% RTs
Space = subaxis(Grid, [2 1], [1 3], Format.Indexes.Letters{Indx}, Format);
Indx= Indx+1;


subfigure(Space, miniGrid, [1, 1], [],true, {}, Format);
Stats = data2D('line', LAT_RT, Sessions.Labels, [], [], Color, StatsP, Format);
ylabel('Seconds')
title('LAT RTs',  'FontSize', Format.Text.TitleSize)
padAxis('y')

dispStat(Stats, [1 3], 'LAT RTs')


% correct
subfigure(Space, miniGrid, [1, 2], [], true, {}, Format);
Stats = data2D('line', LAT_Correct, Sessions.Labels, [], [], Color, StatsP, Format);
title('LAT Correct',  'FontSize', Format.Text.TitleSize)
ylabel('%')
padAxis('y')

dispStat(Stats, [1 3], 'LAT Correct:')


% lapses
subfigure(Space, miniGrid, [1, 3], [], true, {}, Format);
Stats = data2D('line', LAT_Lapses, Sessions.Labels, [], [], Color, StatsP, Format);
title('LAT Lapses',  'FontSize', Format.Text.TitleSize)
ylabel('%')


dispStat(Stats, [1 3], 'LAT lapses:')


%%% SpFT
miniGrid = [1 2];
if strcmp(Colors, 'Task')
    Color = repmat(Format.Color.Tasks.SpFT, nParticipants, 1);
end

Space = subaxis(Grid, [2 4], [1 2], Format.Indexes.Letters{Indx}, Format);
Indx= Indx+1;

% correct
subfigure(Space, miniGrid, [1, 1], [], true, {}, Format);
Stats = data2D('line', SpFT_Correct, Sessions.Labels, [], [], Color, StatsP, Format);
ylabel('Words/s')
title('Correct Words',  'FontSize', Format.Text.TitleSize)
padAxis('y')

dispStat(Stats, [1 3], 'SpFT Correct:')


% mistakes
subfigure(Space, miniGrid, [1, 2], [], true, {}, Format);
Stats = data2D('line', SpFT_Incorrect, Sessions.Labels, [], [], Color, StatsP, Format);
title('Mistakes',  'FontSize', Format.Text.TitleSize)
ylabel('Words/s')
padAxis('y')

dispStat(Stats, [1 3], 'SpFT mistakes:')

saveFig(['I_Task_Performance_', Colors], Paths.Paper, Format)
