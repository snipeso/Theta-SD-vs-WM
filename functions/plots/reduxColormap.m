function NewColormap = reduxColormap(Colormap, N)
% itty bitty code to reduce a colormap to the desired number of levels

Keep = round(linspace(1, size(Colormap, 1), N));
NewColormap = Colormap(Keep, :);