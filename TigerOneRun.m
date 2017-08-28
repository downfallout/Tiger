function [pd, fa, targetFoundConf, confSort, indTrue, indFalse] = TigerOneRun(laneTruthFileName, groundTruthFileName, eleFileName, halo, saveOutName, confs, confuserScore, alarmOffset)
    
    maxConf = max(confs);
%    [targetList,clutterList,~,~,meshTriData,meshTriNormData, meshTriDirData] = ReadTru(groundTruthFileName);
    [~,meshTriData,meshTriNormData, meshTriDirData] = ReadASCLane(laneTruthFileName);
    quadLookupTri = BuildQuadLookupTri(meshTriData, meshTriNormData);
    targetList = ReadASCTargets(groundTruthFileName);
    
    totalArea = 0;
    for i=1:3:size(meshTriData,1)
        tempVec1 = [meshTriData(i+1,1:2)-meshTriData(i,1:2) 0];
        tempVec2 = [meshTriData(i+2,1:2)-meshTriData(i,1:2) 0];

        totalArea = totalArea + max(cross(tempVec1,tempVec2))/2;
    end
    
    if(strcmp(eleFileName(end-2:end),'alm'))
        alarmData = ReadAlb([eleFileName(1:end-1) 'b']);
        if(isempty(alarmData))
            alarmData = ReadAlm(eleFileName);
        end
    elseif(strcmp(eleFileName(end-2:end),'alb'))
        alarmData = ReadAlb(eleFileName);
    end
    
    laneOrthog = LaneOrthogonalAll([alarmData{3}(:) alarmData{2}(:)], meshTriData, meshTriNormData, meshTriDirData, quadLookupTri);
    offset = laneOrthog(:,1:2)*alarmOffset(1)+laneOrthog(:,3:4)*alarmOffset(2);
    alarmData{3}(:) = alarmData{3}(:) + offset(:,1);
    alarmData{2}(:) = alarmData{2}(:) + offset(:,2);
    
    badInds = ~PointIsInLaneAll([alarmData{3}(:) alarmData{2}(:)], meshTriData, meshTriNormData, quadLookupTri);
    
    alarmData{1}(badInds) = [];
    alarmData{2}(badInds) = [];
    alarmData{3}(badInds) = [];
    alarmData{4}(badInds) = [];
    
    offset = MissAnalysis([alarmData{3} alarmData{2}], alarmData{4}, targetList, confuserScore, halo, meshTriData, meshTriNormData, meshTriDirData);

    goodInds = sqrt(offset(:,1).*offset(:,1) +offset(:,2).*offset(:,2))<3*halo;
    figure(90);
    scatter(offset(goodInds,1), offset(goodInds,2), 15, min(1,log(alarmData{4}(goodInds)+1)/log(maxConf+1)), 'filled')
    
    [targetFound, falseAlarms, targetFoundConf, alarmsToTarget] = ScoreAlarmsTry([alarmData{3} alarmData{2}], alarmData{4}, targetList, confuserScore, halo);
    
    for i=length(targetList):-1:1
        if(confuserScore(targetList(i).targetCategory) ~= 0)
            targetList(i) = [];
        end
    end
    
    trueTargets = false(1,length(targetList));
    for i=1:length(targetList)
        if(confuserScore(targetList(i).targetCategory) == 0)
            trueTargets(i) = true;
        end
    end
    
    numTrueTargets = sum(trueTargets);
    [confSort, indSort] = sort(alarmData{4}, 'descend');
    if(nargin == 4)
        pd = zeros(1,length(alarmData{4})+1);
        fa = zeros(1,length(alarmData{4})+1);
        for i = 1:length(confSort)
            pd(i+1) = length(RemoveVal(unique(alarmsToTarget(indSort(1:i))),0))/length(targetFound);
            fa(i+1) = sum(alarmsToTarget(indSort(1:i)) == 0)/totalArea;
        end
    else
        pd = zeros(1,length(confs)+1);
        fa = zeros(1,length(confs)+1);
        for j = 1:length(confs)
            i = sum((confSort >= confs(j)));
            pd(j+1) = sum(targetFoundConf(trueTargets) >= confs(j))/numTrueTargets;
            fa(j+1) = sum(alarmsToTarget(indSort(1:i)) == 0)/totalArea;
        end
    end
    
    indTrue = find(falseAlarms(indSort)==0);
    indFalse = find(falseAlarms(indSort)==1);
    
    if(isempty(saveOutName))
        return;
    end
    
    
    
    %Bob: All of this stuff is for creating figures on a per run basis.
    
    range = confSort(1) - confSort(end);
    step = range/10;
    
    histFalse = zeros(1,10);
    histTrue = zeros(1,10);
    for i=1:9
        histFalse(i) = sum((confSort(indFalse) >= confSort(end)+step*(i-1)) & (confSort(indFalse) < confSort(end)+step*i))/length(confSort);
        histTrue(i) = sum((confSort(indTrue) >= confSort(end)+step*(i-1)) & (confSort(indTrue) < confSort(end)+step*i))/length(confSort);
    end
    
    i=10;
    
    histFalse(i) = sum((confSort(indFalse) >= confSort(end)+step*(i-1)) & (confSort(indFalse) <= confSort(end)+step*i))/length(confSort);
    histTrue(i) = sum((confSort(indTrue) >= confSort(end)+step*(i-1)) & (confSort(indTrue) <= confSort(end)+step*i))/length(confSort);
    
    
    fi=figure(7);
    clf;
    plot(confSort(end)+step*(0:9),histTrue,confSort(end)+step*(0:9),histFalse,'r');
    if(~isempty(saveOutName))
        saveas(fi,['Output\' saveOutName '_ConfHistNorm.fig']);
    end
    
    for i=1:9
        histFalse(i) = sum((confSort(indFalse) >= confSort(end)+step*(i-1)) & (confSort(indFalse) < confSort(end)+step*i))/length(indFalse);
        histTrue(i) = sum((confSort(indTrue) >= confSort(end)+step*(i-1)) & (confSort(indTrue) < confSort(end)+step*i))/length(indTrue);
    end
    
    i=10;
    
    histFalse(i) = sum((confSort(indFalse) >= confSort(end)+step*(i-1)) & (confSort(indFalse) <= confSort(end)+step*i))/length(indFalse);
    histTrue(i) = sum((confSort(indTrue) >= confSort(end)+step*(i-1)) & (confSort(indTrue) <= confSort(end)+step*i))/length(indTrue);
    
    fi=figure(6);
    clf;
    plot(confSort(end)+step*(0:9),histTrue,confSort(end)+step*(0:9),histFalse,'r');
    if(~isempty(saveOutName))
        saveas(fi,['Output\' saveOutName '_ConfHist.fig']);
    end
    
    fi=figure(5);
    clf;
    plot(indFalse, confSort(indFalse),'r*', 'MarkerSize', 5);hold on; plot(indTrue,confSort(indTrue),'.b');
    xlabel('Alarm Index (Sorted)');
    ylabel('Alarm Confidence');
    if(~isempty(saveOutName))
        saveas(fi,['Output\' saveOutName '_ConfSort.fig']);
    end
    
    fi=figure(4);
    clf;
%    colormap([0,0,0;1,0,0]);
    colormap(hot);
    hold on;
    PlotTris(meshTriData);
    PlotTargets(targetList);

%    plot(alarmData{3}, alarmData{2},'.r');
%    plot(alarmData{3}(~falseAlarms), alarmData{2}(~falseAlarms),'*g');
    falseAlarmsInds = falseAlarms==1;
    scatter(alarmData{3}(falseAlarmsInds), alarmData{2}(falseAlarmsInds), 20, min(1,alarmData{4}(falseAlarmsInds)/max(alarmData{4}(:))))
    scatter(alarmData{3}(~falseAlarmsInds), alarmData{2}(~falseAlarmsInds), 15, min(1,alarmData{4}(~falseAlarmsInds)/max(alarmData{4}(:))), 'filled')
    
    PlotTargetsType(targetList);
 
    xlabel('Easting');
    ylabel('Northing');
    axis equal;
    
    if(~isempty(saveOutName))
        saveas(fi,['Output\' saveOutName '_Map.fig']);
    end
    
    if(0)
        fi=figure(2);
        clf;
        plot(fa,pd); axis([0 .1 0 1]);
        xlabel('FAR (Alarms/m^2)');
        ylabel('PD');
        if(~isempty(saveOutName))
            saveas(fi,['Output\' saveOutName '_ROC_0-20.fig']);
        end
    end
    
    fi=figure(1);
    clf;
%    plot(fa,pd); axis([0 fa(end) 0 1]);
%    plot(fa,pd); axis([0 max(1, fa(end)) 0 1]);
    plot(fa,pd); axis([0 .1 0 1]);
    title(sprintf('ROC Halo:%.2f Target Type Scoring %d %d %d %d',halo, confuserScore(1), confuserScore(2), confuserScore(3), confuserScore(4)))
    xlabel('FAR (Alarms/m^2)');
    ylabel('PD');
    if(~isempty(saveOutName))
        saveas(fi,['Output\' saveOutName '_ROC.fig']);
    end
    
    fi = figure(91);
    clf;
%    colormap([0,0,0;1,0,0]);
    colormap(hot);
    hold on;
    rectangle('Position',[-halo -halo 2*halo 2*halo],'Curvature',[1 1]);
    axis equal;
    axis([-2*halo 2*halo -2*halo 2*halo]);
    scatter(offset(goodInds,1), offset(goodInds,2), 15, min(1,log(alarmData{4}(goodInds)+1)/log(maxConf+1)), 'filled')
    ylabel('Drive Direction');
    xlabel('Cross Track Direction');
    if(~isempty(saveOutName))
        saveas(fi,['Output\' saveOutName '_Offsets.fig']);
    end
    