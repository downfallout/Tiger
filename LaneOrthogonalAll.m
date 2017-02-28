function laneOrthog = LaneOrthogonalAll(data, meshTriData, meshTriNormData, meshTriDirData, quadLookupTri)
    
%    quadLookupTri = BuildQuadLookupTri(meshTriData, meshTriNormData);
    minX = floor(min(meshTriData(:,1)))-2;
    minY = floor(min(meshTriData(:,2)))-2;
    maxX = floor(max(meshTriData(:,1)))+1;
    maxY = floor(max(meshTriData(:,2)))+1;
    diffX = maxX-minX;
    diffY = maxY-minY;
    
    laneOrthog = zeros(size(data,1),4);
    
    for j=1:size(data,1)
        point = data(j,:);
        
        indX = floor(point(1) - minX);
        indY = floor(point(2) - minY);
        if(indX > 1 && indY > 1 && indX < diffX && indY < diffY)
            
            dataTemp = [quadLookupTri(indY-1,indX-1).data; quadLookupTri(indY-1,indX).data; quadLookupTri(indY-1,indX+1).data;...
                quadLookupTri(indY,indX-1).data; quadLookupTri(indY,indX).data; quadLookupTri(indY,indX+1).data;...
                quadLookupTri(indY+1,indX-1).data; quadLookupTri(indY+1,indX).data; quadLookupTri(indY+1,indX+1).data];
            
            normTemp = [quadLookupTri(indY-1,indX-1).norm; quadLookupTri(indY-1,indX).norm; quadLookupTri(indY-1,indX+1).norm;...
                quadLookupTri(indY,indX-1).norm; quadLookupTri(indY,indX).norm; quadLookupTri(indY,indX+1).norm;...
                quadLookupTri(indY+1,indX-1).norm; quadLookupTri(indY+1,indX).norm; quadLookupTri(indY+1,indX+1).norm];

            indTemp = [quadLookupTri(indY-1,indX-1).ind; quadLookupTri(indY-1,indX).ind; quadLookupTri(indY-1,indX+1).ind;...
                quadLookupTri(indY,indX-1).ind; quadLookupTri(indY,indX).ind; quadLookupTri(indY,indX+1).ind;...
                quadLookupTri(indY+1,indX-1).ind; quadLookupTri(indY+1,indX).ind; quadLookupTri(indY+1,indX+1).ind];
            
            foundPoint = false;
        
            for i=1:3:size(dataTemp,1)
                di = point - dataTemp(i,:);

                if(di*normTemp(i,:)' > 0)
                    di = point - dataTemp(i+1,:);
                    if(di*normTemp(i+1,:)' > 0)
                        di = point - dataTemp(i+2,:);
                        if(di*normTemp(i+2,:)' > 0)
                            laneOrthog(j,:) = reshape(meshTriDirData(indTemp(i):indTemp(i)+1,:)', 1, 4);
                            foundPoint = true;
                            break;
                        end
                    end
                end
            end
            
            if(~foundPoint)

                %It's not inside any of the triangles.  Find which one is closest.
                %I need to make this more robust
                for i=1:3:size(dataTemp,1)
                    di1 = point - dataTemp(i,:);
                    di2 = point - dataTemp(i+1,:);
                    di3 = point - dataTemp(i+2,:);

                    if((di1*normTemp(i,:)' > 0) + (di2*normTemp(i+1,:)' > 0) + (di3*normTemp(i+2,:)' > 0) == 2)
                        laneOrthog(j,:) = reshape(meshTriDirData(indTemp(i):indTemp(i)+1,:)', 1, 4);
                        break;
                    end
                end
            end
        end
    end