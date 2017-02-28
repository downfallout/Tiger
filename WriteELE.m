function WriteELE(fileName,eleData)
    fid = fopen(fileName,'w');

    if(isempty(eleData))
        fclose(fid);
        return;
    end
    
    count = length(eleData{1});
    for i=1:count
        fprintf(fid, '%d %d %d %d %d %c %d %d %c %f %f %f %c %.10f\n', eleData{1}(i), eleData{2}(i), eleData{3}(i), eleData{4}(i), eleData{5}(i), eleData{6}(i), eleData{7}(i), eleData{8}(i), eleData{9}(i), eleData{10}(i), eleData{11}(i), eleData{12}(i), eleData{13}(i), eleData{14}(i));
    end

    fclose(fid);