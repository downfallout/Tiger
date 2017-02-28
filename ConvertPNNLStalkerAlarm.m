function ConvertPNNLStalkerAlarm(fileName)
    fid = fopen(fileName);
    line = fgets(fid);
    i=0;
    while(ischar(line))
        line = line(5:end);
        i=i+1;
        dat(:,i) = sscanf(line, '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f', [10 inf]);
        line = fgets(fid);
    end
    fclose(fid);
    
    fid = fopen([fileName(1:end-3) 'alm'], 'w');
    for i=1:size(dat,2)
        fprintf(fid,'%d,%f,%f,%f\n', i, dat(7,i), dat(6,i), dat(10,i));
    end
    
    fclose(fid);