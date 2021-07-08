% Script for calculating power of EEG files. Saves each one as a .mat with
% file FFT ch x freq, saving also Freqs and Chanlocs. These are saved in a
% folder indicating the welch parameters used.
% For each file, there will also be a png showing delta, theta, alpha and
% beta topoplots, and the frequency spectrums of Fz, Cz, P3, O1.

close all
clear
clc

Analysis_Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = false;
Tasks = { 'Fixation', 'Game', 'Match2Sample', 'PVT', 'LAT', 'SpFT', 'Music'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WelchWindow = 5;
Freqs = 0.5:(1/WelchWindow):40;

for Indx_T = 1:numel(Tasks)
    
    Task = Tasks{Indx_T};
    
    % get files and paths
    Source = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', 'New_Cuts', Task);
    Destination = fullfile(Paths.Data, 'EEG', 'Unlocked', Task); % TODO: put in 'Unlocked'
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files)
        
        File = Files{Indx_F};
        Filename_Core = extractBefore(File, '_Clean.set');
        Filename = [Filename_Core, '_Welch.mat'];
        
        % skip if already done
        if ~Refresh && exist(fullfile(Destination, Filename), 'file')
            disp(['**************already did ',Filename, '*************'])
            continue
        end
        
        % load EEG
        EEG = pop_loadset('filename', File, 'filepath', Source);
        
        
        
        %%% Set as nan all noise
        
        % remove nonEEG channels
        [Channels, Points] = size(EEG.data);
        fs = EEG.srate;
        Chanlocs = EEG.chanlocs;
        
        try % some files have this, others not; quicker than checking for all the triggers
            disp('removing edge data...')
            
            % remove start and stop
            StartPoint = EEG.event(strcmpi({EEG.event.type}, EEG_Triggers.Start)).latency;
            EndPoint =  EEG.event(strcmpi({EEG.event.type},  EEG_Triggers.End)).latency;
            EEG.data(:, [1:round(StartPoint),  round(EndPoint):end]) = nan; %this gets removed in rmNoise, which removes anything that's a nan
        catch
            disp('not removing edge data...')
        end
        
        % set to nan all cut data
        Cuts_Filepath = fullfile(Source_Cuts, [Filename_Core, '_Cuts.mat']);
        
%         try
        EEG = rmNoise(EEG, Cuts_Filepath);
%         catch
%             continue
%         end
        
        
        %%% get power
        [Power, ~] = pwelch(EEG.data', fs*WelchWindow,  (fs*WelchWindow)/2, Freqs, fs);
        Power = Power';
        
        % save
        parsave(fullfile(Destination, Filename), Power, Freqs, Chanlocs)
        disp(['*************finished ',Filename '*************'])
    end
    
end

function parsave(fname, Power, Freqs, Chanlocs)
save(fname, 'Power', 'Freqs', 'Chanlocs')
end