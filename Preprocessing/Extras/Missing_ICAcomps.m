% script to get complete list of files that don't have their ICA components

clear
clc
close all

Prep_Parameters

NewExtention = '_Cutting.set';

Components_Folder = fullfile(Paths.Preprocessed, 'ICA', 'Components');
Power_Folder = fullfile(Paths.Preprocessed, 'Power', 'SET');

Missing = [];

for Indx_T = 1:numel(allTasks)
    Components = getContent(fullfile(Components_Folder, allTasks{Indx_T}));
    Components = extractBefore(Components, '_ICA_');
    
    Power = getContent(fullfile(Power_Folder, allTasks{Indx_T}));
    Power = extractBefore(Power, '_Power');
    
    Unclean = Power;
     Unclean(contains(Unclean, intersect(Power, Components))) = [];

     
     Unclean = append(Unclean, NewExtention);
     Missing = cat(1, Missing, Unclean);
end


disp(Missing)