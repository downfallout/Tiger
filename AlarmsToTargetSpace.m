function [alarmLocOut, minInd] = AlarmsToTargetSpace(alarmLoc, velocity, targetList)

    s = size(alarmLoc);
    
    alarmLocOut = zeros(s);
    minInd = zeros(1,s(1));
    
    for i=1:s(1)
        minDist = 1000000;
        tangient = velocity(i,:)./norm(velocity(i,:));
        biNormal = cross([tangient 0], [0 0 1]);
        biNormal = biNormal(1:2);
        
        for j=1:length(targetList)
            if(targetList(j).isWire)
                    
                    vec = [alarmLoc(i,1) - targetList(j).loc(1).east, alarmLoc(i,2) - targetList(j).loc(1).north];
                    dist1 = vec*targetList(j).n2';
                    dist2 = vec*targetList(j).n1';
                    
                    dist2 = max(0, min(targetList(j).dist1, dist2));

                    offset = alarmLoc(i,:) - ([targetList(j).loc(1).east targetList(j).loc(1).north] + (dist2*targetList(j).n1));
                    dist = sqrt(sum(offset.*offset));
                    
                    if(dist < minDist)
                        minInd(i) = j;
                        minDist = dist;
                        alarmLocOut(i,:) = [dist2-targetList(j).dist1/2 dist1];
                    end
            else
                offset = alarmLoc(i,:) - [targetList(j).center.east targetList(j).center.north];
                dist = sqrt(sum(offset.*offset));
            
                if(dist < minDist)
                    minInd(i) = j;
                    minDist = dist;
                    alarmLocOut(i,:) = [biNormal*offset' tangient*offset'];
                end
            end
        end
    end