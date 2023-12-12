% This script is for manually removing components containing noise. Cl
% indicated datatype.

clear
eeglab % needs to be run every time to clear global variables
close all
clc

StartTic = tic;

Prep_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Data_Type = 'Power';

Task  = 'Oddball'; % which tasks to convert (for now)
Dataset = 'Providence';
Filename = [];
Refresh = false; % redo already done files
CheckOutput = true; % manually verify if selection was good at the end
MinTimeData = 60;
MinCh = 100;

% % %%% emergency code if I need to fix a specific file
% Filename = 'P09_Match2Sample_Session2_ICA_Components.set';
% FN = split(Filename, '_');
% Task = FN{2};
% Refresh = true;
% CheckOutput = true; % manually verify if selection was good at the end

Component_Folder = 'Manual'; % 'Components';
Destination_Folder = 'Clean'; % 'Clean'
Source_Cuts_Folder = 'Cuts'; % 'Cuts'

IC_Brain_Threshold = 0.1; % %confidence of automatic IC classifier in determining a brain artifact
IC_Other_Threshold = 0.6; % %confidence of automatic IC classifier in determining a brain artifact

IC_Max = 80; % limit of components automatically considered for elimination

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ICA_Folder = 'ICA';
StandardColor = {[0.19608  0.19608  0.51765]}; % for plotting

% standard responses for user inputs
redo = 'redo';
s = 's';
y = 'y';
n = 'n';


% get files and paths
load('StandardChanlocs128.mat', 'StandardChanlocs')
load('Cz.mat', 'CZ')

Source_Comps = fullfile(Paths.Preprocessed, ICA_Folder, Component_Folder, Dataset, Task);
Source_Data = fullfile(Paths.Preprocessed, Data_Type, 'MAT', Dataset, Task);
Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', Source_Cuts_Folder, Dataset, Task);
Destination = fullfile(Paths.Preprocessed,  Data_Type, Destination_Folder, Dataset, Task);

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = deblank(cellstr(ls(Source_Comps)));
Files(~contains(Files, '.mat')) = [];

% randomize files list

if ~Refresh
DoneFiles = getContent(Destination);
Files(contains(Files, DoneFiles)) = [];
end

nFiles = numel(Files);
Files = Files(randperm(nFiles));


    if exist('Filename', 'var') && ~isempty(Filename)
        Files = Filename;
        nFiles = 1;
    end


for Indx_F = 1:nFiles % loop through files in source folder

    %%% get filenames

            Filename = Files{Indx_F};


    % skip if file already exists or data doesn't exist yet
    if ~Refresh && exist(fullfile(Destination, Filename), 'file')
        continue
    elseif ~exist(fullfile(Source_Data, Filename), 'file')
        disp(['***********', 'No data for ', Filename, '***********'])
        continue
    end


    %%% Get data ready
    % load data
    load(fullfile(Source_Data, Filename), 'EEG')
    Data = EEG;
    load(fullfile(Source_Comps, Filename), 'EEG')


    if size(EEG.data, 2)/EEG.srate < MinTimeData || size(EEG.data, 1) < MinCh
        warning(['not enough data in ' Filename])
        continue
    end

    % interpolate bad snippets
    [Data, TMPREJ] = cleanCuts(Data, fullfile(Source_Cuts, Filename));

    % add CZ
    Data.data(end+1, :) = zeros(1, size(Data.data, 2));
    Data.chanlocs(end+1) = CZ;

    % rereference to average
    Data = pop_reref(Data, []);

    %%% interface for selecting components
    RemoveComps
    if Break % this is important to let the script loop when running automatically on all the files
        break
    end

end
disp(Task)
