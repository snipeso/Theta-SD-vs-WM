% example data used in paper

clear
clc
close all

P = analysisParameters();

Paths = P.Paths;
Bands = P.Bands;
Format = P.Format;
Pixels = P.Pixels;

Path = 'F:\Data\Example';

% preselected snippets of data with good examples of theta bursts
Coordinates = {
    'EO.set', 308.3, 22, Format.Colors.Tasks.PVT, 'Beta';
    'EC2.set', 324, 90,  Format.Colors.Tasks.Match2Sample, 'Alpha';
    'fmTheta.set', 581.3, 6,  Format.Colors.Tasks.Music, 'Theta';
    'N3_clean.set', 343.15, 11, Format.Colors.Tasks.Game, 'Delta';
    };

Results = fullfile(Paths.Results, 'Bursts', 'Presentation');
if ~exist(Results, 'dir')
    mkdir(Results)
end

% load all EEGs
for Indx_E = 1:size(Coordinates, 1)
    
    Filename = Coordinates{Indx_E, 1};
    EEG = pop_loadset('filename', Filename, 'filepath', Path);
    try
    AllEEG(Indx_E) = EEG;
    catch
         AllEEG(Indx_E).data = EEG.data;
          AllEEG(Indx_E).chanlocs = EEG.chanlocs;
            AllEEG(Indx_E).srate = EEG.srate;
    end
end



%%
YLims = [-160 110];

for Indx_B = 1:size(Coordinates, 1)
Fig = figure('units','centimeters','position',[0 0 30 10]);

Start = Coordinates{Indx_B, 2};
plotWaves(AllEEG(Indx_B), Start, Start+2, Coordinates{Indx_B, 3}, ...
    Coordinates{Indx_B, 4}, Format); 
ylim(YLims)

saveFig(Coordinates{Indx_B, end}, Results, Format)

end

%%