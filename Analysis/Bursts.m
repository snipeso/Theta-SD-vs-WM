clear
clc
close all
% 
P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Format = P.Format;


Filename = 'P12_LAT_Session2Comp_Clean.set';
% Filename = 'P01_Standing_BaselinePost_Clean.set';

Levels = split(Filename, '_');
Task = Levels{2};
Participant = Levels{1};
TitleTag = strjoin({'Burst', Participant, Task, Levels{3}}, '_');

Source = fullfile(Paths.Preprocessed, 'Clean', 'Power', Task);


Results = fullfile(Paths.Results, 'Bursts');
if ~exist(Results, 'dir')
    mkdir(Results)
end


EEG = pop_loadset('filename', Filename, 'filepath', Source);
% pop_eegplot(EEG2)

Pix = get(0,'screensize');
% 
eegplot(EEG.data,'spacing', 20, 'srate', EEG.srate, ...
    'winlength', 20, 'position', [0 0 Pix(3) Pix(4)*.97], 'eloc_file', ...
    EEG.chanlocs)



%%
Start = 47; Ch = 69; Title = PlotBurst(EEG, Start, Start+5, Ch, Bands, Format);


%   saveFig([TitleTag, '_', Title], Results, Format)


%% Plots used in paper 1

