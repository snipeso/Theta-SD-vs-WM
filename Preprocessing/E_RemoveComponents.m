% This script is for manually removing components containing noise. Cl
% indicated datatype.

clear
eeglab % needs to be run every time to clear global variables
close all
clc
Prep_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Data_Type = 'Power';
% Filename = ['P10_Fixation_BaselinePost_ICA_Components.set'];
% Task = 'Fixation';
% allTasks = {'Fixation', 'Standing', 'Oddball', 'Game'};
Filename = [];

CheckOutput = true; % manually verify if selection was good at the end
Automate = false; % automatically apply previous selection of components to Data_Type (used when applying to ERP data)
Refresh = true; % redo already done files

Component_Folder = 'Components'; % 'Components';
Destination_Folder = 'Clean'; % 'Clean'
Source_Cuts_Folder = 'New_Cuts'; % 'Cuts'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ICA_Folder = 'ICA';

% choose a random task
if ~exist('Task', 'var') || isempty(Task)
    Task = allTasks{randi(numel(allTasks))};
end

% get files and paths
load('StandardChanlocs128.mat', 'StandardChanlocs')
load('Cz.mat', 'CZ')

Source_Comps = fullfile(Paths.Preprocessed, ICA_Folder, Component_Folder, Task);
Source_Data = fullfile(Paths.Preprocessed, Data_Type, 'SET', Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', Source_Cuts_Folder, Task);
Destination = fullfile(Paths.Preprocessed, Destination_Folder, Data_Type, Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source_Comps)));
Files(~contains(Files, '.set')) = [];

% randomize files list
nFiles = numel(Files);
Files = Files(randperm(nFiles));

for Indx_F = 1:nFiles % loop through files in source folder
    
    %%% get filenames
    
    if ~exist('Filename', 'var') || isempty(Filename)
        Filename_Comps = Files{Indx_F};
    else
        Filename_Comps = Filename;
    end
    
    Filename_Core = extractBefore(Filename_Comps, '_ICA_Components');
    Filename_Data = [Filename_Core, '_' Data_Type, '.set'];
    
    Filename_Destination = [Filename_Core, '_Clean.set'];
    Filename_Cuts =  [Filename_Core, '_Cuts.mat'];
    
    % skip if file already exists or data doesn't exist yet
    if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
        disp(['***********', 'Already did ', Filename_Destination, '***********'])
        continue
    elseif ~exist(fullfile(Source_Data, Filename_Data), 'file')
        disp(['***********', 'No data for ', Filename_Destination, '***********'])
        continue
    end
    
    
    %%% Get data ready
    
    % load data
    Data = pop_loadset('filepath', Source_Data, 'filename', Filename_Data); % this is the data where you want to remove the components
    clc
    EEG = pop_loadset('filepath', Source_Comps, 'filename', Filename_Comps); % this is the data where components were generated (and save the bad ones)
    clc % hide filename
    
    
    % interpolate bad snippets
    [Data, TMPREJ] = cleanCuts(Data, fullfile(Source_Cuts, Filename_Cuts));
    
    % add CZ
    Data.data(end+1, :) = zeros(1, size(Data.data, 2));
    Data.chanlocs(end+1) = CZ;
    
    % rereference to average
    Data = pop_reref(Data, []);
    
    %%% interface for selecting components
    
    % only first time, plot all the components open
    
    pop_prop( EEG, 0, 1:35, gcbo, { 'freqrange', [1 40] });
    disp('press enter to proceed')
    pause
    RemoveComps
    if Break
        break
    end
    
end
