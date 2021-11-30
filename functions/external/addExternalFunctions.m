% adds all the paths to all the external functions I use. Probably a
% sub-optimal solution, but dealing with submodules is a bitch.

Path = mfilename('fullpath');
Path = extractBefore(Path, 'addExternalFunctions');

SubFolders = getContent(Path);
SubFolders(contains(SubFolders, '.')) = [];

for Indx_F = 1:numel(SubFolders)
    
   addpath(fullfile(Path, SubFolders(Indx_F))) 
end