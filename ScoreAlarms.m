function [targetFound, falseAlarms, targetFoundConf, alarmsToTarget] = ScoreAlarms(alarmLoc, alarmConf, targetList, confuserScore, halo)
    s = size(alarmLoc);
    targetFound = false(1, length(targetList(1).data));
    targetFoundConf = -100000*ones(1, length(targetList(1).data));
    falseAlarms = ones(1, s(1));
    alarmsToTarget = zeros(1, s(1));
    for i=1:s(1)
        if(confuserScore(3) == 2)
            for j=1:length(targetList(3).data)
                if(targetList(3).data(j).rectangle)
                    dist = [targetList(3).data(j).center.east-alarmLoc(i,1), targetList(3).data(j).center.north-alarmLoc(i,2)];
    %                dist = sqrt(sum(dist.*dist));
                    if(max(abs(dist)) < 2) % Quick check to throw out most points
                        %Test two main directions
    %                    vec1 = [alarmLoc(i,1) - targetList(3).data(j).loc(1).east, alarmLoc(i,2) - targetList(3).data(j).loc(1).north];
    %                    vec2 = [alarmLoc(i,1) - targetList(3).data(j).loc(2).east, alarmLoc(i,2) - targetList(3).data(j).loc(2).north];
    %                    dist1 = vec1*targetList(3).data(j).n1';
    %                    dist2 = vec2*targetList(3).data(j).n2';

                        vec = [alarmLoc(i,1) - targetList(3).data(j).loc(2).east, alarmLoc(i,2) - targetList(3).data(j).loc(2).north];
                        dist1 = vec*targetList(3).data(j).n1';
                        dist2 = vec*targetList(3).data(j).n2';

                        if(dist1 > -halo && dist1 < targetList(3).data(j).dist1+halo && dist2 > 0 && dist2 < targetList(3).data(j).dist2)
                            falseAlarms(i) = 2;
                            continue;
                        end


                        if(dist2 > -halo && dist2 < targetList(3).data(j).dist2+halo && dist1 > 0 && dist1 < targetList(3).data(j).dist1)
                            falseAlarms(i) = 2;
                            continue;
                        end

                        %Test four corners
                        dist = [targetList(3).data(j).loc(1).east-alarmLoc(i,1), targetList(3).data(j).loc(1).north-alarmLoc(i,2)];
                        dist = sqrt(sum(dist.*dist));
                        if(dist < halo)
                            falseAlarms(i) = 2;
                            continue
                        end

                        dist = [targetList(3).data(j).loc(2).east-alarmLoc(i,1), targetList(3).data(j).loc(2).north-alarmLoc(i,2)];
                        dist = sqrt(sum(dist.*dist));
                        if(dist < halo)
                            falseAlarms(i) = 2;
                            continue
                        end

                        dist = [targetList(3).data(j).loc(3).east-alarmLoc(i,1), targetList(3).data(j).loc(3).north-alarmLoc(i,2)];
                        dist = sqrt(sum(dist.*dist));
                        if(dist < halo)
                            falseAlarms(i) = 2;
                            continue
                        end

                        dist = [targetList(3).data(j).loc(4).east-alarmLoc(i,1), targetList(3).data(j).loc(4).north-alarmLoc(i,2)];
                        dist = sqrt(sum(dist.*dist));
                        if(dist < halo)
                            falseAlarms(i) = 2;
                            continue
                        end
                    end
                elseif(targetList(3).data(j).isWire)

                        vec = [alarmLoc(i,1) - targetList(3).data(j).loc(1).east, alarmLoc(i,2) - targetList(3).data(j).loc(1).north];
    %                    dist1 = vec*targetList(3).data(j).n1';
                        dist2 = vec*targetList(3).data(j).n1';

                        dist2 = max(0, min(targetList(3).data(j).dist1, dist2));

                        offset = alarmLoc(i,:) - ([targetList(3).data(j).loc(1).east targetList(3).data(j).loc(1).north] + (dist2*targetList(3).data(j).n1));
                        dist = sqrt(sum(offset.*offset));

                        if(dist < halo)
                            falseAlarms(i) = 2;
                            continue
                        end
                else
                    dist = [targetList(3).data(j).center.east-alarmLoc(i,1), targetList(3).data(j).center.north-alarmLoc(i,2)];
                    if(max(abs(dist)) < 2) % Quick check to throw out most points
    %                    dist = [targetList(3).data(j).loc.east-alarmLoc(i,1), targetList(3).data(j).loc.north-alarmLoc(i,2)];
                        dist = sqrt(sum(dist.*dist));
                        if(dist < halo)
                            falseAlarms(i) = 2;
                        end
                    end
                end
            end
        end
        
        %Now check Targets
        for j=1:length(targetList(1).data)
            if(targetList(1).data(j).rectangle)
                dist = [targetList(1).data(j).center.east-alarmLoc(i,1), targetList(1).data(j).center.north-alarmLoc(i,2)];
%                dist = sqrt(sum(dist.*dist));
                if(max(abs(dist)) < 2) % Quick check to throw out most points
                    %Test two main directions
%                    vec1 = [alarmLoc(i,1) - targetList(1).data(j).loc(1).east, alarmLoc(i,2) - targetList(1).data(j).loc(1).north];
%                    vec2 = [alarmLoc(i,1) - targetList(1).data(j).loc(2).east, alarmLoc(i,2) - targetList(1).data(j).loc(2).north];
%                    dist1 = vec1*targetList(1).data(j).n1';
%                    dist2 = vec2*targetList(1).data(j).n2';
                    
                    vec = [alarmLoc(i,1) - targetList(1).data(j).loc(2).east, alarmLoc(i,2) - targetList(1).data(j).loc(2).north];
                    dist1 = vec*targetList(1).data(j).n1';
                    dist2 = vec*targetList(1).data(j).n2';

                    if(dist1 > -halo && dist1 < targetList(1).data(j).dist1+halo && dist2 > 0 && dist2 < targetList(1).data(j).dist2)
                        targetFound(j) = true;
                        if(alarmConf(i) > targetFoundConf(j))
                            targetFoundConf(j) = alarmConf(i);
                        end
                        falseAlarms(i) = 0;
                        alarmsToTarget(i) = j;
                        continue;
                    end


                    if(dist2 > -halo && dist2 < targetList(1).data(j).dist2+halo && dist1 > 0 && dist1 < targetList(1).data(j).dist1)
                        targetFound(j) = true;
                        if(alarmConf(i) > targetFoundConf(j))
                            targetFoundConf(j) = alarmConf(i);
                        end
                        falseAlarms(i) = 0;
                        alarmsToTarget(i) = j;
                        continue;
                    end

                    %Test four corners
                    dist = [targetList(1).data(j).loc(1).east-alarmLoc(i,1), targetList(1).data(j).loc(1).north-alarmLoc(i,2)];
                    dist = sqrt(sum(dist.*dist));
                    if(dist < halo)
                        targetFound(j) = true;
                        if(alarmConf(i) > targetFoundConf(j))
                            targetFoundConf(j) = alarmConf(i);
                        end
                        falseAlarms(i) = 0;
                        alarmsToTarget(i) = j;
                        continue
                    end

                    dist = [targetList(1).data(j).loc(2).east-alarmLoc(i,1), targetList(1).data(j).loc(2).north-alarmLoc(i,2)];
                    dist = sqrt(sum(dist.*dist));
                    if(dist < halo)
                        targetFound(j) = true;
                        if(alarmConf(i) > targetFoundConf(j))
                            targetFoundConf(j) = alarmConf(i);
                        end
                        falseAlarms(i) = 0;
                        alarmsToTarget(i) = j;
                        continue
                    end

                    dist = [targetList(1).data(j).loc(3).east-alarmLoc(i,1), targetList(1).data(j).loc(3).north-alarmLoc(i,2)];
                    dist = sqrt(sum(dist.*dist));
                    if(dist < halo)
                        targetFound(j) = true;
                        if(alarmConf(i) > targetFoundConf(j))
                            targetFoundConf(j) = alarmConf(i);
                        end
                        falseAlarms(i) = 0;
                        alarmsToTarget(i) = j;
                        continue
                    end

                    dist = [targetList(1).data(j).loc(4).east-alarmLoc(i,1), targetList(1).data(j).loc(4).north-alarmLoc(i,2)];
                    dist = sqrt(sum(dist.*dist));
                    if(dist < halo)
                        targetFound(j) = true;
                        if(alarmConf(i) > targetFoundConf(j))
                            targetFoundConf(j) = alarmConf(i);
                        end
                        falseAlarms(i) = 0;
                        alarmsToTarget(i) = j;
                        continue
                    end
                end
            elseif(targetList(1).data(j).isWire)
                    
                    vec = [alarmLoc(i,1) - targetList(1).data(j).loc(1).east, alarmLoc(i,2) - targetList(1).data(j).loc(1).north];
%                    dist1 = vec*targetList(1).data(j).n1';
                    dist2 = vec*targetList(1).data(j).n1';
                    
                    dist2 = max(0, min(targetList(1).data(j).dist1, dist2));

                    offset = alarmLoc(i,:) - ([targetList(1).data(j).loc(1).east targetList(1).data(j).loc(1).north] + (dist2*targetList(1).data(j).n1));
                    dist = sqrt(sum(offset.*offset));
                    
                    if(dist < halo)
                        targetFound(j) = true;
                        if(alarmConf(i) > targetFoundConf(j))
                            targetFoundConf(j) = alarmConf(i);
                        end
                        falseAlarms(i) = 0;
                        alarmsToTarget(i) = j;
                        continue
                    end
            else
                dist = [targetList(1).data(j).center.east-alarmLoc(i,1), targetList(1).data(j).center.north-alarmLoc(i,2)];
                if(max(abs(dist)) < 2) % Quick check to throw out most points
%                    dist = [targetList(1).data(j).loc.east-alarmLoc(i,1), targetList(1).data(j).loc.north-alarmLoc(i,2)];
                    dist = sqrt(sum(dist.*dist));
                    if(dist < halo)
                        targetFound(j) = true;
                        if(alarmConf(i) > targetFoundConf(j))
                            targetFoundConf(j) = alarmConf(i);
                        end
                        falseAlarms(i) = 0;
                        alarmsToTarget(i) = j;
                    end
                end
            end
        end
    end