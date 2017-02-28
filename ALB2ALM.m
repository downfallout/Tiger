function ALB2ALM(fileName)
    
    fid = fopen(fileName, 'rb');
    
    data = fread(fid, [3 inf], 'float64');
    
    fclose(fid);
    
%    data = [1:size(data,2) data];
    
    
    fid = fopen([fileName(1:end-3) 'alm'], 'wb');
    
    for i=1:size(data,2)
        fprintf(fid, '%d %.3f %.3f %.6f\n', i, data(1,i), data(2,i), data(3,i));
    end
    
    fclose(fid);