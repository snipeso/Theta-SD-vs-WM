% script for splitting apart the EEG of the RRTs, which are saved in the
% same file, divided only by triggers.

clear
clc
close all

Prep_Parameters
Refresh = false;
Padding = 5; % time around the events to keep in cut

StartFixCode = 'S 12';
EndFixCode = 'S 13';
StartStandCode = 'S 14';
EndStandCode = 'S 15';

% get list of folders for RRTs
Folders.RRT = cellstr(ls(fullfile(Paths.Datasets, Folders.Template, 'Fixation')));
Folders.RRT(contains(Folders.RRT, '.')) = [];

load('StandardChanlocs128.mat', 'StandardChanlocs') % has channel locations in StandardChanlocs


for Indx_D = 1:size(Folders.Datasets, 1) % loop through participants
    
    for Indx_F = 1:numel(Folders.RRT)
        Paths_Fixation = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, ...
            'Fixation', Folders.RRT{Indx_F}, 'EEG');
        Paths_Standing =  fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, ...
            'Standing', Folders.RRT{Indx_F}, 'EEG');
        Paths_Oddball =  fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, ...
            'Oddball', Folders.RRT{Indx_F}, 'EEG');
        Paths_QuestionnaireEEG = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, ...
            'QuestionnaireEEG', Folders.RRT{Indx_F}, 'EEG');
        
        if ~exist(Paths_QuestionnaireEEG, 'dir')
            mkdir(Paths_QuestionnaireEEG)
        end
        
        
        % skip rest if folder not found
        if ~exist(Paths_Fixation, 'dir')
            warning([deblank(Paths_Fixation), ' does not exist'])
            continue
        end
        
        % if does not contain EEG, then skip
        if ~CheckSet(Paths_Fixation)
            continue
        end
        
        Content = ls(Paths_Fixation);
        SET = contains(string(Content), '.set');
        Filename.SET = Content(SET, :);
        
        % if not going to refresh and file already split, skip
        if ~Refresh && CheckSet(Paths_Standing) && CheckSet(Paths_Oddball) ...
                && CheckSet(Paths_QuestionnaireEEG)
            disp(['****** Skipping ', Filename.SET, ' *******'])
            continue
        end
        
        % load EEG
        Content = ls(Paths_Fixation);
        VHDR = contains(string(Content), '.vhdr');
        if ~any(VHDR)
            if any(strcmpi(Levels, 'EEG'))
                warning([Path, ' is missing EEG files'])
            end
            continue
        elseif nnz(VHDR) > 1 % or if there's more than 1 file
            warning([Path, ' has more than one eeg file'])
            continue
        end
        Filename.VHDR = Content(VHDR, :);
        EEG = pop_loadbv(Paths_Fixation, Filename.VHDR);
        
        % update EEG structure
        EEG.ref = 'CZ';
        EEG.chanlocs = StandardChanlocs;
        EEG.info.oldname = Filename.VHDR;
        EEG.info.oldpath = Paths_Fixation;
        
        % get start fixation
        allEvents = {EEG.event.type};
        StartFixEvent = EEG.event(strcmpi(allEvents, StartFixCode));
        StartFix = StartFixEvent.latency - EEG.srate*Padding;
        if StartFix < 1; StartFix = 1; end
        
        % get end fixation
        EndFixEvent = EEG.event(strcmpi(allEvents, EndFixCode));
        EndFix = EndFixEvent.latency  + EEG.srate*Padding;
        
        % cut
        EEGfix = pop_select(EEG, 'point', [StartFix, EndFix]);
        
        % save
        pop_saveset(EEGfix, 'filename', Filename.SET, ...
            'filepath', Paths_Fixation, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        
        % get start standing
        StartStandIndx = find(strcmpi(allEvents, StartStandCode));
        StartStandEvent = EEG.event(StartStandIndx);
        StartStand = StartStandEvent.latency  - EEG.srate*Padding;
        
        % get end standing
        EndStandEvent = EEG.event(strcmpi(allEvents, EndStandCode));
        
        if isempty(EndStandEvent)
            EndStand = EEG.pnts;
        else
            EndStand = EndStandEvent.latency  + EEG.srate*Padding;
            if EndStand > EEG.pnts; EndStand = EEG.pnts; end
        end
        
        
        % cut
        EEGStand = pop_select(EEG, 'point', [StartStand, EndStand]);
        
        % save
        pop_saveset(EEGStand, 'filename', ['Stand_', Filename.SET], ...
            'filepath', Paths_Standing, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        
        % get start oddball
        StartOddball = EndFixEvent.latency - EEG.srate*Padding;
        
        % get end oddball
        EndOddballIndx = StartStandIndx - 1;
        EndOddballEvent = EEG.event(EndOddballIndx);
        EndOddball = EndOddballEvent.latency + EEG.srate*Padding;
        if EndOddball > EEG.pnts; EndOddball = EEG.pnts; end
        
        % cut
        EEGOddball = pop_select(EEG, 'point', [StartOddball, EndOddball]);
        
        % save
        pop_saveset(EEGOddball, 'filename', ['Oddball_', Filename.SET], ...
            'filepath', Paths_Oddball, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
        
        StartQ = EndOddball + EEG.srate*Padding;
        EndQ = StartStand -  EEG.srate*Padding;
        
        % cut
        EEGQ = pop_select(EEG, 'point', [StartQ, EndQ]);
        
        % save
        pop_saveset(EEGQ, 'filename', ['Questionnaire_', Filename.SET], ...
            'filepath', Paths_QuestionnaireEEG, ...
            'check', 'on', ...
            'savemode', 'onefile', ...
            'version', '7.3');
    end
end


function IsPresent = CheckSet(Path)
% checks if there is a set file in the folder

IsPresent = false;
Content = ls(Path);
SET = contains(string(Content), '.set');

if ~any(SET)
    warning([Path, ' is missing EEG files'])
elseif nnz(SET) > 1
    warning([Path, ' has more than one eeg file'])
else
    IsPresent = true;
end
end