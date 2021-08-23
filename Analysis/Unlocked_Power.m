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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Refresh = false;
Tasks = { 'Fixation', 'Game', 'Match2Sample', 'PVT', 'LAT', 'SpFT', 'Music'};
Duration = 5; % in minutes


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WelchWindow = 8;
Freqs = 0.5:(1/WelchWindow):40;

if isempty(Duration)
    Tag = num2str(WelchWindow);
else
    Tag = [ num2str(WelchWindow), '_' num2str(Duration)];
end


for Indx_T = 1:numel(Tasks)
    
    Task = Tasks{Indx_T};
    
    % get files and paths
    Source = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task);
    Source_Cuts = fullfile(Paths.Preprocessed, 'Cutting', 'New_Cuts', Task);
    Destination = fullfile(Paths.Data, 'EEG', ['Unlocked_' Tag], Task); % TODO: put in 'Unlocked'
    
    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end
    
    Files = deblank(cellstr(ls(Source)));
    Files(~contains(Files, '.set')) = [];
    
    for Indx_F = 1:numel(Files)
        
        File = Files{Indx_F};
        Filename_Core = extractBefore(File, '_Clean.set');
        Filename = [Filename_Core, '_Welch.mat'];
        Filename_Figure = [Filename_Core, '_Welch.jpg'];
        
        % skip if already done
        if ~Refresh && exist(fullfile(Destination, Filename), 'file')
            disp(['**************already did ',Filename, '*************'])
            continue
        end
        
        % load EEG
        EEG = pop_loadset('filename', File, 'filepath', Source);
        
        
        
        %%% Set as nan all noise
        
        % remove nonEEG channels
        [TotCh, Points] = size(EEG.data);
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
        
        % remove all data marked as noise or nan
        Cuts_Filepath = fullfile(Source_Cuts, [Filename_Core, '_Cuts.mat']);
        
        EEG = rmNoise(EEG, Cuts_Filepath);
        
        % if only want a certain amount of data, cut
        if ~isempty(Duration)
            if Duration*60*fs >= size(EEG.data, 2)
                warning([EEG.filename, ' has only ', num2str(round(size(EEG.data, 2)/fs)/60), ' minutes'])
            else
                EEG = pop_select(EEG, 'time', [0 Duration*60]);
            end
        end
        
        
        %%% get power
        nfft = 2^nextpow2(WelchWindow*fs);
        noverlap = round(nfft*.75);
        window = hanning(nfft);
        [Power, Freqs] = pwelch(EEG.data', window, noverlap, nfft, fs);
        Power = Power';
        Freqs = Freqs';
        
        % plot it
        PlotSummaryPower(Power, Freqs, Chanlocs, Bands, Channels, replace(Filename_Core, '_', ' '), Format)
        
        
        % save
        save(fullfile(Destination, Filename), 'Power', 'Freqs', 'Chanlocs')
        saveas(gcf,fullfile(Destination, Filename_Figure))
        close
        disp(['*************finished ',Filename '*************'])
    end
    
end