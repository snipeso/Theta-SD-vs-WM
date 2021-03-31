% This script is for manually removing components containing noise. Click
% run. A popup will appear with the top 35 components of a randomly
% selected file. Select the bad components, then press ok. 2 popups will
% show the new data; evaluate if it is sufficiently cleaned. When prompted
% in the editor, indicate 'y' for accepting selection, 'n' for rejecting it
% and running it again, and 's' to skip and do a different one.

% if you indicate "automate", it will just apply the selection and removal
% of components already done to the indicated datatype.

clear
eeglab % needs to be run every time to clear global variables
close all
clc
Prep_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Data_Type = 'Power';
% Filename = ['P01_Game_Session2_ICA_Components.set'];
% Task = 'Match2Sample';
Filename = [];

CheckOutput = true; % manually verify if selection was good at the end
Automate = false; % automatically apply previous selection of components to Data_Type (used when applying to ERP data)
Refresh = false; % redo already done files

Component_Folder = 'Components'; % 'Components';
Destination_Folder = 'Clean'; % 'Deblinked'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% choose a random task
if ~exist('Task', 'var') || isempty(Task)
    Task = allTasks{randi(numel(allTasks))};
end

% get files and paths
load('StandardChanlocs128.mat', 'StandardChanlocs')
load('Cz.mat', 'CZ')

Source_Comps = fullfile(Paths.Preprocessed, 'ICA', Component_Folder, Task);
Source_Data = fullfile(Paths.Preprocessed, Data_Type, 'SET', Task);
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
    
    if isempty(Filename)
        Filename_Comps = Files{Indx_F};
    else
        Filename_Comps = Filename;
    end
    
    Filename_Data = replace(Filename_Comps, 'ICA_Components', Data_Type);
    Filename_Destination = [extractBefore(Filename_Data, Data_Type), '_Clean.set'];
    
    
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
    
    % remove channels from Data that aren't in EEG
    Data = pop_select(Data, 'channel', labels2indexes({EEG.chanlocs.labels}, Data.chanlocs));
    
    % interpolate bad snippets
    Data = InterpolateSnippets(Data, [], cutData, srate, true);
    
    % add CZ
    Data.data(end+1, :) = zeros(1, size(Data.data, 2));
    Data.chanlocs(end+1) = CZ;
    
    % rereference to average
    Data = pop_reref(Data, []);
    
    %%% interface for selecting components
    RemoveComps
    if Break
        break
    end
    
end
