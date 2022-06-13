
clear
clc
close all
Prep_Parameters

Task = 'TV';
Refresh = false;
BadChannel_Threshold = .33; % proportion of bad epochs before it gets counted as a bad channel
BadWindow_Threshold = .1; % proportion of bad channels before its counted as a bad window

Source = fullfile(Paths.Core, 'Outliers', Task);

Destination = fullfile(Paths.Preprocessed, 'Cutting', 'Cuts', Task);
if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Content = getContent(Source);
Content(~contains(Content, '.mat')) = [];

for Indx_F = 1:numel(Content)

    %%% Load data
    Filename = Content{Indx_F};

    Levels = split(Filename, '_');

    Filename_Destination = strjoin([Levels(1:3)', 'Cuts.mat'], '_');
    if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
        disp(['Skipping ', Filename])
        continue
    end

    load(fullfile(Source, Filename), 'artndxn', 'scoringlen')
    artndxn = double(artndxn);

    % load EEG data
    Filename_EEG = replace(Filename, '_artndxn', '');
    load(fullfile(Paths.Preprocessed, 'Cutting', 'MAT', Task, Filename_EEG), 'EEG')
    [nChannels, nPoints] = size(EEG.data);
    fs = EEG.srate;
    Chanlocs = EEG.chanlocs;

    Epoch_Edges = 1:scoringlen*fs:nPoints;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% identify what type of artifact

    %%% Bad windows

    % find holes (neighboring channels that are all bad)
    for Ch = EEG_Channels.notEEG
        Chanlocs(Ch).X = nan;
        Chanlocs(Ch).Y = nan;
        Chanlocs(Ch).Z = nan;
    end
    Holes = findHoles(artndxn, Chanlocs, EEG_Channels.Edges);

    % get epochs missing too many channels anyway
    EEG_artndxn = artndxn;
    EEG_artndxn(EEG_Channels.notEEG, :) = [];
    BadWindows = sum(EEG_artndxn==0)./size(EEG_artndxn, 1) >=BadWindow_Threshold;


    % set to nan holes so they're not counted in BadSnippets
    artndxn(:, Holes | BadWindows) = nan;

    % get start and end timepoints
    [Starts, Ends] = data2windows(Holes); % find continuous bad epochs
    Starts = Epoch_Edges(Starts);
    Ends = Epoch_Edges(Ends+1);

    % convert to Cuts format
    TMPREJ = zeros(numel(Starts), nChannels+5);
    TMPREJ(:, 1:2) = [Starts', Ends'];
    TMPREJ(:, 3:5) = repmat([1 1 0], numel(Starts), 1);


    %%% bad channels
    BadEpochs = sum(artndxn==0, 2, 'omitnan');
    badchans = find(BadEpochs./size(artndxn, 2) >= BadChannel_Threshold)';

    artndxn(badchans, :) = nan;

    % all remaining marked epochs that are neither bad channels nor bad
    % epochs into bad snippets
    BadSnippets = artndxn==0;

    % convert to Cuts format
    cutData = nan(nChannels, nPoints);
    for Indx_Ch = 1:nChannels
        for Indx_P = 1:size(artndxn, 2)
            if ~BadSnippets(Indx_Ch, Indx_P)
                continue
            end
            Points = Epoch_Edges(Indx_P):Epoch_Edges(Indx_P+1); % all points in the epoch
            cutData(Indx_Ch, Points) = EEG.data(Indx_Ch, Points);
        end
    end

    %%% save to cuts
    save(fullfile(Destination, Filename_Destination), 'badchans', 'cutData', 'TMPREJ')
    disp(['Finished ', Filename])
end


