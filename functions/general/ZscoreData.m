function Data = ZscoreData(Data, Dimentions)
% z-scores a matrix across the first dimention (presumed participant) and
% seperately for the last dimention (presumed frequency), if option
% selected.
% 'last' indicates that last dimention is also to be kept separate

Dims = ndims(Data); % probs wrong

switch Dimentions
    case 'last-1'
        for Indx_P = 1:size(Data, 1)
            for Indx_L = 1:size(Data, Dims-1)
                switch Dims % TODO: figure a more general way to do this
                    case 3
                        Row = Data(Indx_P,Indx_L, :);
                        Mean = nanmean(Row(:));
                        Std = nanstd(Row(:));
                        Data(Indx_P, Indx_L, :) = (Row-Mean)./Std;
                    case 4
                        Row = Data(Indx_P,:, Indx_L, :);
                        Mean = nanmean(Row(:));
                        Std = nanstd(Row(:));
                        Data(Indx_P, :, Indx_L, :) = (Row-Mean)./Std;
                    case 5
                        Row = Data(Indx_P,:, :, Indx_L, :);
                        Mean = nanmean(Row(:));
                        Std = nanstd(Row(:));
                        Data(Indx_P, :, :, Indx_L, :) = (Row-Mean)./Std;
                        
                    case 6
                        Row = Data(Indx_P,:, :, :, Indx_L, :);
                        Mean = nanmean(Row(:));
                        Std = nanstd(Row(:));
                        Data(Indx_P, :, :, :, Indx_L, :) = (Row-Mean)./Std;
                    otherwise
                        error('dimention not known')
                end
            end
        end
    otherwise
        % TODO
end