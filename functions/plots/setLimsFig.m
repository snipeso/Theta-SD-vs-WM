function setLimsFig(Handles, Axis, Divergent)
% sets the limit to the same number for all axes


Lims = nan(numel(Handles), 2);

for Indx_A = 1:numel(Handles)

    switch Axis
        case 'y'
            try
            Lims(Indx_A, :) = Handles(Indx_A).YLim;
            catch
                a=1
            end
        case 'x'
            Lims(Indx_A, :) = Handles(Indx_A).XLim;
        case 'c'
            Lims(Indx_A, :) =  Handles(Indx_A).CAxis; % TODO
    end
end


NewLims = [min(Lims(:, 1)), max(Lims(:, 2))];

if exist('Divergent', 'var') && Divergent
    Lim = max(abs(NewLims));
    NewLims = [-Lim, Lim];
end
Range = diff(NewLims);
Padding =  Range*.05;
NewLims = [NewLims(1)-Padding, NewLims(2)+Padding];


for Indx_A = 1:numel(Handles)
    switch Axis
        case 'y'
             Handles(Indx_A).YLim = NewLims;
        case 'x'
              Handles(Indx_A).XLim = NewLims;
        case 'c'
              Handles(Indx_A).CAxis = NewLims;
    end
end