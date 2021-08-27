function NewLims = setLimsTiles(Tot, Axis)
% function to set all tiles to the same values

Lims = nan(Tot, 2);

for Indx_Sp = 1:Tot
   nexttile(Indx_Sp)

    switch Axis
        case 'y'
            Lims(Indx_Sp, :) = ylim;
        case 'x'
            Lims(Indx_Sp, :) = xlim;
        case 'c'
            Lims(Indx_Sp, :) = caxis;
    end
end

NewLims = [min(Lims(:, 1)), max(Lims(:, 2))];
Range = diff(NewLims);
Padding =  Range*.05;
NewLims = [NewLims(1)-Padding, NewLims(2)+Padding];


for Indx_Sp = 1:Tot
 nexttile(Indx_Sp)
    hold on
    switch Axis
        case 'y'
            ylim(NewLims)
        case 'x'
            xlim(NewLims)
        case 'c'
            caxis(NewLims)
    end
    
end