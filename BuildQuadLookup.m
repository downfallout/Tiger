function quadLookup = BuildQuadLookup(data,conf)
    s=size(data);
    
    minX = floor(min(data(1,:)))-2;
    minY = floor(min(data(2,:)))-2;
    maxX = floor(max(data(1,:)))+1;
    maxY = floor(max(data(2,:)))+1;
    
    quadLookup(maxY-minY,maxX-minX).data = [];
    quadLookup(maxY-minY,maxX-minX).conf = [];
    
    for i=1:s(2)
        indX = floor(data(1,i) - minX);
        indY = floor(data(2,i) - minY);
        quadLookup(indY, indX).data(:,end+1) = data(:,i);
        quadLookup(indY, indX).conf(1,end+1) = conf(i);
    end