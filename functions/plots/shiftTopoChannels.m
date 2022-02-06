function Chanlocs = shiftTopoChannels(Chanlocs, Shift, Axis)
% shifts locations of electrodes to improve topoplot symmetry.
% Chanlocs is EEGLAB structure of channel locations
% shift is how much to move it by. The original axes are approximately -0.5
% to 0.5.
% Axis is either x or y.

Theta =[Chanlocs.theta];
Radius = [Chanlocs.radius];

Theta = -pi/180*(Theta-90);

[x, y] = pol2cart(Theta, Radius);

switch Axis
    case 'y'
        y = y+Shift;
        
    case 'x'
        x = x+Shift;
end

[Theta, Radius] = cart2pol(x, y);
Theta = (Theta*180/(-pi)) + 90;


for Indx_Ch = 1:numel(Chanlocs)
    Chanlocs(Indx_Ch).theta = Theta(Indx_Ch);
    Chanlocs(Indx_Ch).radius = Radius(Indx_Ch);
end
