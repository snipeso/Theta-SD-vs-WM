%%% Instructions:
%%% This script calls the commands to help you mark the data that contains
%%% noise. 
%%% Run each section one at a time (click on it so it turns yellow, then click "run
%%% section" in the above tool bar). Each section explains how it works.
%%% Numbered sections have to happen first, and in their order, other
%%% sections include additional functions you can call from the editor.


%% Section 1: Choose a file
%%% Choose the folder you want to edit, change the variable Folder.Data
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

% Filename = 'P10_Match2Sample_Session2_Cleaning.set'; % choose this if you want to clean a specific file
% Folder = 'Match2Sample';

Filename = []; % choose this if you want to randomly select a file to clean from the list

Source_Folder = 'SET'; % location of cut sources (use a different one [e.g. 'SET/Game'] if you don't want to randomly choose from whole pool)
Destination_Folder = 'Cuts'; % location where to save cuts

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(Filename)
    Source = fullfile(Paths.Preprocessed, 'Cleaning', Source_Folder, Folder);
    Destination = fullfile(Paths.Preprocessed, 'Cleaning', Destination_Folder, Folder);
    Randomize = false;
else
     Source = fullfile(Paths.Preprocessed, 'Cleaning', Source_Folder);
    Destination = fullfile(Paths.Preprocessed, 'Cleaning', Destination_Folder);
    Randomize = true;
end

EEG = loadEEGtoCut(Source, Destination, Filename, Randomize); % load file
m = matfile(EEG.CutFilepath,'Writable',true); % create cuts file, load it to current workspace



%% Section 2: autoclean
%%% You can opt out of this, but it's recommended. You can run it as is,
%%% and it will automatically find sections of the data to cut. Your job
%%% will then be to fix it. If AutoCut is cutting out too much clean data,
%%% or too little, you can manually change the threshold. First look at the
%%% plot (set showPlots to true), and set the threshold.
%%% If you want to remove all the autoCuts, just run RemoveCuts(), which
%%% removes all the yellow ([1,1,0]) markings.
%%NOTE: ONLY RUN ONCE for each file! If you are opening everything for a second time,
%%this will just make a mess.

Threshold = [];
Color = [1, 1, 0]; % Color for AutoCut
showPlots = false;
% AutoCut(EEG, Color, [], showPlots)

%TODO: Autoremove EMG
% RemoveCuts(EEG, [1, 1, 0]) % removes autocut data

%% Section 3: plot all
%%% run this function to open the popup window for marking the data. SAVE
%%% BEFORE CLOSING. But if you do that, you can always open wherever you
%%% left off. Run as many times as you want
rmCh(EEG.CutFilepath, EEG_Channels.notEEG)
 
MarkData(EEG) 

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
% restoreCh(EEG.CutFilepath, Ch) % restore removed channels

% function to plot a given dataset, with prev markings if exist, save the markings to a file

%% remove or restore a little piece of a channel
%%% If there's a little chunck of a channel that wen't haywire, but the
%%% rest of the channel is fine, you can mark a section to remove, by
%%% running CutSnippt(), indicating in seconds the start time and end time
%%% of the channel you want to remove. If you run this, then open
%%% MarkData() it will highlight the section in red.

% remove channels entirely
% CutSnippet(EEG, StartTime, EndTime, Channel)
% RestoreSnippet(EEG, StartTime, EndTime, Channel)



