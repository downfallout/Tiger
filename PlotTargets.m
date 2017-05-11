function PlotTargets(targetList,e,n)
    if(nargin == 1)
        e = 0;
        n = 0;
    end

    for ind=1:length(targetList)
        if(targetList(ind).rectangle)
            dat = [[targetList(ind).loc(1).east targetList(ind).loc(2).east targetList(ind).loc(3).east targetList(ind).loc(4).east targetList(ind).loc(1).east]; [targetList(ind).loc(1).north targetList(ind).loc(2).north targetList(ind).loc(3).north targetList(ind).loc(4).north targetList(ind).loc(1).north]];
            plot(dat(1,:)-e, dat(2,:)-n,'b');
            hold on;
%            plot(targetList(ind).center.east-e, targetList(ind).center.north-n,'*b');
        elseif(targetList(ind).convex || targetList(ind).concave)
            dat = zeros(2, length(targetList(ind).loc)+1);
            for i=1:length(targetList(ind).loc)
                dat(:,i) = [targetList(ind).loc(i).east; targetList(ind).loc(i).north]; 
            end
            dat(:,end) = [targetList(ind).loc(1).east; targetList(ind).loc(1).north];
            plot(dat(1,:)-e, dat(2,:)-n,'b');
            hold on;
%            plot(targetList(ind).center.east-e, targetList(ind).center.north-n,'*b');
        elseif(targetList(ind).isWire)
            plot([targetList(ind).loc(1).east targetList(ind).loc(2).east]-e, [targetList(ind).loc(1).north targetList(ind).loc(2).north]-n,'b');
            hold on;
            plot([targetList(ind).loc(1).east targetList(ind).loc(2).east]-e, [targetList(ind).loc(1).north targetList(ind).loc(2).north]-n,'.c');
        else
            plot(targetList(ind).loc(1).east-e, targetList(ind).loc(1).north-n,'*b');
            hold on;
        end
    end