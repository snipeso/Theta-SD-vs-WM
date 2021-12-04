function shiftaxis(Axis, X, Y)
% little script for shifting axes to adjust for weird figures.
% X and Y are in pixels, and the new axes will be centered in the same
% spot, but now larger.

Axis.Units = 'pixels';

if ~isempty(X)
    Axis.Position(1) = Axis.Position(1)-X;
    Axis.Position(3) =  Axis.Position(3) + X*2;
end

if ~isempty(Y)
    Axis.Position(2) = Axis.Position(2)-Y;
    Axis.Position(4) =  Axis.Position(4) + Y*2;
end

Axis.Units = 'normalized';