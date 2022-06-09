% Script for calculating power of EEG files. Saves each one as a .mat with
% file FFT ch x freq, saving also Freqs and Chanlocs. These are saved in a
% folder indicating the welch parameters used.
% For each file, there will also be a png showing delta, theta, alpha and
% beta topoplots, and the frequency spectrums of Fz, Cz, P3, O1.

close all
clear
clc

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Format = P.Format;
Channels = P.Channels;
% Tasks = P.AllTasks;
Tasks = {'Fixation', 'Standing', 'Oddball'};

Refresh = false;
WelchWindow = 8; % duration of window to do FFT
Overlap = .75; % overlap of hanning windows for FFT

EEG_Triggers.Start = 'S  1';
EEG_Triggers.End = 'S  2';

% durations to loop through for each task
Durations.Match2Sample =  [-2, -4, 1 2 4 6 8, 10, 12, 15, 20];
Durations.LAT =  [-2, -4, 1 2 4 6 8, 10];
Durations.PVT =  [-2, -4, 1 2 4 6 8];
Durations.SpFT =  [-2, 1 2 4];
Durations.Game =  [-2, -4, 1 2 4 6 8];
Durations.Music =  [-2, 1 2 4];
Durations.Fixation = [5];
Durations.Standing = [5];
Durations.Oddball = [5];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate power for minutes of the recording

for Indx_T = 1:numel(Tasks)
    
    Task = Tasks{Indx_T};
    
    % get files and paths
    Source = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', 'Cuts', Task);
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files)
        
        File = Files{Indx_F};
        Filename_Core = extractBefore(File, '_Clean.set');
        Filename = [Filename_Core, '_Welch.mat'];
        
        % load EEG
        EEG = pop_loadset('filename', File, 'filepath', Source);
        fs = EEG.srate;
        
        %%% Remove bad data
        
        % remove nonEEG channels
        EEG = pop_select(EEG, 'nochannel', labels2indexes(Channels.Remove, EEG.chanlocs));

        % remove beginning
        if any(strcmpi({EEG.event.type}, EEG_Triggers.Start))
            StartPoint = EEG.event(strcmpi({EEG.event.type}, EEG_Triggers.Start)).latency;
            EEG.data(:, 1:round(StartPoint)) = nan; %this gets removed in rmNoise, which removes anything that's a nan
        else
            warning('not removing beginning data...')
        end
        
        % remove ending
        if any(strcmpi({EEG.event.type},  EEG_Triggers.End))
            EndPoint =  EEG.event(strcmpi({EEG.event.type},  EEG_Triggers.End)).latency;
            EEG.data(:, round(EndPoint):end) = nan; %this gets removed in rmNoise, which removes anything that's a nan
        else
            warning('not removing end data...')
        end
        
        % remove all data marked as noise in cuts
        Cuts_Filepath = fullfile(Source_Cuts, [Filename_Core, '_Cuts.mat']);
        EEG = rmNoise(EEG, Cuts_Filepath);
        
        % remove all data changed to NaN (beginnings and ends
        EEG = rmNaN(EEG);
        
        
        %%% get power
        for D = Durations.(Task) % loop through different file durations
            
            Tag = [ 'window',num2str(WelchWindow), 's_duration' num2str(D),'m'];
            Destination = fullfile(Paths.Data, 'EEG', 'Unlocked', Tag, Task);
            if ~exist(Destination, 'dir')
                mkdir(Destination)
            end
            
            % skip if already done
            if ~Refresh && exist(fullfile(Destination, Filename), 'file')
                disp(['**************already did ',Filename, '*************'])
                continue
            end
            
            % get the requested amount of data
            EEGshort = keepEEG(EEG, D);
            
            Chanlocs = EEGshort.chanlocs;
            Duration = size(EEGshort.data, 2)/EEGshort.srate;
            
            % FFT
            nfft = 2^nextpow2(WelchWindow*fs);
            noverlap = round(nfft*Overlap);
            window = hanning(nfft);
            [Power, Freqs] = pwelch(EEGshort.data', window, noverlap, nfft, fs);
            Power = Power';
            Freqs = Freqs';
            
            % plot it
            Title = replace([Filename_Core, ' ',Tag], '_', ' ');
            PlotSummaryPower(Power, Freqs, Chanlocs, Bands, Channels, Title, Format, Labels)
            
            % save
            save(fullfile(Destination, Filename), 'Power', 'Freqs', 'Chanlocs', 'Duration')
            Filename_Figure = strjoin({Filename_Core, Tag, 'Welch.jpg'}, '_');
            saveas(gcf,fullfile(Destination, Filename_Figure))
            close
        end
        disp(['*************finished ',Filename '*************'])
    end
end