function CatConvertMUAlarm(fileName1, fileName2, fileNameOut)
    fid = fopen(fileName1);
    dat1 = fscanf(fid, '%f %f %f %f', [4 inf]);
    fclose('all');
    
    fid = fopen(fileName2);
    dat2 = fscanf(fid, '%f %f %f %f', [4 inf]);
    fclose('all');
    
    dat = [dat1 dat2];
    fid = fopen(fileNameOut, 'w');
    for i=1:size(dat,2)
        fprintf(fid,'%d,%f,%f,%f\n', i, dat(3,i), dat(2,i), dat(4,i));
    end
    
    fclose(fid);