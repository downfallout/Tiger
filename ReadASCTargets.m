function targetList = ReadASCTargets(gt_file)
    
gt=[];
ct = [];
laneMarkers=[];
groundMarkers=[];

markersRight = [];
markersLeft = [];

fd_gt=fopen(gt_file,'r');

   
polyCount = 0;
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

    [buriedDepth,line2] = strtok(line2,[',' ' ']);
    [multiPoint,line2] = strtok(line2,[',' ' ']);
    
    if(multiPoint == 'V' || multiPoint == 'X')
        [lane,line2] = strtok(line2,[',' ' ']);
        line2 = strtrim(line2); %kw
        if(strcmp(line2,'start') == 1)  %kw
            polyCount = 1;
        elseif(strcmp(line2,'stop') == 1) %kw
            polyCount = polyCount+1;
            gt(end-polyCount+2).numMultiPoint = polyCount;
        else
            polyCount = polyCount+1;
        end
    else
        [lane,line2] = strtok(line2,[',' ' ']);
    end
    
    
    ind = length(gt)+1;
%    gt(ind).id = str2num(tnum);
    gt(ind).id = tnum;
    gt(ind).north = str2num(north);
    gt(ind).east = str2num(east);
    gt(ind).alt = str2num(alt);
    gt(ind).type = type;
    gt(ind).buriedDepth = str2num(buriedDepth);
    gt(ind).multiPoint = multiPoint;
    gt(ind).lane = lane;
    gt(ind).targetCategory = str2num(tnum(8));
    if(0)
%    if(~isempty(strfind(gt(ind).type, 'EFP')))
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
end

fclose(fd_gt);

%Build target List

targetList = [];

rectJump = 0;

for i=1:length(gt)
    if(rectJump > 0)
        rectJump = rectJump - 1;
        continue;
    end
    
    ind = length(targetList)+1;
    targetList(ind).id = gt(i).id;
    targetList(ind).type = gt(i).type;
    targetList(ind).buriedDepth = gt(i).buriedDepth;
    targetList(ind).multiPoint = gt(i).multiPoint;
    targetList(ind).lane = gt(i).lane;
    targetList(ind).diameter = gt(i).diameter;
    targetList(ind).length = gt(i).length;
    targetList(ind).pitch = gt(i).pitch;
    targetList(ind).yaw = gt(i).yaw;
    targetList(ind).targetCategory = gt(i).targetCategory+1;
    targetList(ind).numMultiPoint = gt(i).numMultiPoint; %kw
    
    switch(gt(i).multiPoint)
        case 'N'
            targetList(ind).rectangle = false;
            targetList(ind).concave = false;
            targetList(ind).convex = false;
            targetList(ind).isWire = false;
            targetList(ind).loc.north = gt(i).north;
            targetList(ind).loc.east = gt(i).east;
            targetList(ind).loc.alt = gt(i).alt;
            targetList(ind).center.north = gt(i).north;
            targetList(ind).center.east = gt(i).east;
            targetList(ind).center.alt = gt(i).alt;
            targetList(ind).rectangle = false;
        case 'Y'
            rectJump = 2;
            
            targetList(ind).rectangle = true;
            targetList(ind).concave = false;
            targetList(ind).convex = false;
            
            targetList(ind).isWire = false;
            
            
            targetList(ind).loc(1).north = gt(i).north;
            targetList(ind).loc(1).east = gt(i).east;
            targetList(ind).loc(1).alt = gt(i).alt;
            targetList(ind).loc(2).north = gt(i+1).north;
            targetList(ind).loc(2).east = gt(i+1).east;
            targetList(ind).loc(2).alt = gt(i+1).alt;
            targetList(ind).loc(3).north = gt(i+2).north;
            targetList(ind).loc(3).east = gt(i+2).east;
            targetList(ind).loc(3).alt = gt(i+2).alt;
            
            %Determine the correct orientation of the rectangle
            v1 = [targetList(ind).loc(2).east - targetList(ind).loc(1).east, targetList(ind).loc(2).north - targetList(ind).loc(1).north];
            v2 = [targetList(ind).loc(3).east - targetList(ind).loc(1).east, targetList(ind).loc(3).north - targetList(ind).loc(1).north];
            v3 = [targetList(ind).loc(3).east - targetList(ind).loc(2).east, targetList(ind).loc(3).north - targetList(ind).loc(2).north];
            
            v1 = v1/norm(v1);
            v2 = v2/norm(v2);
            v3 = v3/norm(v3);
            
            vv(1) = v1*v2';
            vv(2) = v1*v3';
            vv(3) = v2*v3';
            
            [~, indMin] = min(abs(vv));

            if(indMin == 1)
                swapVal = targetList(ind).loc(1).north;
                targetList(ind).loc(1).north = targetList(ind).loc(2).north;
                targetList(ind).loc(2).north = swapVal;
                swapVal = targetList(ind).loc(1).east;
                targetList(ind).loc(1).east = targetList(ind).loc(2).east;
                targetList(ind).loc(2).east = swapVal;
                swapVal = targetList(ind).loc(1).alt;
                targetList(ind).loc(1).alt = targetList(ind).loc(2).alt;
                targetList(ind).loc(2).alt = swapVal;
            elseif(indMin == 3)
                swapVal = targetList(ind).loc(3).north;
                targetList(ind).loc(3).north = targetList(ind).loc(2).north;
                targetList(ind).loc(2).north = swapVal;
                swapVal = targetList(ind).loc(3).east;
                targetList(ind).loc(3).east = targetList(ind).loc(2).east;
                targetList(ind).loc(2).east = swapVal;
                swapVal = targetList(ind).loc(3).alt;
                targetList(ind).loc(3).alt = targetList(ind).loc(2).alt;
                targetList(ind).loc(2).alt = swapVal;
            end
            %Done
            
            targetList(ind).loc(4).north = targetList(ind).loc(1).north + targetList(ind).loc(3).north - targetList(ind).loc(2).north;
            targetList(ind).loc(4).east = targetList(ind).loc(1).east + targetList(ind).loc(3).east - targetList(ind).loc(2).east;
            targetList(ind).loc(4).alt = targetList(ind).loc(1).alt + targetList(ind).loc(3).alt - targetList(ind).loc(2).alt;
            
            targetList(ind).center.north = (targetList(ind).loc(1).north + targetList(ind).loc(3).north)/2;
            targetList(ind).center.east = (targetList(ind).loc(1).east + targetList(ind).loc(3).east)/2;
            targetList(ind).center.alt = (targetList(ind).loc(1).alt + targetList(ind).loc(3).alt)/2;
            
            targetList(ind).n1 = [targetList(ind).loc(1).north - targetList(ind).loc(2).north, targetList(ind).loc(2).east - targetList(ind).loc(1).east];
            targetList(ind).n2 = [targetList(ind).loc(2).north - targetList(ind).loc(3).north, targetList(ind).loc(3).east - targetList(ind).loc(2).east];
            
            targetList(ind).dist1 = sqrt(sum(targetList(ind).n2.^2));
            targetList(ind).dist2 = sqrt(sum(targetList(ind).n1.^2));
            
            targetList(ind).n1 = targetList(ind).n1/targetList(ind).dist2;
            targetList(ind).n2 = targetList(ind).n2/targetList(ind).dist1;
            
        case 'V'
            targetList(ind).concave = true;
            targetList(ind).convex = false;
            targetList(ind).rectangle = false;
            targetList(ind).isWire = false;
            
            rectJump = gt(i).numMultiPoint-1;

            targetList(ind).center.north = 0;
            targetList(ind).center.east = 0;
            targetList(ind).center.alt = 0;
            for multipointInd = 0:gt(i).numMultiPoint-1
                targetList(ind).loc(multipointInd+1).north = gt(i+multipointInd).north;
                targetList(ind).loc(multipointInd+1).east = gt(i+multipointInd).east;
                targetList(ind).loc(multipointInd+1).alt = gt(i+multipointInd).alt;

                targetList(ind).center.north = targetList(ind).center.north + gt(i+multipointInd).north;
                targetList(ind).center.east = targetList(ind).center.east + gt(i+multipointInd).east;
                targetList(ind).center.alt = targetList(ind).center.alt + gt(i+multipointInd).alt;
            end
            
            northV = zeros(1, gt(i).numMultiPoint);
            eastV = zeros(1, gt(i).numMultiPoint);
            
            for multipointInd = 1:gt(i).numMultiPoint
                northV(multipointInd) = targetList(ind).loc(multipointInd).north;
                eastV(multipointInd) = targetList(ind).loc(multipointInd).east;
            end
            
            tri = delaunay(eastV,northV);
            targetList(ind).n = zeros(3*size(tri,1),2);
            targetList(ind).dist = zeros(3*size(tri,1),1);
            
            targetList(ind).tri = tri;
            
            for curTri = 1:size(tri,1)
                curNormInd = 3*curTri-2;
                targetList(ind).n(curNormInd,:) = [targetList(ind).loc(tri(curTri,2)).north - targetList(ind).loc(tri(curTri,1)).north, targetList(ind).loc(tri(curTri,1)).east - targetList(ind).loc(tri(curTri,2)).east];
                targetList(ind).dist(curNormInd) = sqrt(sum(targetList(ind).n(curTri,:).^2));
                targetList(ind).n(curNormInd,:) = targetList(ind).n(curTri,:)/targetList(ind).dist(multipointInd);
                curNormInd = 3*curTri-1;
                targetList(ind).n(curNormInd,:) = [targetList(ind).loc(tri(curTri,3)).north - targetList(ind).loc(tri(curTri,2)).north, targetList(ind).loc(tri(curTri,2)).east - targetList(ind).loc(tri(curTri,3)).east];
                targetList(ind).dist(curNormInd) = sqrt(sum(targetList(ind).n(curTri,:).^2));
                targetList(ind).n(curNormInd,:) = targetList(ind).n(curTri,:)/targetList(ind).dist(multipointInd);
                curNormInd = 3*curTri;
                targetList(ind).n(curNormInd,:) = [targetList(ind).loc(tri(curTri,1)).north - targetList(ind).loc(tri(curTri,3)).north, targetList(ind).loc(tri(curTri,3)).east - targetList(ind).loc(tri(curTri,1)).east];
                targetList(ind).dist(curNormInd) = sqrt(sum(targetList(ind).n(curTri,:).^2));
                targetList(ind).n(curNormInd,:) = targetList(ind).n(curTri,:)/targetList(ind).dist(multipointInd);
            end
            
%I think this isn't necessary
%            multipointInd = gt(i).numMultiPoint;
%            targetList(ind).n(multipointInd,:) = [targetList(ind).loc(1).north - targetList(ind).loc(multipointInd).north, targetList(ind).loc(1).east - targetList(ind).loc(multipointInd).east];
%            targetList(ind).dist(multipointInd) = sqrt(sum(targetList(ind).n(multipointInd,:).^2));
%            targetList(ind).n(multipointInd,:) = targetList(ind).n(multipointInd,:)/targetList(ind).dist(multipointInd);
            
            targetList(ind).center.north = targetList(ind).center.north/gt(i).numMultiPoint;
            targetList(ind).center.east = targetList(ind).center.east/gt(i).numMultiPoint;
            targetList(ind).center.alt = targetList(ind).center.alt/gt(i).numMultiPoint;
            
        case 'X'
            targetList(ind).concave = false;
            targetList(ind).convex = true;
            targetList(ind).rectangle = false;
            targetList(ind).isWire = false;
            
            rectJump = gt(i).numMultiPoint-1;

            targetList(ind).center.north = 0;
            targetList(ind).center.east = 0;
            targetList(ind).center.alt = 0;
            for multipointInd = 0:gt(i).numMultiPoint-1
                targetList(ind).loc(multipointInd+1).north = gt(i+multipointInd).north;
                targetList(ind).loc(multipointInd+1).east = gt(i+multipointInd).east;
                targetList(ind).loc(multipointInd+1).alt = gt(i+multipointInd).alt;

                targetList(ind).center.north = targetList(ind).center.north + gt(i+multipointInd).north;
                targetList(ind).center.east = targetList(ind).center.east + gt(i+multipointInd).east;
                targetList(ind).center.alt = targetList(ind).center.alt + gt(i+multipointInd).alt;
            end
            
            for multipointInd = 1:gt(i).numMultiPoint-1
                targetList(ind).n(multipointInd,:) = [targetList(ind).loc(multipointInd+1).north - targetList(ind).loc(multipointInd).north, targetList(ind).loc(multipointInd).east - targetList(ind).loc(multipointInd+1).east];
                targetList(ind).dist(multipointInd) = sqrt(sum(targetList(ind).n(multipointInd,:).^2));
                targetList(ind).n(multipointInd,:) = targetList(ind).n(multipointInd,:)/targetList(ind).dist(multipointInd);
            end
            
            multipointInd = gt(i).numMultiPoint;
            targetList(ind).n(multipointInd,:) = [targetList(ind).loc(1).north - targetList(ind).loc(multipointInd).north, targetList(ind).loc(multipointInd).east - targetList(ind).loc(1).east];
            targetList(ind).dist(multipointInd) = sqrt(sum(targetList(ind).n(multipointInd,:).^2));
            targetList(ind).n(multipointInd,:) = targetList(ind).n(multipointInd,:)/targetList(ind).dist(multipointInd);
            
            targetList(ind).center.north = targetList(ind).center.north/gt(i).numMultiPoint;
            targetList(ind).center.east = targetList(ind).center.east/gt(i).numMultiPoint;
            targetList(ind).center.alt = targetList(ind).center.alt/gt(i).numMultiPoint;
            
    end
    
end

%figure(1); hold on; for i=1:length(targetList) plot(targetList(i).loc(1).east, targetList(i).loc(1).north, '.r'); end; axis equal;
%figure(1); hold on; for i=1:length(targetList) plot3(targetList(i).loc(1).east, targetList(i).loc(1).north, targetList(i).loc(1).alt, '.r'); end; axis equal;