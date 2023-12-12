%%% Instructions:
%%% This script calls the commands to help you mark the data that contains
%%% noise.
%%% Below, additional functions are provided you can call from the editor.


%% Section 1: Choose a file
%%% Choose the folder you want to edit, change the variable Source_Folder
%%% accordingly (this should be a folder in the folder "LightFiltering",
%%% and is onerm the tasks, like "MWT").
%%% If you want to clean a specific file, set the variable Filename
%%% accordingly; if you leave it as an empty list, the script will randomly
%%% select a file from your chosen folder that hasn't been marked yet.
clear
clc
close all
Prep_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

% % Single filename
% Filename = 'P168_Providence_Session1_eve_Oddball_n_2.mat'; % choose this if you want to clean a specific file P07_Standing_Main8

% % Filename list
% Filename = [
%     "P13_SpFT_Session2_Cutting.set"
% ];

Dataset = 'Providence';
Source_Folder = 'MAT'; % location of cut sources (use a different one [e.g. 'SET/Game'] if you don't want to randomly choose from whole pool)
Destination_Folder = 'Cuts'; % location where to save cuts
ifExists = 'Cuts';
allTasks = { 'Oddball'}; % comment out if you want all possible files

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('Filename', 'var') && size(Filename, 1)==1
    FN = split(Filename, '_');
    Folder = FN{5};
    
    Source = fullfile(Paths.Preprocessed, 'Cutting', Source_Folder, Dataset, Folder);
    Destination = fullfile(Paths.Preprocessed, 'Cutting', Destination_Folder,  Dataset, Folder);
    allTasks = Folder;
    
elseif exist('Filename', 'var') && size(Filename, 1)>1
    Filename = char(Filename(randperm(size(Filename, 1), 1), :));
    FN = split(Filename, '_');
    Folder = FN{2};
    
    Source = fullfile(Paths.Preprocessed, 'Cutting', Source_Folder,  Dataset, Folder);
    Destination = fullfile(Paths.Preprocessed, 'Cutting', Destination_Folder,  Dataset, Folder);
    allTasks = Folder;
    
else
    Source = fullfile(Paths.Preprocessed, 'Cutting', Source_Folder,  Dataset);
    Destination = fullfile(Paths.Preprocessed, 'Cutting', Destination_Folder,  Dataset);
    Filename = [];
end

EEG = loadEEGtoCut(Source, Destination, Filename, allTasks, ifExists); % load file
m = matfile(EEG.CutFilepath,'Writable',true); % create cuts file, load it to current workspace


% remove already the channels that don't get used for the ICA anyway
% EEG_Channels.notEEG = [81 75 94 95 49 56];
rmCh(EEG.CutFilepath, EEG_Channels.notEEG)

% open the window for cleaning the data
markData(EEG)  % rerun this every time you want to see updates on removed channels and segments

% EEGr = EEG;
% try
%     EEGr = pop_select(EEGr, 'nochannel', m.badchans);
% end

% EEGr = pop_reref(EEGr, []);
% PlotSpectopo(EEGr, 100, 200);

%% remove or restore a whole channel
%%% Use these to mark whole channels to be removed; sometimes this is a
%%% trial and error process, so it helps to write out the variable Ch
%%% listing all the channels as you discover them while going through the
%%% data, and then at some point saving and closing the data window,
%%% running rmCh(), then checking again in MarkData if you removed the
%%% right channels or not. You can restore channels that are fine with
%%% restoreCh;

% Ch = [];

% rmCh(EEG.CutFilepath, Ch) % remove channel or list of channels
% rsCh(EEG.CutFilepath, Ch) % restore removed channels

% function to plot a given dataset, with prev markings if exist, save the markings to a file

%% remove or restore a little piece of a channel
%%% If there's a little chunck of a channel that wen't haywire, but the
%%% rest of the channel is fine, you can mark a section to remove, by
%%% running rsSnippt(), indicating in seconds the start time and end time
%%% of the channel you want to remove. If you run this, then open
%%% MarkData() it will highlight the section in red.

% remove channels entirely
% rmSnip(EEG, StartTime, EndTime, Channel)
% rsSnip(EEG, StartTime, EndTime, Channel)



