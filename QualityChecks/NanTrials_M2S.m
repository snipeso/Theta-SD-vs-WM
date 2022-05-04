Path = 'F:\Data\Preprocessed\SourceLocalization_Trials119\Match2Sample\Retention1';

Content = getContent(Path);
Levels = {'L1', 'L3', 'L6'};

for Indx_F = 1:numel(Content)
    C = Content{Indx_F};
    load(fullfile(Path, C))
    
    NanTrials = cellfun(@allNan, Data.trial);
    PrcentNan = cellfun(@prcntNan, Data.trial);
   
    T = tabulate(Data.trialinfo.level(NanTrials));
    
    
    disp([C, ' nan trials: ', num2str(nnz(NanTrials)), ...
        '; % nan: ', num2str(100*nanmean(PrcentNan), '%.f')])
   
    if ~isempty(T)
    disp(num2str(T(:, 2)'))
    end
    
end


function V = allNan(C)

V = any(isnan(C), 'all');

end

function P = prcntNan(C)

if allNan(C)
    P = nnz(any(isnan(C)))/size(C, 2);
else
    P = nan;
end

end
