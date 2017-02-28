function PlotTris(meshTriData,e,n)
    if(nargin == 1)
        e = 0;
        n = 0;
    end
    meshTriDataX = reshape(meshTriData(:,1),3,[])-e;
    meshTriDataY = reshape(meshTriData(:,2),3,[])-n;
%    p = patch(meshTriDataX,meshTriDataY,'b');
    p = patch(meshTriDataX,meshTriDataY,'b','FaceColor','none');
    