function Colors = getColors(N, Order, Color)
% Selects from colorblind friendly pallettes the requested colors.
% N can be either 1 or 2 values; the first indicates the number of hues,
% the second the number of luminance changes. if no second value is
% indicated, than a N x RGB matrix is returned. Otherwise, an N(2) x RGB x
% N(3) matrix is returned, such that hue varies on the third dimention.
% if Color (a string of one of the colors) is specified, then it will just
% use that one color, and give a set of shades based on N (single number).

% base colors
AllColors.red = [208, 78, 60];
AllColors.orange = [231, 138, 52];
AllColors.yellow = [215, 175, 62];
AllColors.green = [126, 184, 117];
AllColors.olive = [181, 191, 109];
AllColors.teal = [87, 162, 172];
AllColors.blue = [78, 121, 196];
AllColors.purple = [130, 77, 153];

if exist('Color', 'var')
    N = [1, N(end)];
    AllColors.blue = AllColors.(Color); % little hack
end

% select as different colors as possible based on N
switch N(1)
    case 1
        MainColors = AllColors.blue;
    case 2
        MainColors = [AllColors.blue; AllColors.yellow];
    case 3
        MainColors = [AllColors.blue; AllColors.yellow; AllColors.red];
    case 4
        MainColors = [AllColors.blue; AllColors.yellow;
            AllColors.red; AllColors.green];
    case 5
        MainColors = [AllColors.blue; AllColors.yellow;
            AllColors.red; AllColors.green; AllColors.purple];
    case 6
        MainColors = [AllColors.blue; AllColors.yellow;  AllColors.red;
            AllColors.green; AllColors.purple; AllColors.orange];
    case 7
        MainColors = [AllColors.blue; AllColors.yellow;  AllColors.red;
            AllColors.green; AllColors.purple; AllColors.orange;
            AllColors.teal];
    case 8
        MainColors = [AllColors.blue; AllColors.yellow;  AllColors.red;
            AllColors.green; AllColors.purple; AllColors.orange;
            AllColors.teal; AllColors.olive];
    otherwise
        error('too many colors')
end

% change order of colors if requested
if exist('Order', 'var')
    switch Order
        case 'rainbow'
            FullOrder = [7 3 1 5 8 2 6 4]; % maximum final order
            [~, Order] = sort(FullOrder(1:N(1)), 'ascend'); % order for subset
            MainColors = MainColors(Order, :);
    end
end

% convert to values 0 to 1
MainColors = MainColors/255;

% vary luminance
if numel(N) == 1
    Colors = MainColors;
elseif numel(N) == 2
    Lum = [
        150, nan, nan, nan, nan;
        125, 175, nan, nan, nan;
        100, 150, 200, nan, nan;
        75, 125, 175, 225, nan;
        40, 100, 150, 200, 240;
        ]; % all the possible luminance jumps to make sure that they're nice when few
    
    if N(2) <= 5
        Lum = Lum(N(2), :);
        Lum(isnan(Lum)) = [];
    else
        Lum = linspace(40, 240, N(2));
    end
    
    Lum = Lum/255;
    
    hsl_Colors =rgb2hsl(MainColors);
    all_hsl_Colors = repmat(hsl_Colors, 1, 1, N(2));
    all_hsl_Colors(:, 3, :) =  repmat(Lum, N(1), 1);
    if N(1) == 1
        all_hsl_Colors = permute(all_hsl_Colors, [3, 2, 1]);
        Colors = hsl2rgb(all_hsl_Colors);
    else
        all_hsl_Colors = permute(all_hsl_Colors, [1, 3, 2]);
        Colors = hsl2rgb(all_hsl_Colors);
        Colors = permute(Colors, [2, 3, 1]);
    end
else
    error('Not correct N')
end