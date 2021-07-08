function NewLims = SetLims(Dim1, Dim2, Axis)
% function to set all subplots to the same values

Tot = Dim1*Dim2;

Lims = nan(Tot, 2);

for Indx_Sp = 1:Tot
    subplot(Dim1, Dim2, Indx_Sp)
    if strcmpi(Axis, 'y')
        Lims(Indx_Sp, :) = ylim;
    elseif strcmpi(Axis, 'x')
        Lims(Indx_Sp, :) = xlim;
    end
end


NewLims = [min(Lims(:, 1)), max(Lims(:, 2))];


for Indx_Sp = 1:Tot
    subplot(Dim1, Dim2, Indx_Sp)
    
    if strcmpi(Axis, 'y')
        ylim(NewLims)
    elseif strcmpi(Axis, 'x')
        xlim(NewLims)
    end
end