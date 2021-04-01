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
Destination_Folder = 'New_Cuts'; % location where to save cuts
Old_Destination = ''; % 'Old_Cuts'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(Filename)
    Source = fullfile(Paths.Preprocessed, 'Cutting', Source_Folder, Folder);
    Destination = fullfile(Paths.Preprocessed, 'Cutting', Destination_Folder, Folder);
    Randomize = false;
else
    Source = fullfile(Paths.Preprocessed, 'Cutting', Source_Folder);
    Destination = fullfile(Paths.Preprocessed, 'Cutting', Destination_Folder);
    Randomize = true;
end

EEG = loadEEGtoCut(Source, Destination, Filename, Randomize); % load file
m = matfile(EEG.CutFilepath,'Writable',true); % create cuts file, load it to current workspace

% if provided, get old TMPREJ and nan matrix (this is to use old cuts to avoid wasting too much time)
if exist('Old_Destination', 'var')
    OldCutFilepath = replace(EEG.CutFilepath, Destination_Folder, Old_Destination);
    AlreadyDid = whos(m);
    if ~contains(AlreadyDid, 'TMPREJ')
        load(OldCutFilepath, 'TMPREJ') % create cuts file, load it to current workspace
        
        if exist('TMPREJ', 'var')
            m.TMPREJ = TMPREJ;
        end
    end
    
    if ~contains(AlreadyDid, 'cutData')
            load(OldCutFilepath, 'cutData') % create cuts file, load it to current workspace
        
        if exist('cutData', 'var')
            m.cutData = cutData;
        end
    end
end

% remove already the channels that don't get used for the ICA anyway
rmCh(EEG.CutFilepath, EEG_Channels.notEEG)

% open the window for cleaning the data
MarkData(EEG)  % rerun this every time you want to see updates on removed channels and segments

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


