function NewLims = setLims(Dim1, Dim2, Axis)
% function to set all subplots to the same values

Tot = Dim1*Dim2;

Lims = nan(Tot, 2);

for Indx_Sp = 1:Tot
    subplot(Dim1, Dim2, Indx_Sp)
    hold on
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


for Indx_Sp = 1:Tot
    subplot(Dim1, Dim2, Indx_Sp)
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