function PlotTargetsType(targetList,e,n)
    if(nargin == 1)
        e = 0;
        n = 0;
    end
    
    for ind=1:length(targetList)
        t = targetList(ind).type;
        t(t == '_') = ' ' ;
        t = [t ' ' num2str(targetList(ind).buriedDepth) ' ' num2str(targetList(ind).id)];
        text(targetList(ind).center.east-e, targetList(ind).center.north-n, t, 'Color', [0 0 0]);
    end