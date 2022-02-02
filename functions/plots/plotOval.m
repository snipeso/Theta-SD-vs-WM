function plotOval(Focus1, Focus2, Eccentricity, ZeroAxis, Color, Alpha)
% plots an oval patch
% Focus one is [x y] coordinates
% eccentricity is a number between 0 and 1. The closer to 1, the more flat.
% this plots a 2-D oval, but can be in a 3D space, if you specify which
% axis is 0


x1 = Focus1(1);
x2 = Focus2(1);
y1 = Focus1(2);
y2 = Focus2(2);

a = 1/2*sqrt((x2-x1)^2+(y2-y1)^2);
b = a*sqrt(1-Eccentricity^2);
t = linspace(0,2*pi);
X = a*cos(t);
Y = b*sin(t);
w = atan2(y2-y1,x2-x1);
x = (x1+x2)/2 + X*cos(w) - Y*sin(w);
y = (y1+y2)/2 + X*sin(w) + Y*cos(w);

switch ZeroAxis
    case 'x'
        patch('Vertices', [zeros(numel(x), 1), x(:), y(:)], 'Faces', 1:numel(x), ...
            'FaceColor', Color, 'EdgeColor', 'none', 'FaceAlpha', Alpha)
        light
    otherwise
        patch(x,y, Color, 'FaceAlpha', Alpha, 'EdgeColor','none')
end