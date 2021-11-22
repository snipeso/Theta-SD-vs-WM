function String = time2str(Time)

H = floor(Time);
mm = Time-H;

String = [num2str(H), ':', num2str(mm*60)];