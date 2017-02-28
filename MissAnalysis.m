function offset = MissAnalysis(alarmLoc, alarmConf, targetList, confuserScore, halo, meshTriData, meshTriNormData, meshTriDirData)

    s = size(alarmLoc);
    
    targetLoc = zeros(length(targetList),2);
    
    for i=1:length(targetList)
        targetLoc(i,:) = [targetList(i).center.east; targetList(i).center.north];
    end
    
    offset = zeros(s(1),2);
%    laneOrthogAll = zeros(3*s(1),2);
    
    %find the orthogonal basis for each target.  This could be moved
    %earlier in the processing chain to reduce computation.
    laneOrthog = zeros(3*length(targetList),2);
    for i=1:length(targetList)
        laneOrthog((i-1)*3+1:(i-1)*3+3,:) = LaneOrthogonal(targetLoc(i,:), meshTriData, meshTriNormData, meshTriDirData);
    end

    for i=1:s(1)
        offsetTemp = [alarmLoc(i,1) - targetLoc(:,1), alarmLoc(i,2)-targetLoc(:,2)];
        dist = sqrt(sum(offsetTemp.*offsetTemp,2));
        
        [~, minInd] = min(dist);
        
        minVec = offsetTemp(minInd,:);
        
%        laneOrthog = LaneOrthogonal(targetLoc(minInd,:), meshTriData, meshTriNormData, meshTriDirData);
        
%        laneOrthogAll((i-1)*3+1:(i-1)*3+3,:) = laneOrthog((minInd-1)*3+1:(minInd-1)*3+3,:);
        
        offset(i,:) = [dot(laneOrthog(1,:),minVec), dot(laneOrthog(2,:),minVec)];
    end
    
    