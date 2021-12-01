function Axes = subfigure(Space, Grid, CornerLocation, Size, Letter, Format)
%  subfigure(Space, Grid, Location, Letter, Format)
% Instead of subplot, this lets you place a subfigure anywhere on the
% figure (could be overlap if you're not careful).
% Space is a [left bottom width height] matrix outlining the space within
% to make a grid and place the plot. If empty, uses figure
% Grid indicates the size of the parcel in which the axes should be
% plotted.
% CornerLocation indicates which parcel the bottom left corner of the axes
% should occupy. should be [r x c].
% Size is number of parcels [r x c].
% Letter is optional, and would make a big letter in the corner of the
% parcel.

% if making a sub-sub axes, run the following first:
% Axes = ... {the space you want to fill}
% Axes.Units = 'pixels';
% Space = Axes.Position;
% delete(Axes);
% then run each sub axes with Space filled



% if no space provided, use whole figure
set(gcf, 'units', 'pixels')
FigSpace = get(gcf, 'position');

PaddingLabels = Format.Pixels.PaddingLabels;

if isempty(Space)
    Space = FigSpace;
end


% Check if Space is full figure or not; if not, use minor padding
if all(Space == FigSpace)
    Padding = Format.Pixels.Padding;
    PaddingExterior = Format.Pixels.PaddingExterior;
    FontSize = Format.Pixels.LetterSize;
    
    % get grid dividers
    X = linspace(PaddingExterior, Space(3)-PaddingExterior, Grid(2)+1);
    Y = flip(linspace(PaddingExterior, Space(4)-PaddingExterior, Grid(1)+1));
    
else
    Padding = Format.Pixels.PaddingMinor;
    FontSize = Format.Pixels.LetterSize*2/3;
    PaddingExterior = 0;
    
    % get grid dividers
    X = linspace(Space(1), Space(1)+Space(3), Grid(2)+1);
    Y = flip(linspace(Space(2), Space(2)+Space(4), Grid(1)+1));
end


% get axes size
axisWidth = ((Space(3)-PaddingExterior*2)/Grid(2));
axisHeight = ((Space(4)-PaddingExterior*2)/Grid(1));

% get position
Left = X(CornerLocation(2))+Padding+PaddingLabels;
Bottom = Y(1+CornerLocation(1))+Padding+PaddingLabels;
Width = axisWidth*Size(2)-Padding*2-PaddingLabels;
Height = axisHeight*Size(1)-Padding*2-PaddingLabels;

% set up axes
Position = [Left, Bottom, Width, Height];

%%% Real script
Axes = axes('Units', 'pixels', 'Position', Position);

if ~isempty(Letter)
    Txt = annotation('textbox', [0 0 0 0], 'string', Letter, 'Units', 'pixels', ...
        'FontSize', FontSize, 'FontName', Format.FontName, 'FontWeight', 'Bold');
    Txt.Position =  [X(CornerLocation(2))-FontSize+Padding/2, Y(CornerLocation(1))+FontSize-Padding/2+PaddingLabels 0 0];
    Txt.Units = 'normalized';
end

% Axes.Units = 'normalized';
set(gca, 'Units', 'normalized')

