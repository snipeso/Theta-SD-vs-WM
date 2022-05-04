function bubbleTopo(Data, Chanlocs, Size, Type, Labels, Format)
% plots topoplot as a circle per channel.
% if labels, mark label indexes


TextColor = [.75 .75 .75];
switch Type
    case '2D'

        Theta =[Chanlocs.theta];
        Radius = [Chanlocs.radius];
        
        Theta = -pi/180*(Theta-90);
        
        
        [x, y] = pol2cart(Theta, Radius);
        
        scatter(x, y, Size, Data, 'filled')
        if ~isempty(Labels)
            hold on
            if numel(Labels) == numel(Chanlocs)
                  textscatter(x, y, Labels, 'ColorData', TextColor, 'FontName', Format.Text.FontName, 'TextDensityPercentage', 100)
            else
                
                textscatter(x, y, {Chanlocs.labels}, 'ColorData', TextColor, 'FontName', Format.Text.FontName)
            end
        end
        axis square
        xlim([min(x) max(x)])
        ylim([min(y) max(y)])
        padAxis('x')
        padAxis('y')
    case '3D'
        X = [Chanlocs.X];
        Y = [Chanlocs.Y];
        Z = [Chanlocs.Z];
        scatter3(X, Y, Z, Size, Data, 'filled')
        
        if  ~isempty(Labels)
            hold on
            textscatter3(X, Y, Z, {Chanlocs.labels}, 'ColorData', TextColor, 'FontName', Format.Text.FontName)
        end
        view(0, 90)
        axis vis3d
        set(gca,'DataAspectRatio',[1 1 1.2])
end

set(gca, 'visible', 'off', 'FontName', Format.Text.FontName, 'FontSize', Format.Text.AxisSize)
title('')

set(findall(gca, 'type', 'text'), 'visible', 'on')

Dims = size(Data);

if Dims(2) ~=3 % if not a color triplet
    Colormap = Format.Colormap.Linear;
    Colormap = reduxColormap(Colormap, Format.Steps.Linear);
    colormap(Colormap)
    colorbar
end