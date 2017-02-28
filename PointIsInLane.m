function inLane = PointIsInLane(point, meshTriData, meshTriNormData)
    s = size(meshTriData);
    inLane = false;
    
    for i=1:3:s(1)
        di = point - meshTriData(i,:);
        
        if(di*meshTriNormData(i,:)' > 0)
            di = point - meshTriData(i+1,:);
            if(di*meshTriNormData(i+1,:)' > 0)
                di = point - meshTriData(i+2,:);
                if(di*meshTriNormData(i+2,:)' > 0)
                    inLane = true;
                    return;
                end
            end
        end
    end
    
    