function Folder = getContent(Folder)
% little function for getting whatever is inside a folder, ignoring the
% stupid dots and turning everything into a string

Folder = deblank(string(ls(Folder)));

Folder(strcmp(Folder, ".")) = [];
Folder(strcmp(Folder, "..")) = [];