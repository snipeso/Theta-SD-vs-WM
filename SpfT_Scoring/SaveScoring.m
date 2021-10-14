% Script that takes the anonymous scoring, tracks back which file and
% participant it comes from, and saves a new folder called "Scoring" for
% each session.
clear
clc
close all

%%% Load parameters
P = spft_Parameters();
Paths = P.Paths;

% get table of locations
Scoring = fullfile(Paths.Scoring, 'Scoring_Anonymized');
AllData = readtable(fullfile(Scoring, 'All_Paths.csv'), 'Delimiter', ',');

%%% go through every file, and save CSV into a scoring folder in the raw data
Files = deblank(string(ls(Scoring)));
Files(~contains(Files, 'csv')) = [];
Files(~contains(Files, 'SpFT')) = [];

for Indx_F = 1:numel(Files)
    
   ID = str2double(extractBetween(Files(Indx_F), '_', '.csv')); 
   Row = AllData.ID==ID;
   
   Destination = replace(AllData.Path{Row}, 'Recordings', 'Scoring');
   if ~exist(Destination, 'dir')
       mkdir(Destination)
   end
   
   Old = fullfile(Scoring, Files(Indx_F));
   New = fullfile(Destination, replace(AllData.Filename{Row}, '.wav', '.csv'));
   copyfile(Old, New)
   
end