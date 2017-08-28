function [laneMarkers,meshTriData,meshTriNormData, meshTriDirData] = ReadASCLane(gt_file)
    
laneMarkers=[];

markersRight = [];
markersLeft = [];

fd_gt=fopen(gt_file,'r');

   
%count=0
totalInds = 0;
while (feof(fd_gt) == 0)

   line=fgets(fd_gt);
   if(line(1) == '/' && line(2) == '/')
       continue;
   end

    [tnum,line2] = strtok(line,[',' ' ']);
    [north,line2] = strtok(line2,[',' ' ']);
    [east,line2] = strtok(line2,[',' ' ']);
    [alt,line2] = strtok(line2,[',' ' ']);
    [type,line2] = strtok(line2,[',' ' ']);
    if(length(type) < 2)
        continue;
    end

    if(type(1) == 'L' && type(2) == 'N')
        totalInds = totalInds+1;
    end
end

fseek(fd_gt,0,'bof');

laneMarkers(totalInds).id = [];
totalInds = 0;

while (feof(fd_gt) == 0)

   line=fgets(fd_gt);
   if(line(1) == '/' && line(2) == '/')
       continue;
   end

    [tnum,line2] = strtok(line,[',' ' ']);
    [north,line2] = strtok(line2,[',' ' ']);
    [east,line2] = strtok(line2,[',' ' ']);
    [alt,line2] = strtok(line2,[',' ' ']);
    [type,line2] = strtok(line2,[',' ' ']);
    if(length(type) < 2)
        continue;
    end

    if(type(1) == 'L' && type(2) == 'N')
        totalInds = totalInds+1;
%        [groundType,line2] = strtok(line2,[',' ' ']);
        [markerType,line2] = strtok(line2,[',' ' ']);
        
        laneMarkers(totalInds).id = str2num(tnum);
        laneMarkers(totalInds).center.north = str2num(north);
        laneMarkers(totalInds).center.east = str2num(east);
        laneMarkers(totalInds).center.alt = str2num(alt);
        laneMarkers(totalInds).type = type;
%        laneMarkers(ind).groundType = groundType;
        laneMarkers(totalInds).markerType = markerType;
    end
end

fclose(fd_gt);

%Build Lane Blocks
%Lane markers are not always in the same order in asc files.  I assume
%either a loop starting at BOLL and ending at BOLR; or BOLL through MOLL to
%EOLL then BOLR through MOLR ending with EOLR

numMarkersLeft = 0;
numMarkersRight = 0;
firstRight = true;
loop = true;
for i=1:length(laneMarkers)
    if(~isempty(strfind(laneMarkers(i).markerType, 'LL')))
        numMarkersLeft = numMarkersLeft+1;
    	markersLeft(numMarkersLeft,:) = [laneMarkers(i).center.east laneMarkers(i).center.north];
    elseif(~isempty(strfind(laneMarkers(i).markerType, 'LR')))
        if(firstRight)
            if(~isempty(strfind(laneMarkers(i).markerType, 'BOLR')))
                loop = false;
            elseif(~isempty(strfind(laneMarkers(i).markerType, 'EOLR')))
                loop = true;
            end
            firstRight = false;
        end
        
        numMarkersRight = numMarkersRight+1;
        
        markersRight(numMarkersRight,:) = [laneMarkers(i).center.east laneMarkers(i).center.north];
    end
end

for i=1:floor(numMarkersLeft/2)
    temp = markersLeft(i,:);
    markersLeft(i,:) = markersLeft(numMarkersLeft-i+1,:);
    markersLeft(numMarkersLeft-i+1,:) = temp;
end

if(loop)
    for i=1:floor(numMarkersRight/2)
        temp = markersRight(i,:);
        markersRight(i,:) = markersRight(numMarkersRight-i+1,:);
        markersRight(numMarkersRight-i+1,:) = temp;
    end
end

meshTriData = [];
meshTriNormData = [];
meshTriDirData = [];

if(~isempty(markersRight))
    markersAll = [markersRight; markersLeft];
    markersInd = 1:size(markersAll,1);
    isRightMarker = zeros(1,size(markersAll,1));
    isRightMarker(1:size(markersRight,1)) = 1;

        angles = zeros(1,length(markersInd));
        tempVec1 = markersAll(markersInd(2),:) - markersAll(markersInd(1),:);
        tempVec1 = [tempVec1/norm(tempVec1) 0];
        tempVec2 = markersAll(markersInd(end),:) - markersAll(markersInd(1),:);
        tempVec2 = [tempVec2/norm(tempVec2) 0];
        if(max(cross(tempVec1,tempVec2)) > 0)
            angles(1) = dot(tempVec1,tempVec2);
        else
            angles(1) = -2 - dot(tempVec1,tempVec2);
        end

        for i=2:length(markersInd)-1
            tempVec1 = markersAll(markersInd(i+1),:) - markersAll(markersInd(i),:);
            tempVec1 = [tempVec1/norm(tempVec1) 0];
            tempVec2 = markersAll(markersInd(i-1),:) - markersAll(markersInd(i),:);
            tempVec2 = [tempVec2/norm(tempVec2) 0];
            if(max(cross(tempVec1,tempVec2)) > 0)
                angles(i) = dot(tempVec1,tempVec2);
            else
                angles(i) = -2 - dot(tempVec1,tempVec2);
            end
        end

        tempVec1 = markersAll(markersInd(1),:) - markersAll(markersInd(end),:);
        tempVec1 = [tempVec1/norm(tempVec1) 0];
        tempVec2 = markersAll(markersInd(end-1),:) - markersAll(markersInd(end),:);
        tempVec2 = [tempVec2/norm(tempVec2) 0];
        if(max(cross(tempVec1,tempVec2)) > 0)
            angles(end) = dot(tempVec1,tempVec2);
        else
            angles(end) = -2 - dot(tempVec1,tempVec2);
        end

    while(length(markersInd) > 3)
        [~,ind] = max(angles);

        ind1 = markersInd(ind);

        if(ind == length(angles))
            ind2 = markersInd(1);
        else
            ind2 = markersInd(ind+1);
        end

        if(ind == 1)
            ind3 = markersInd(end);
        else
            ind3 = markersInd(ind-1);
        end

        meshTriData(end+1,:) = markersAll(ind1,:);
        meshTriData(end+1,:) = markersAll(ind2,:);
        meshTriData(end+1,:) = markersAll(ind3,:);
        
        isRightTemp(1) = isRightMarker(ind1); 
        isRightTemp(2) = isRightMarker(ind2); 
        isRightTemp(3) = isRightMarker(ind3); 
        
        if(isRightTemp(1))
            if(isRightTemp(2))
                %Right Side 1 2
                di = markersAll(ind2,:) - markersAll(ind1,:);
                di = di/norm(di);
                meshTriDirData(end+1,:) = [di(2) -di(1)];
                meshTriDirData(end+1,:) = di;
                meshTriDirData(end+1,:) = [0 0];
            else
                if(isRightTemp(3))
                    %Right Side 1 3
                    di = markersAll(ind1,:) - markersAll(ind3,:);
                    di = di/norm(di);
                    meshTriDirData(end+1,:) = [di(2) -di(1)];
                    meshTriDirData(end+1,:) = di;
                    meshTriDirData(end+1,:) = [0 0];
                else
                    %Left Side 2 3
                    di = markersAll(ind2,:) - markersAll(ind3,:);
                    di = di/norm(di);
                    meshTriDirData(end+1,:) = [di(2) -di(1)];
                    meshTriDirData(end+1,:) = di;
                    meshTriDirData(end+1,:) = [0 0];
                end
            end
        else
            if(isRightTemp(2))
                if(isRightTemp(3))
                    %Right Side 2 3
                    di = markersAll(ind3,:) - markersAll(ind2,:);
                    di = di/norm(di);
                    meshTriDirData(end+1,:) = [di(2) -di(1)];
                    meshTriDirData(end+1,:) = di;
                    meshTriDirData(end+1,:) = [0 0];
                else
                    %Left Side 1 3
                    di = markersAll(ind3,:) - markersAll(ind1,:);
                    di = di/norm(di);
                    meshTriDirData(end+1,:) = [di(2) -di(1)];
                    meshTriDirData(end+1,:) = di;
                    meshTriDirData(end+1,:) = [0 0];
                end
            else
                %Left Side 1 2
                di = markersAll(ind1,:) - markersAll(ind2,:);
                di = di/norm(di);
                meshTriDirData(end+1,:) = [di(2) -di(1)];
                meshTriDirData(end+1,:) = di;
                meshTriDirData(end+1,:) = [0 0];
            end
        end
        
%        meshTriNormData(end+1,:) = cross([0 0 1], [markersAll(ind2,:) - markersAll(ind1,:) 0]);
%        meshTriNormData(end+1,:) = cross([0 0 1], [markersAll(ind3,:) - markersAll(ind2,:) 0]);
%        meshTriNormData(end+1,:) = cross([0 0 1], [markersAll(ind1,:) - markersAll(ind3,:) 0]);
        
        %Simplify the cross product
        di = markersAll(ind2,:) - markersAll(ind1,:);
        di = di/norm(di);
        meshTriNormData(end+1,:) = [-di(2) di(1)];
        di = markersAll(ind3,:) - markersAll(ind2,:);
        di = di/norm(di);
        meshTriNormData(end+1,:) = [-di(2) di(1)];
        di = markersAll(ind1,:) - markersAll(ind3,:);
        di = di/norm(di);
        meshTriNormData(end+1,:) = [-di(2) di(1)];

        markersInd(ind) = [];
        angles(ind) = [];

        ind = min(ind,length(angles));

        if(ind == 1)
            tempVec1 = markersAll(markersInd(ind+1),:) - markersAll(markersInd(ind),:);
            tempVec1 = [tempVec1/norm(tempVec1) 0];
            tempVec2 = markersAll(markersInd(end),:) - markersAll(markersInd(ind),:);
            tempVec2 = [tempVec2/norm(tempVec2) 0];
            if(max(cross(tempVec1,tempVec2)) > 0)
                angles(ind) = dot(tempVec1,tempVec2);
            else
                angles(ind) = -2 - dot(tempVec1,tempVec2);
            end
        elseif(ind == length(angles))
            tempVec1 = markersAll(markersInd(1),:) - markersAll(markersInd(ind),:);
            tempVec1 = [tempVec1/norm(tempVec1) 0];
            tempVec2 = markersAll(markersInd(ind-1),:) - markersAll(markersInd(ind),:);
            tempVec2 = [tempVec2/norm(tempVec2) 0];
            if(max(cross(tempVec1,tempVec2)) > 0)
                angles(ind) = dot(tempVec1,tempVec2);
            else
                angles(ind) = -2 - dot(tempVec1,tempVec2);
            end
        else
            tempVec1 = markersAll(markersInd(ind+1),:) - markersAll(markersInd(ind),:);
            tempVec1 = [tempVec1/norm(tempVec1) 0];
            tempVec2 = markersAll(markersInd(ind-1),:) - markersAll(markersInd(ind),:);
            tempVec2 = [tempVec2/norm(tempVec2) 0];
            if(max(cross(tempVec1,tempVec2)) > 0)
                angles(ind) = dot(tempVec1,tempVec2);
            else
                angles(ind) = -2 - dot(tempVec1,tempVec2);
            end
        end

        if(ind ==1)
            ind = length(angles);
        else
            ind = ind-1;
        end

        if(ind == 1)
            tempVec1 = markersAll(markersInd(ind+1),:) - markersAll(markersInd(ind),:);
            tempVec1 = [tempVec1/norm(tempVec1) 0];
            tempVec2 = markersAll(markersInd(end),:) - markersAll(markersInd(ind),:);
            tempVec2 = [tempVec2/norm(tempVec2) 0];
            if(max(cross(tempVec1,tempVec2)) > 0)
                angles(ind) = dot(tempVec1,tempVec2);
            else
                angles(ind) = -2 - dot(tempVec1,tempVec2);
            end
        elseif(ind == length(angles))
            tempVec1 = markersAll(markersInd(1),:) - markersAll(markersInd(ind),:);
            tempVec1 = [tempVec1/norm(tempVec1) 0];
            tempVec2 = markersAll(markersInd(ind-1),:) - markersAll(markersInd(ind),:);
            tempVec2 = [tempVec2/norm(tempVec2) 0];
            if(max(cross(tempVec1,tempVec2)) > 0)
                angles(ind) = dot(tempVec1,tempVec2);
            else
                angles(ind) = -2 - dot(tempVec1,tempVec2);
            end
        else
            tempVec1 = markersAll(markersInd(ind+1),:) - markersAll(markersInd(ind),:);
            tempVec1 = [tempVec1/norm(tempVec1) 0];
            tempVec2 = markersAll(markersInd(ind-1),:) - markersAll(markersInd(ind),:);
            tempVec2 = [tempVec2/norm(tempVec2) 0];
            if(max(cross(tempVec1,tempVec2)) > 0)
                angles(ind) = dot(tempVec1,tempVec2);
            else
                angles(ind) = -2 - dot(tempVec1,tempVec2);
            end
        end
%        meshTriDataX = reshape(meshTriData(:,1),3,[])-e;
%        meshTriDataY = reshape(meshTriData(:,2),3,[])-n;
%        p = patch(meshTriDataX,meshTriDataY,'b'); axis equal;
    %    pause(.05);
    end

    [~,ind] = max(angles);

    ind1 = markersInd(ind);

    if(ind == length(angles))
        ind2 = markersInd(1);
    else
        ind2 = markersInd(ind+1);
    end

    if(ind == 1)
        ind3 = markersInd(end);
    else
        ind3 = markersInd(ind-1);
    end
    
    meshTriData(end+1,:) = markersAll(ind1,:);
    meshTriData(end+1,:) = markersAll(ind2,:);
    meshTriData(end+1,:) = markersAll(ind3,:);
    
    
    isRightTemp(1) = isRightMarker(ind1); 
    isRightTemp(2) = isRightMarker(ind2); 
    isRightTemp(3) = isRightMarker(ind3); 

    if(isRightTemp(1))
        if(isRightTemp(2))
            %Right Side 1 2
            di = markersAll(ind2,:) - markersAll(ind1,:);
            di = di/norm(di);
            meshTriDirData(end+1,:) = [di(2) -di(1)];
            meshTriDirData(end+1,:) = di;
            meshTriDirData(end+1,:) = [0 0];
        else
            if(isRightTemp(3))
                %Right Side 1 3
                di = markersAll(ind1,:) - markersAll(ind3,:);
                di = di/norm(di);
                meshTriDirData(end+1,:) = [di(2) -di(1)];
                meshTriDirData(end+1,:) = di;
                meshTriDirData(end+1,:) = [0 0];
            else
                %Left Side 2 3
                di = markersAll(ind2,:) - markersAll(ind3,:);
                di = di/norm(di);
                meshTriDirData(end+1,:) = [di(2) -di(1)];
                meshTriDirData(end+1,:) = di;
                meshTriDirData(end+1,:) = [0 0];
            end
        end
    else
        if(isRightTemp(2))
            if(isRightTemp(3))
                %Right Side 2 3
                di = markersAll(ind3,:) - markersAll(ind2,:);
                di = di/norm(di);
                meshTriDirData(end+1,:) = [di(2) -di(1)];
                meshTriDirData(end+1,:) = di;
                meshTriDirData(end+1,:) = [0 0];
            else
                %Left Side 1 3
                di = markersAll(ind3,:) - markersAll(ind1,:);
                di = di/norm(di);
                meshTriDirData(end+1,:) = [di(2) -di(1)];
                meshTriDirData(end+1,:) = di;
                meshTriDirData(end+1,:) = [0 0];
            end
        else
            %Left Side 1 2
            di = markersAll(ind1,:) - markersAll(ind2,:);
            di = di/norm(di);
            meshTriDirData(end+1,:) = [di(2) -di(1)];
            meshTriDirData(end+1,:) = di;
            meshTriDirData(end+1,:) = [0 0];
        end
    end
        
%    meshTriDataX = reshape(meshTriData(:,1),3,[])-e;
%    meshTriDataY = reshape(meshTriData(:,2),3,[])-n;
%    p = patch(meshTriDataX,meshTriDataY,'b'); axis equal;
    
    
%        meshTriNormData(end+1,:) = cross([0 0 1], [markersAll(ind2,:) - markersAll(ind1,:) 0]);
%        meshTriNormData(end+1,:) = cross([0 0 1], [markersAll(ind3,:) - markersAll(ind2,:) 0]);
%        meshTriNormData(end+1,:) = cross([0 0 1], [markersAll(ind1,:) - markersAll(ind3,:) 0]);
        
    %Simplify the cross product
    di = markersAll(ind2,:) - markersAll(ind1,:);
    di = di/norm(di);
    meshTriNormData(end+1,:) = [-di(2) di(1)];
    di = markersAll(ind3,:) - markersAll(ind2,:);
    di = di/norm(di);
    meshTriNormData(end+1,:) = [-di(2) di(1)];
    di = markersAll(ind1,:) - markersAll(ind3,:);
    di = di/norm(di);
    meshTriNormData(end+1,:) = [-di(2) di(1)];

    totalArea = 0;
    for i=1:3:size(meshTriData,1)
        tempVec1 = [meshTriData(i+1,:)-meshTriData(i,:) 0];
        tempVec2 = [meshTriData(i+2,:)-meshTriData(i,:) 0];

        totalArea = totalArea + max(cross(tempVec1,tempVec2))/2;
    end
end

%fprintf('Total lane area %.2f meters squared.\n',totalArea);