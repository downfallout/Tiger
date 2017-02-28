function [targetList,clutterList,laneMarkers,groundMarkers,meshTriData,meshTriNormData, meshTriDirData] = ReadTru(gt_file)
    
gt=[];
ct = [];
laneMarkers=[];
groundMarkers=[];

markersRight = [];
markersLeft = [];

fd_gt=fopen(gt_file,'r');

   
%count=0
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
        [groundType,line2] = strtok(line2,[',' ' ']);
        [markerType,line2] = strtok(line2,[',' ' ']);
        ind = length(laneMarkers)+1;
        laneMarkers(ind).id = str2num(tnum);
        laneMarkers(ind).center.north = str2num(north);
        laneMarkers(ind).center.east = str2num(east);
        laneMarkers(ind).center.alt = str2num(alt);
        laneMarkers(ind).type = type;
        laneMarkers(ind).groundType = groundType;
        laneMarkers(ind).markerType = markerType;
    elseif(type(1) == 'L' && type(2) == 'M')
        [markerType,line2] = strtok(line2,[',' ' ']);
        ind = length(groundMarkers)+1;
        groundMarkers(ind).id = str2num(tnum);
        groundMarkers(ind).north = str2num(north);
        groundMarkers(ind).east = str2num(east);
        groundMarkers(ind).alt = str2num(alt);
        groundMarkers(ind).type = type;
        groundMarkers(ind).markerType = markerType;
    else
        [buriedDepth,line2] = strtok(line2,[',' ' ']);
        [multiPoint,line2] = strtok(line2,[',' ' ']);
        [numMultiPoint,line2] = strtok(line2,[',' ' ']);
        [lane,line2] = strtok(line2,[',' ' ']);
        [isTarget,line2] = strtok(line2,[',' ' ']);
        if(isTarget(1) == 'Y')
            ind = length(gt)+1;
            gt(ind).id = str2num(tnum);
            gt(ind).north = str2num(north);
            gt(ind).east = str2num(east);
            gt(ind).alt = str2num(alt);
            gt(ind).type = type;
            gt(ind).buriedDepth = str2num(buriedDepth);
            gt(ind).multiPoint = multiPoint == 'Y';
            gt(ind).numMultiPoint = str2num(numMultiPoint);
            gt(ind).lane = lane;
            gt(ind).isTarget = true;
            gt(ind).isMetal = ~isempty(strfind(gt(ind).type, 'M'));
            gt(ind).isUnconcealed = ~isempty(strfind(gt(ind).type, 'U'));
            if(~isempty(strfind(gt(ind).type, 'EFP')))
                gt(ind).diameter = str2num(gt(ind).type(9:10));
                gt(ind).length = str2num(gt(ind).type(12:13));
                gt(ind).pitch = str2num(gt(ind).type(15:16));
                gt(ind).yaw = str2num(gt(ind).type(18:20));
            else
                gt(ind).diameter = 0;
                gt(ind).length = 0;
                gt(ind).pitch = 0;
                gt(ind).yaw = 0;
            end
        else
            ind = length(ct)+1;
            ct(ind).id = str2num(tnum);
            ct(ind).north = str2num(north);
            ct(ind).east = str2num(east);
            ct(ind).alt = str2num(alt);
            ct(ind).type = type;
            ct(ind).buriedDepth = str2num(buriedDepth);
            ct(ind).multiPoint = multiPoint == 'Y';
            ct(ind).numMultiPoint = str2num(numMultiPoint);
            ct(ind).lane = lane;
            ct(ind).isTarget = false;
        end
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

%Build target List

targetList = [];

rectJump = 0;

for i=1:length(gt)
    if(rectJump > 0)
        rectJump = rectJump - 1;
        continue;
    end
    
    if( ~isempty(strfind(upper(gt(i).type), 'WIRE')))
        continue;
    end
    
    ind = length(targetList)+1;
    targetList(ind).id = gt(i).id;
    targetList(ind).type = gt(i).type;
    targetList(ind).buriedDepth = gt(i).buriedDepth;
    targetList(ind).multiPoint = gt(i).multiPoint;
    targetList(ind).lane = gt(i).lane;
    targetList(ind).isMetal = gt(ind).isMetal;
    targetList(ind).isUnconcealed = gt(ind).isUnconcealed;
    targetList(ind).diameter = gt(ind).diameter;
    targetList(ind).length = gt(ind).length;
    targetList(ind).pitch = gt(ind).pitch;
    targetList(ind).yaw = gt(ind).yaw;
    if(gt(i).multiPoint)
        rectJump = gt(i).numMultiPoint-1;


        targetList(ind).loc(1).north = gt(i).north;
        targetList(ind).loc(1).east = gt(i).east;
        targetList(ind).loc(1).alt = gt(i).alt;
        targetList(ind).loc(2).north = gt(i+1).north;
        targetList(ind).loc(2).east = gt(i+1).east;
        targetList(ind).loc(2).alt = gt(i+1).alt;

        targetList(ind).center.north = (targetList(ind).loc(1).north + targetList(ind).loc(2).north)/2;
        targetList(ind).center.east = (targetList(ind).loc(1).east + targetList(ind).loc(2).east)/2;
        targetList(ind).center.alt = (targetList(ind).loc(1).alt + targetList(ind).loc(2).alt)/2;
    else
        targetList(ind).loc.north = gt(i).north;
        targetList(ind).loc.east = gt(i).east;
        targetList(ind).loc.alt = gt(i).alt;
        targetList(ind).center.north = gt(i).north;
        targetList(ind).center.east = gt(i).east;
        targetList(ind).center.alt = gt(i).alt;
    end
    
    targetList(ind).rectangle = false;
    targetList(ind).isWire = false;
end

clutterList = [];
rectJump = 0;
for i=1:length(ct)
    if(rectJump > 0)
        rectJump = rectJump - 1;
        continue;
    end
    
    if( ~isempty(strfind(upper(ct(i).type), 'WIRE')))
        continue;
    end
    
    if(ct(i).multiPoint)
        ind = length(clutterList)+1;
        clutterList(ind).id = ct(i).id;
        clutterList(ind).type = ct(i).type;
        clutterList(ind).buriedDepth = ct(i).buriedDepth;
        clutterList(ind).multiPoint = ct(i).multiPoint;
        clutterList(ind).lane = ct(i).lane;
        
        rectJump = ct(i).numMultiPoint-1;


        clutterList(ind).loc(1).north = ct(i).north;
        clutterList(ind).loc(1).east = ct(i).east;
        clutterList(ind).loc(1).alt = ct(i).alt;
        clutterList(ind).loc(2).north = ct(i+1).north;
        clutterList(ind).loc(2).east = ct(i+1).east;
        clutterList(ind).loc(2).alt = ct(i+1).alt;

        clutterList(ind).center.north = (clutterList(ind).loc(1).north + clutterList(ind).loc(2).north)/2;
        clutterList(ind).center.east = (clutterList(ind).loc(1).east + clutterList(ind).loc(2).east)/2;
        clutterList(ind).center.alt = (clutterList(ind).loc(1).alt + clutterList(ind).loc(2).alt)/2;
    else
        ind = length(clutterList)+1;
        clutterList(ind).id = ct(i).id;
        clutterList(ind).type = ct(i).type;
        clutterList(ind).buriedDepth = ct(i).buriedDepth;
        clutterList(ind).multiPoint = ct(i).multiPoint;
        clutterList(ind).lane = ct(i).lane;
        clutterList(ind).loc.north = ct(i).north;
        clutterList(ind).loc.east = ct(i).east;
        clutterList(ind).loc.alt = ct(i).alt;
        clutterList(ind).center.north = ct(i).north;
        clutterList(ind).center.east = ct(i).east;
        clutterList(ind).center.alt = ct(i).alt;
    end
    
    clutterList(ind).rectangle = false;
    clutterList(ind).isWire = false;
end

fprintf('');

%figure(1); hold on; for i=1:length(targetList) plot(targetList(i).loc(1).east, targetList(i).loc(1).north, '.r'); end; axis equal;
%figure(1); hold on; for i=1:length(targetList) plot3(targetList(i).loc(1).east, targetList(i).loc(1).north, targetList(i).loc(1).alt, '.r'); end; axis equal;