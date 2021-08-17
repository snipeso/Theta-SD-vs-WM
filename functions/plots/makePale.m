function Color = makePale(Color, Prcnt)
% make color as pale as indicated in Prcnt. If color is 1 x 3, then it
% makes as many pale colors as indicated in Prcnt. If color is n x 3, Prcnt
% can either be n x 1 or 1 value.

DimsC = size(Color);
DimsP = size(Prcnt);

% make both matrices have the same number of rows
if DimsC(1) == 1
    Color = repmat(Color, DimsP(1), 1);
end

if DimsP(1) == 1
   Prcnt = repmat(Prcnt, DimsC(1), 1); 
end

Color = rgb2hsv(Color);

Color(:, 2) = Color(:, 2).*Prcnt; % reduce the saturation
Color(:, 3) = (1-Color(:, 3)).*(1-Prcnt) + Color(:, 3); % increase the value


Color = hsv2rgb(Color);