function Time = str2time(String)
% 'HH:mm'

String =  str2double(split(String, ':'));
Time = String(:, 1) + String(:, 2)/60; 