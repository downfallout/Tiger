function ConvertMUAlarm(fileName)
    fid = fopen(fileName);
    dat = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f', [11 inf]);
    fclose('all');
    
    fid = fopen([fileName(1:end-3) 'alm'], 'w');
    for i=1:size(dat,2)
        fprintf(fid,'%d,%f,%f,%f\n', i, dat(10,i), dat(9,i), dat(11,i));
    end
    
    fclose(fid);