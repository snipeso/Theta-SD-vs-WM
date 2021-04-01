Folder = 'D:\LSM\Data\Preprocessed\Cutting\Old_Cuts\TV';

Files = string(ls(Folder));

for Indx_F = 1:numel(Files)
    F =  Files{Indx_F};
    F_New = replace(F, '_Cleaning_Cuts', '_Cuts');
    if strcmp(F, F_New)
        continue
    end
    movefile(fullfile(Folder,F), fullfile(Folder, F_New))
end