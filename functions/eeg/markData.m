function markData(EEG)
% uses EEGLAB "scroll" interface to view data to cut. Highlight areas
% indicate whole time blocks to remove, and red segments in single channels
% indicate snippets to interpolate. Red channels indicate channels to
% remove.

close all

CURRENTSET = 1;
ALLEEG(1) = EEG;

m = matfile(EEG.CutFilepath,'Writable',true);

% make color vector
StandardColor = {[0.19608  0.19608  0.51765]};
Colors = repmat(StandardColor, size(EEG.data, 1), 1);

Content = who(m);

if ismember('badchans', Content)
    Colors(m.badchans) = {[1, 0, 0]};
end
    
if ismember('cutData', Content)
    Data2 = m.cutData;
else
    Data2 = [];
end

Pix = get(0,'screensize');

if ismember('TMPREJ', Content)
    eegplot(EEG.data, 'srate', EEG.srate, 'spacing', 30, 'winlength', 60, ...
    'command', 'm.TMPREJ = TMPREJ', 'color', Colors, 'butlabel', 'Save', ...
    'winrej', m.TMPREJ, 'data2', Data2, 'position', [0 0 Pix(3) Pix(4)])
else
    eegplot(EEG.data, 'srate', EEG.srate, 'spacing', 30, 'winlength', 60, ...
        'command', 'm.TMPREJ = TMPREJ', 'color', Colors, 'butlabel', 'Save', 'data2', Data2, 'position', [0 0 Pix(3) Pix(4)])
end

