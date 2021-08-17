function padAxis(Axis)

switch Axis
    case 'x'
        Lims = xlim;
    case 'y'
        Lims = ylim;
    case 'c'
        Lims = caxis;
end

Range = diff(Lims);

Padding = Range*.05;
NewLims = [Lims(1)-Padding, Lims(2)+Padding];


switch Axis
    case 'x'
        xlim(NewLims)
    case 'y'
        ylim(NewLims)
    case 'c'
        caxis(NewLims)
end

