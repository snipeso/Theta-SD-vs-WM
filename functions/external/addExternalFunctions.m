% adds all the paths to all the external functions I use. Probably a
% sub-optimal solution, but dealing with submodules is a bitch.

Path = mfilename('fullpath');
Path = extractBefore(Path, 'addExternalFunctions');

% add MES toolbox
% addpath(fullfile(Path, 'hhentschke-measures-of-effect-size-toolbox-3d90ae5'))
addpath(fullfile(Path, 'colormaps'))
