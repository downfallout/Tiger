function [triListX, triListY, colorTri] = ScanHeaders2Tris(scanHeaders,data)

    s = size(scanHeaders);
    
    n = [scanHeaders(:,4) - scanHeaders(:,3), scanHeaders(:,6) - scanHeaders(:,5)];
    no = sqrt(sum(n.^2,2));
    n = n./repmat(no,1,2);
    scanHeaders(:,3) = scanHeaders(:,3) - .3*n(:,1);
    scanHeaders(:,4) = scanHeaders(:,4) - .3*n(:,1);
    scanHeaders(:,5) = scanHeaders(:,5) - .3*n(:,2);
    scanHeaders(:,6) = scanHeaders(:,6) - .3*n(:,2);
    
    triListX = zeros(3,s(1)*s(2)*2);
    triListY = zeros(3,s(1)*s(2)*2);
    colorTri = zeros(1,s(1)*s(2)*2);
    
    for i=1:s(1)-1
        n1 = [scanHeaders(i,6)-scanHeaders(i,5), scanHeaders(i,4)-scanHeaders(i,3)];
        no = sqrt(sum(n1.^2));
        n1 = n1/no;
        n2 = [scanHeaders(i+1,5)-scanHeaders(i,5), scanHeaders(i+1,3)-scanHeaders(i,3)];
        n3 = [scanHeaders(i+1,6)-scanHeaders(i,6), scanHeaders(i+1,4)-scanHeaders(i,4)];
        
        leftSide = [scanHeaders(i,5), scanHeaders(i,3)];
        
        for j=1:s(2)
            point1 = leftSide+no*((j-1)/s(2))*n1;
            point2 = leftSide+no*(j/s(2))*n1;
            point3 = leftSide+no*(j/s(2))*n1+(1-j/s(2))*n2+(j/s(2))*n3;
            point4 = leftSide+no*((j-1)/s(2))*n1+(1-(j-1)/s(2))*n2+((j-1)/s(2))*n3;
            
            triListX(:,2*(i-1)*s(2)+2*(j-1)+1) = [point1(1);
                                        point2(1);
                                        point3(1)];
            triListX(:,2*(i-1)*s(2)+2*(j-1)+2) = [point1(1);
                                        point3(1);
                                        point4(1)];
            triListY(:,2*(i-1)*s(2)+2*(j-1)+1) = [point1(2);
                                        point2(2);
                                        point3(2)];
            triListY(:,2*(i-1)*s(2)+2*(j-1)+2) = [point1(2);
                                        point3(2);
                                        point4(2)];
                                    
            colorTri(:,2*(i-1)*s(2)+2*(j-1)+1) = data(j,i);
            colorTri(:,2*(i-1)*s(2)+2*(j-1)+2) = data(j,i);
        end
    end
    
    i=s(1);
    
    n1 = [scanHeaders(i,6)-scanHeaders(i,5), scanHeaders(i,4)-scanHeaders(i,3)];
    no = sqrt(sum(n1.^2));
    n1 = n1/no;
    n2 = [-n1(2), n1(1)];

    leftSide = [scanHeaders(i,5), scanHeaders(i,3)];
    
    for j=1:s(2)
        point1 = leftSide+3.2*((j-1)/s(2))*n1;
        point2 = leftSide+3.2*(j/s(2))*n1;
        point3 = leftSide+3.2*(j/s(2))*n1+.05*n2;
        point4 = leftSide+3.2*((j-1)/s(2))*n1+.05*n2;

        triListX(:,2*(i-1)*s(2)+2*(j-1)+1) = [point1(1);
                                    point2(1);
                                    point3(1)];
        triListX(:,2*(i-1)*s(2)+2*(j-1)+2) = [point1(1);
                                    point3(1);
                                    point4(1)];
        triListY(:,2*(i-1)*s(2)+2*(j-1)+1) = [point1(2);
                                    point2(2);
                                    point3(2)];
        triListY(:,2*(i-1)*s(2)+2*(j-1)+2) = [point1(2);
                                    point3(2);
                                point4(2)];
        colorTri(:,2*(i-1)*s(2)+2*(j-1)+1) = data(j,i);
        colorTri(:,2*(i-1)*s(2)+2*(j-1)+2) = data(j,i);
    end
    