function [targetFound, falseAlarms, targetFoundConf, alarmsToTarget] = ScoreAlarmsTry(alarmLoc, alarmConf, targetList, confuserScore, halo)
    haloSq = halo*halo;
    
    s = size(alarmLoc);
    
    numPasses = 0;
    for i=length(targetList):-1:1
        if(confuserScore(targetList(i).targetCategory) == 1)
            targetList(i) = [];
        elseif(confuserScore(targetList(i).targetCategory) == 2)
            numPasses = numPasses+1;
            passList(numPasses) = targetList(i);
            targetList(i) = [];
        else
            fprintf('');
        end
    end
    
    targetFound = false(1, length(targetList));
    targetFoundConf = -100000*ones(1, length(targetList));
    falseAlarms = ones(1, s(1));
    alarmsToTarget = zeros(1, s(1));
    
    data = zeros(2,length(targetList));
    for j=1:length(targetList)
        data(:,j) = [targetList(j).center.east targetList(j).center.north];
        targetList(j).index = j;
    end
    
    if(numPasses > 0)
        passList(numPasses).index = -1;
        quadLookup = BuildQuadLookup(data,[targetList passList]);
    else
        quadLookup = BuildQuadLookup(data,targetList);
    end
    
    minX = floor(min(data(1,:)))-2;
    minY = floor(min(data(2,:)))-2;
    maxX = floor(max(data(1,:)))+1;
    maxY = floor(max(data(2,:)))+1;
    diffX = maxX-minX;
    diffY = maxY-minY;
    
    for i=1:s(1)
        %Now check Targets
        indX = floor(alarmLoc(i,1) - minX);
        indY = floor(alarmLoc(i,2) - minY);
        if(indX > 1 && indY > 1 && indX < diffX && indY < diffY)

            dataTemp = [quadLookup(indY-1,indX-1).conf quadLookup(indY-1,indX).conf quadLookup(indY-1,indX+1).conf...
                quadLookup(indY,indX-1).conf quadLookup(indY,indX).conf quadLookup(indY,indX+1).conf...
                quadLookup(indY+1,indX-1).conf quadLookup(indY+1,indX).conf quadLookup(indY+1,indX+1).conf];


            for j=1:length(dataTemp)
                foundTarget = false;
                if(dataTemp(j).rectangle)
                    foundTarget = false;
                    
                    for k=1:1  %Bob: This looks worthless, but it is actually needed to use break in the if statements and still hit the foundtarget block
                        vec = [alarmLoc(i,1) - dataTemp(j).loc(2).east, alarmLoc(i,2) - dataTemp(j).loc(2).north];
                        dist1 = vec*dataTemp(j).n1';
                        dist2 = vec*dataTemp(j).n2';

                        if(dist1 > -halo && dist1 < dataTemp(j).dist1+halo && dist2 > 0 && dist2 < dataTemp(j).dist2)
                            foundTarget = true;
                            break;
                        end


                        if(dist2 > -halo && dist2 < dataTemp(j).dist2+halo && dist1 > 0 && dist1 < dataTemp(j).dist1)
                            foundTarget = true;
                            break;
                        end

                        %Test four corners
                        dist = [dataTemp(j).loc(1).east-alarmLoc(i,1), dataTemp(j).loc(1).north-alarmLoc(i,2)];
%                        dist = sqrt(sum(dist.*dist));
                        dist = sum(dist.*dist);
                        if(dist < haloSq)
                            foundTarget = true;
                            break;
                        end

                        dist = [dataTemp(j).loc(2).east-alarmLoc(i,1), dataTemp(j).loc(2).north-alarmLoc(i,2)];
%                        dist = sqrt(sum(dist.*dist));
                        dist = sum(dist.*dist);
                        if(dist < haloSq)
                            foundTarget = true;
                            break;
                        end

                        dist = [dataTemp(j).loc(3).east-alarmLoc(i,1), dataTemp(j).loc(3).north-alarmLoc(i,2)];
%                        dist = sqrt(sum(dist.*dist));
                        dist = sum(dist.*dist);
                        if(dist < haloSq)
                            foundTarget = true;
                            break;
                        end

                        dist = [dataTemp(j).loc(4).east-alarmLoc(i,1), dataTemp(j).loc(4).north-alarmLoc(i,2)];
%                        dist = sqrt(sum(dist.*dist));
                        dist = sum(dist.*dist);
                        if(dist < haloSq)
                            foundTarget = true;
                            break;
                        end
                    end
                elseif(targetList(j).convex)
                    foundTarget = true;
                    
                    for k=1:dataTemp(j).numMultiPoint
                        vec = [alarmLoc(i,1) - dataTemp(j).loc(k).east, alarmLoc(i,2) - dataTemp(j).loc(k).north];
                        if(vec*dataTemp(j).n(k,:)' < -halo) %scholl
                            foundTarget = false;
                            break;
                        end
                    end
                elseif(targetList(j).concave)
                    
                    for k=1:size(dataTemp(j).tri,1)
                        foundTarget = true;
                        
                        vec = [alarmLoc(i,1) - dataTemp(j).loc(dataTemp(j).tri(k,2)).east, alarmLoc(i,2) - dataTemp(j).loc(dataTemp(j).tri(k,1)).east];
                        if(vec*dataTemp(j).n(3*k-2,:)' < -halo)
                            foundTarget = false;
                        end
                        
                        vec = [alarmLoc(i,1) - dataTemp(j).loc(dataTemp(j).tri(k,3)).east, alarmLoc(i,2) - dataTemp(j).loc(dataTemp(j).tri(k,2)).east];
                        if(vec*dataTemp(j).n(3*k-1,:)' < -halo)
                            foundTarget = false;
                        end
                        
                        vec = [alarmLoc(i,1) - dataTemp(j).loc(dataTemp(j).tri(k,1)).east, alarmLoc(i,2) - dataTemp(j).loc(dataTemp(j).tri(k,3)).east];
                        if(vec*dataTemp(j).n(3*k,:)' < -halo)
                            foundTarget = false;
                        end
                        
                        if(foundTarget)
                            break;
                        end
                    end
                else %It's a point target.
                    dist = [dataTemp(j).center.east-alarmLoc(i,1), dataTemp(j).center.north-alarmLoc(i,2)];
%                    dist = sqrt(sum(dist.*dist));
                    dist = sum(dist.*dist);
                    if(dist < haloSq)
                        foundTarget = true;
                    end
                end
                    
                if(foundTarget)
                    switch(confuserScore(dataTemp(j).targetCategory))
                        case 0
                            targetFound(dataTemp(j).index) = true;
                            if(alarmConf(i) > targetFoundConf(dataTemp(j).index))
                                targetFoundConf(dataTemp(j).index) = alarmConf(i);
                            end
                            falseAlarms(i) = 0;
                            alarmsToTarget(i) = dataTemp(j).index;
                        case 1
                        case 2
                            if(falseAlarms(i) == 1)
                                falseAlarms(i) = 2;
                                alarmsToTarget(i) = -1;
                            end
                    end
                end
            end
        end
    end
    
    return
    
    