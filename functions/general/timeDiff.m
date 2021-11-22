function Hours = timeDiff(Start, End)
% gives in hours the time difference

if iscell(Start)
    Start = str2time(Start);
    End = str2time(End);
end

Hours = mod(End-Start, 24);