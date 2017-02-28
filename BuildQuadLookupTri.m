function quadLookup = BuildQuadLookupTri(data, norm)
    s=size(data);
    
    minX = floor(min(data(:,1)))-2;
    minY = floor(min(data(:,2)))-2;
    maxX = floor(max(data(:,1)))+1;
    maxY = floor(max(data(:,2)))+1;
    
    quadLookup(maxY-minY,maxX-minX).data = [];
    quadLookup(maxY-minY,maxX-minX).norm = [];
    quadLookup(maxY-minY,maxX-minX).ind = [];
    
    quadLookupNumCount = zeros(maxY-minY,maxX-minX);
    
    for i=1:3:s(1)
        minXTri = floor(min(data(i:i+2,1))-minX);
        minYTri = floor(min(data(i:i+2,2))-minY);
        maxXTri = floor(max(data(i:i+2,1))-minX);
        maxYTri = floor(max(data(i:i+2,2))-minY);
        
        quadLookupNumCount(minYTri:maxYTri,minXTri:maxXTri) = quadLookupNumCount(minYTri:maxYTri,minXTri:maxXTri)+1;
        
    end
    
    
    for j=1:maxX-minX
        for k=1:maxY-minY
            quadLookup(k, j).data = zeros(quadLookupNumCount(k, j)*3, 2);
            quadLookup(k, j).norm = zeros(quadLookupNumCount(k, j)*3, 2);
            quadLookup(k, j).ind = zeros(quadLookupNumCount(k, j)*3, 1);
        end
    end
    
    quadLookupNumCount = ones(maxY-minY,maxX-minX);
        
    for i=1:3:s(1)
        minXTri = floor(min(data(i:i+2,1))-minX);
        minYTri = floor(min(data(i:i+2,2))-minY);
        maxXTri = floor(max(data(i:i+2,1))-minX);
        maxYTri = floor(max(data(i:i+2,2))-minY);
        
        for j=minXTri:maxXTri
            for k=minYTri:maxYTri
                count = quadLookupNumCount(k,j);
                quadLookup(k, j).data(count:count+2,:) = data(i:i+2,:);
                quadLookup(k, j).norm(count:count+2,:) = norm(i:i+2,:);
                quadLookup(k, j).ind(count:count+2,:) = i;
            end
        end
        
        quadLookupNumCount(minYTri:maxYTri,minXTri:maxXTri) = quadLookupNumCount(minYTri:maxYTri,minXTri:maxXTri)+3;
    end