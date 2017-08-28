function laneOrthog = LaneOrthogonal(point, meshTriData, meshTriNormData, meshTriDirData)
    s = size(meshTriData);
    
    for i=1:3:s(1)
        di = point - meshTriData(i,1:2);
        
        if(di*meshTriNormData(i,:)' > 0)
            di = point - meshTriData(i+1,1:2);
            if(di*meshTriNormData(i+1,:)' > 0)
                di = point - meshTriData(i+2,1:2);
                if(di*meshTriNormData(i+2,:)' > 0)
                    laneOrthog = meshTriDirData(i:i+2,:);
                    return;
                end
            end
        end
    end
    
    %It's not inside any of the triangles.  Find which one is closest.
    %I need to make this more robust
    for i=1:3:s(1)
        di1 = point - meshTriData(i,1:2);
        di2 = point - meshTriData(i+1,1:2);
        di3 = point - meshTriData(i+2,1:2);
        
        if((di1*meshTriNormData(i,:)' > 0) + (di2*meshTriNormData(i+1,:)' > 0) + (di3*meshTriNormData(i+2,:)' > 0) == 2)
                laneOrthog = meshTriDirData(i:i+2,:);
            return;
        end
    end
    