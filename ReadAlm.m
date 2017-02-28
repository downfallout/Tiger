function alarmData = ReadAlm(fileName)
    fid = fopen(fileName);
    line = fgets(fid);
    count = 0;
    while(line(1) == '/' && line(2) == '/')
        count = count + 1;
        line = fgets(fid);
    end

    fseek(fid,0,'bof');
    for i=1:count
        fgets(fid);
    end
    alarmData = textscan(fid, '%d,%f,%f,%f');
    
    if(isempty(alarmData{4}(:)))
        fseek(fid,0,'bof');
        for i=1:count
            fgets(fid);
        end
        alarmData = textscan(fid, '%d %f %f %f');
    end

    fclose(fid);