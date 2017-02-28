function ConvertMUHBADSAlarm(fileName)
    fid = fopen(fileName);
    dat = fscanf(fid, '%f,%f,%f,%f', [4 inf]);
    fclose('all');
    
    fid = fopen([fileName(1:end-3) 'alm'], 'w');
    for i=1:size(dat,2)
        fprintf(fid,'%d,%f,%f,%f\n', i, dat(3,i), dat(2,i), dat(4,i));
    end
    
    fclose(fid);