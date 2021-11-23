function bubbleTopo(Color, Chanlocs, Size, Type, Labels, Format)
% plots topoplot as a circle per channel.
% if labels, mark label indexes


TextColor = [.75 .75 .75];
switch Type
    case '2D'
        Theta =[Chanlocs.theta];
        Radius = [Chanlocs.radius];
        
        Theta = -pi/180*(Theta-90);
        
        
        [x, y] = pol2cart(Theta, Radius);
        
        scatter(x, y, Size, Color, 'filled')
        if ~isempty(Labels)
            hold on
            if numel(Labels) == numel(Chanlocs)
                  textscatter(x, y, Labels, 'ColorData', TextColor, 'FontName', Format.FontName, 'TextDensityPercentage', 100)
            else
                
                textscatter(x, y, {Chanlocs.labels}, 'ColorData', TextColor, 'FontName', Format.FontName)
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
        scatter3(X, Y, Z, Size, Color, 'filled')
        
        if Labels
            hold on
            textscatter3(X, Y, Z, {Chanlocs.labels}, 'ColorData', TextColor, 'FontName', Format.FontName)
        end
        view(0, 90)
        axis vis3d
        set(gca,'DataAspectRatio',[1 1 1.2])
end

set(gca, 'visible', 'off', 'FontName', Format.FontName)
title('')

set(findall(gca, 'type', 'text'), 'visible', 'on')

Dims = size(Color);

if Dims(2) ~=3 % if not a color triplet
    Colormap = Format.Colormap.Linear;
    Colormap = reduxColormap(Colormap, Format.Steps.Linear);
    colormap(Colormap)
    colorbar
end