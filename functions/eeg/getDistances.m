function M = getDistances(X, Y, Z)
% distances between electrodes

M = nan(numel(X));

for Indx_Ch1 = 1:numel(X)
    for Indx_Ch2 = 1:numel(X)
        M(Indx_Ch1, Indx_Ch2) = sqrt((X(Indx_Ch2)-X(Indx_Ch1))^2 +...
            (Y(Indx_Ch2)-Y(Indx_Ch1))^2 + (Z(Indx_Ch2)-Z(Indx_Ch1))^2);
    end
end

