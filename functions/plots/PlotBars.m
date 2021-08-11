function Stats = PlotBars(Data, xLabels, Colors, Format, Orientation, Stats)
% Matrix is a P x whatever matrix. This plots the averages across the
% whatever dimention, and SEM error bars if requested. 

% See PlotBars2 of original scripts to get inspiration on other dimentions

Dims = size(Data);

if any(Dims==1)
    nDims = numel(Dims)-1;
else
    nDims = numel(Dims);
end

switch nDims
    case 2 % e.g. P x S
        if exist('Stats', 'var') && Stats
            
            % get standard mean error for error bars
            SEM = nanstd(Data)/sqrt(Dims(1));
            
            % plot bars
           drawBars(nanmean(Data)', xLabels, Colors, Format, Orientation, [SEM', SEM'])
           
           % plot pairwise comparison of bars
         Stats = Pairwise(Data, true);
         plotPairwiseStars(Stats, 1:Dims(2), Format.Colors.SigStar)

           
        end
        
        
    otherwise
        disp('dont know what to do with these dimentions')
end



set(gca, 'FontSize', 15)