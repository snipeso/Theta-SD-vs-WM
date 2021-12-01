clear
clc
close all

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Format = P.Format;


Filename = 'P10_LAT_BaselineComp_Clean.set';

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

Pix = get(0,'screensize');

eegplot(EEG.data,'spacing', 20, 'srate', EEG.srate, ...
    'winlength', 20, 'position', [0 0 Pix(3) Pix(4)*.97], 'eloc_file', ...
    EEG.chanlocs)



%%
Start = 47; Ch = 69; Title = PlotBurst(EEG, Start, Start+5, Ch, Bands, Format);


%   saveFig([TitleTag, '_', Title], Results, Format)


%% Plots used in paper 1

