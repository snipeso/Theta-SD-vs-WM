function bubbleTopo(Color, Chanlocs, Size, Type, Labels, Format)
% plots topoplot as a circle per channel.


TextColor = [.75 .75 .75];
switch Type
    case '2D'
        Theta =[Chanlocs.theta];
        Radius = [Chanlocs.radius];
        
        Theta = -pi/180*(Theta-90);
        
        
        [x, y] = pol2cart(Theta, Radius);
        
        scatter(x, y, Size, Color, 'filled')
        if Labels
            hold on
            textscatter(x, y, {Chanlocs.labels}, 'ColorData', TextColor, 'FontName', Format.FontName)
        end
        axis square
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