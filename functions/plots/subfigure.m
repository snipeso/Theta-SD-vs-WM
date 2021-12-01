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

% if no space provided, use whole figure
set(gcf, 'units', 'pixels')
FigSpace = get(gcf, 'position');

PaddingExterior = Format.Pixels.PaddingExterior;

if isempty(Space)
    Space = FigSpace;
end


% Check if Space is full figure or not; if not, use minor padding
if all(Space == FigSpace)
    Padding = Format.Pixels.Padding;
else
    Padding = Format.Pixels.PaddingMinor;
    
    % TODO: shift of Space?
end

% get grid dividers
X = linspace(PaddingExterior, Space(3)-PaddingExterior, Grid(2)+1);
Y = flip(linspace(PaddingExterior, Space(4)-PaddingExterior, Grid(1)+1));

% get axes size
axisWidth = ((Space(3)-PaddingExterior*2)/Grid(2));
axisHeight = ((Space(4)-PaddingExterior*2)/Grid(1));

% get position
Left = X(CornerLocation(2))+Padding;
Bottom = Y(1+CornerLocation(1))+Padding;
Width = axisWidth*Size(2)-Padding*2;
Height = axisHeight*Size(1)-Padding*2;

% set up axes
Position = [Left, Bottom, Width, Height];



%%% Real script
Axes = axes('Units', 'pixels', 'Position', Position);

if ~isempty(Letter)
    Txt = annotation('textbox', [0 0 0 0], 'string', Letter, 'Units', 'pixels', ...
        'FontSize',Format.Pixels.LetterSize, 'FontName', Format.FontName, 'FontWeight', 'Bold');
    Txt.Position =  [X(CornerLocation(2))-Format.Pixels.LetterSize, Y(CornerLocation(1))+Format.Pixels.LetterSize+Padding/2 0 0];
end

