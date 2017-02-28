function ALM2ALB(fileName)
    alarmData = ReadAlm(fileName);
    
    data = [alarmData{2} alarmData{3} alarmData{4}]';
    data = data(:);
    
    fid = fopen([fileName(1:end-3) 'alb'], 'wb');
    
    fwrite(fid, data, 'float64');
    
    fclose(fid);