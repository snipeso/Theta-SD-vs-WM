function [EEG, TMPREJ] = cleanCuts(EEG, cutsPath)
% function that interpolates snippets of bad data, and removes bad channels

% load cuts
load(cutsPath, 'badchans', 'cutData', 'srate', 'TMPREJ')
if ~exist('badchans', 'var')
    badchans = [];
end

if ~exist('cutData', 'var')
    cutData = [];
end
if ~exist('TMPREJ', 'var')
    TMPREJ = [];
elseif ~isempty(TMPREJ)
    TMPREJ(:, 1:2) =  (TMPREJ(:, 1:2)./srate)*EEG.srate; % convert tmprej to new srate
end

% remove bad channels
badchans(badchans<1 | badchans>128) = []; % this is a precaution from some previously badly written scripts
badchans = unique(badchans);
EEG = pop_select(EEG, 'nochannel', badchans);


% clean data segments
if ~isempty(cutData)
    EEG = interpolateSnippets(EEG, badchans, cutData, srate);
end