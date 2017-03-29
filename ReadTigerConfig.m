function [fileNameTiger, numFiles, halo, alarmOffset, targetCategoryScore] = ReadTigerConfig(fileName)
    fid = fopen(fileName);
    
    halo = fscanf(fid,'%f\n',1);
    
    alarmOffset = fscanf(fid,'%f %f\n',[1 2]);
    
%    confuserScore = fscanf(fid,'%f\n',1);
    line = fgets(fid);
    targetCategoryScore = textscan(line, '%f',  'delimiter', ' ');
    targetCategoryScore = targetCategoryScore{1};
    
%    numFiles = fscanf(fid,'%f\n',1);
    
    fileNameTiger = textscan(fid, '%s %s %s %s',  'delimiter', ',');
    fclose(fid);
    
    numFiles = length(fileNameTiger{1});