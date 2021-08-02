function plotPairwise(Data, xValues, Colors, Corrected)
% plots the significant stars for data

Dims = size(Data);

if any(Dims==1)
    nDims = numel(Dims)-1;
else
    nDims = numel(Dims);
end

switch nDims
    case 2 % e.g. P x S
        
        [pValues, ~, ~, ~] = Pairwise(Data, Corrected);
        
        if isempty(xValues)
            xValues = 1:Dims(2);
        end
        
        Pairs = {};
        
        for Indx1 = 1:Dims(2)-1
            for Indx2 = 2:Dims(2)
                
                if exist('Colors', 'var') && ~isempty(Colors)
                    Color = Colors(Indx1, :);
                else
                    Color = 'k';
                end
                
                newPair = {xValues([Indx1, Indx2]), pValues(Indx1, Indx2), Color};
                Pairs = cat(1, Pairs, newPair);
            end
        end
        
        % remove all non-trending comparisons
        Pairs( [Pairs{:, 2}]>= .1 | isnan([Pairs{:, 2}]), :) = [];
        
        
        if any( [Pairs{:, 2}])
            sigstar(Pairs(:, 1), [Pairs{:, 2}], Pairs(:, 3))
        end
        
    otherwise
        disp('dont know what to do with these dimentions')
end