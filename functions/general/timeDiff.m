function Hours = timeDiff(Start, End)
% gives in hours the time difference

if iscell(Start)
    Start = str2time(Start);
    End = str2time(End);
end

Hours = End-Start;
Sign = sign(Hours);

% positive times
Pos = Sign == 1;
Hours(Pos) = mod(Hours(Pos), 24);

% negative times
Neg = Sign == -1;
Hours(Neg) = -mod(abs(Hours(Neg)), 24);