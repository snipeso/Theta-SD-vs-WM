function [BadData, strScores] = loadVIS(Filepath)
% Script for reading a VIS file in a folder, and 


Content = getContent(Filepath);
Content(~contains(Content, '.vis')) = [];

% find correct vis file
if any(contains(Content, 'rh')) % if reto scored it
    VIS_Filename = Content(contains(Content, 'rh'));
elseif numel(Content) == 1 % if there's only one vis
    VIS_Filename = Content;
      warning(['No Reto score in ', Filepath])
elseif numel(Content) > 1 % if there's more than one, just get the first
      VIS_Filename = Content(1);
      warning(['More than one VIS in ', Filepath])
else
    warning(['No VIS in ', Filepath])
    return
end

% read .vis file
[BadData, strScores, ~] = visfun.readtrac(fullfile(Filepath, VIS_Filename), 1);