function alarmData = ReadAlb(fileName)
    
    fid = fopen(fileName,'rb');
    
    if(fid > -1)
        alarmData = fread(fid, 'float64');
        fclose(fid);
        alarmData = reshape(alarmData,3,[])';
        alarmData = {(1:size(alarmData,1))', alarmData(:,1), alarmData(:,2), alarmData(:,3)};
    else
        alarmData =[];
    end