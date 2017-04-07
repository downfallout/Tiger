function [allPD, allFA, allConfsSorted, targetFoundConf] = Tiger(fileNameConfig, saveName)
    %Test
    if(nargin == 1)
        saveName = [];
    else
        d = dir(['Output\' saveName]);
        if(isempty(d))
            mkdir(['Output\' saveName]);
        end
    end
    
    [fileNameTiger, numFiles, halo, alarmOffset, targetCategoryScore] = ReadTigerConfig(['Config\' fileNameConfig]);
    
    allConfs = [];
    
    figure(100);
    clf;
    hold on;
    for i=1:numFiles
        if(strcmp(fileNameTiger{3}{i}(end-2:end),'alm'))
            alarmData = ReadAlb(['Alarms\' fileNameTiger{3}{i}(1:end-1) 'b']);
            if(isempty(alarmData))
                alarmData = ReadAlm(['Alarms\' fileNameTiger{3}{i}]);
            end
        elseif(strcmp(fileNameTiger{3}{i}(end-2:end),'alb'))
            alarmData = ReadAlb(['Alarms\' fileNameTiger{3}{i}]);
        end
        
%        [~,~,~,~,meshTriData,meshTriNormData] = ReadTru(fileNameTiger{1}{i});
        [~,meshTriData,meshTriNormData, meshTriDirData] = ReadASCLane(['GroundTruth\' fileNameTiger{1}{i}]);
        
        quadLookupTri = BuildQuadLookupTri(meshTriData, meshTriNormData);
        
        if(alarmOffset(1) ~= 0 || alarmOffset(2) ~= 0)
            laneOrthog = LaneOrthogonalAll([alarmData{3}(:) alarmData{2}(:)], meshTriData, meshTriNormData, meshTriDirData,quadLookupTri);
            offset = laneOrthog(:,1:2)*alarmOffset(1)+laneOrthog(:,3:4)*alarmOffset(2);
            alarmData{3}(:) = alarmData{3}(:) + offset(:,1);
            alarmData{2}(:) = alarmData{2}(:) + offset(:,2);
        end

        badInds = ~PointIsInLaneAll([alarmData{3}(:) alarmData{2}(:)], meshTriData, meshTriNormData, quadLookupTri);
        
        alarmData{1}(badInds) = [];
        alarmData{2}(badInds) = [];
        alarmData{3}(badInds) = [];
        alarmData{4}(badInds) = [];
        allConfs = [allConfs; alarmData{4}];
        
        
%        colormap([0,0,0;1,0,0]);
        colormap(hot);
        scatter(alarmData{3}(:), alarmData{2}(:), 15, min(1,alarmData{4}(:)/max(alarmData{4}(:))), 'filled')
%        plot(alarmData{3}(:), alarmData{2}(:), '.', 'Color', hsv2rgb([(i-1)/numFiles 1 1]));

        targetList = ReadASCTargets(['GroundTruth\' fileNameTiger{2}{i}]);
        PlotTargets(targetList);
        PlotTargetsType(targetList);
    end
%    targetList = ReadASCTargets(['GroundTruth\' fileNameTiger{2}{1}]);
    PlotTris(meshTriData);
%    PlotTargets(targetList);
%    PlotTargetsType(targetList);
    axis equal;
    
    allConfsSorted = sort(unique(allConfs), 'descend');
    
    allPD = zeros(numFiles,length(allConfsSorted)+1);
    allFA = zeros(numFiles,length(allConfsSorted)+1);
    
    figure(90);
    clf;
%    colormap([0,0,0;1,0,0]);
    colormap(hot);
    hold on;
    rectangle('Position',[-halo -halo 2*halo 2*halo],'Curvature',[1 1]);
    axis equal;
    axis([-2*halo 2*halo -2*halo 2*halo]);
    ylabel('Drive Direction');
    xlabel('Cross Track Direction');
    for i=1:numFiles
        fprintf('Processing %s...',fileNameTiger{3}{i});
        if(isempty(saveName))
            [allPD(i,:), allFA(i,:), targetFoundConf(i,:), confSort{i}, indTrue{i}, indFalse{i}] = TigerOneRun(['GroundTruth\' fileNameTiger{1}{i}], ['GroundTruth\' fileNameTiger{2}{i}], ['Alarms\' fileNameTiger{3}{i}], halo, [], allConfsSorted, targetCategoryScore, alarmOffset);
        else
            [allPD(i,:), allFA(i,:), targetFoundConf(i,:), confSort{i}, indTrue{i}, indFalse{i}] = TigerOneRun(['GroundTruth\' fileNameTiger{1}{i}], ['GroundTruth\' fileNameTiger{2}{i}], ['Alarms\' fileNameTiger{3}{i}], halo, [saveName '\' fileNameTiger{4}{i}], allConfsSorted, targetCategoryScore, alarmOffset);
        end
        fprintf('Done\n');
    end
    
    confSortAll = [];
    indTrueAll = [];
    indFalseAll = [];
    for i=1:numFiles
        confSortAll = [confSortAll; confSort{i}(:)];
        indTrueAll = [indTrueAll; indTrue{i}(:)];
        indFalseAll = [indFalseAll; indFalse{i}(:)];
    end;
    
    maxConfSortAll = max(confSortAll);
    minConfSortAll = min(confSortAll);
    range = maxConfSortAll - minConfSortAll;
    step = range/10;
    
%    histFalse = zeros(1,10);
%    histTrue = zeros(1,10);
    
%    for i=1:9
%        histFalse(i) = sum((confSortAll(indFalseAll) >= minConfSortAll+step*(i-1)) & (confSortAll(indFalseAll) < minConfSortAll+step*i))/length(indFalseAll);
%        histTrue(i) = sum((confSortAll(indTrueAll) >= minConfSortAll+step*(i-1)) & (confSortAll(indTrueAll) < minConfSortAll+step*i))/length(indTrueAll);
%    end
    
%    i=10;
    
%    histFalse(i) = sum((confSortAll(indFalseAll) >= minConfSortAll+step*(i-1)) & (confSortAll(indFalseAll) < minConfSortAll+step*i))/length(indFalseAll);
%    histTrue(i) = sum((confSortAll(indTrueAll) >= minConfSortAll+step*(i-1)) & (confSortAll(indTrueAll) < minConfSortAll+step*i))/length(indTrueAll);
    
    
    fi=figure(7);
    clf;
%    plot(confSortAll(end)+step*(0:9),histTrue,confSortAll(end)+step*(0:9),histFalse,'r');
    histTrue = hist(confSortAll(indTrueAll), confSortAll(end)+step*(0:9));
    histFalse = hist(confSortAll(indFalseAll), confSortAll(end)+step*(0:9));
    bar(confSortAll(end)+step*(0:9),[histTrue'/sum(histTrue) histFalse'/sum(histFalse)], 'hist');
    xlabel('Alarm Confidence');
    ylabel('Percentage');
    legend('Target Alarms', 'False Alarms');
%    if(~isempty(saveOutName))
%        saveas(f,[saveOutName '_ConfHistNormAll.fig']);
%    end
    
    fi=figure(8);
    clf;
    s = size(targetFoundConf);
    detectFARate = zeros(s);
    for i=1:s(1)
        for j=1:s(2)
            if(targetFoundConf(i,j) ~=-100000)
                inds = sum(allConfsSorted >= targetFoundConf(i,j));
                detectFARate(i,j) = allFA(i,inds+1);
            else
                detectFARate(i,j) = -1;
            end;
        end;
    end;
    
    detectFARateImage = detectFARate;
    detectFARateImage(detectFARateImage == -1) = max(detectFARateImage(:));
%    imagesc(detectFARate, [0 .1]);
    imagesc(detectFARateImage);
%    colormap([linspace(0,1,300)', linspace(0,1,300)', linspace(0,1,300)']);
    colormap(hot);
    hold on;
    for i=1:s(1)
        for j=1:s(2)
            if(targetFoundConf(i,j) == -100000)
%                text(j-.25,i,'N/A','Color','white');
                text(j-.25,i,'N/A');
            else
%                text(j,i,sprintf('%.5f',detectFARate(i,j)));
            end;
        end;
    end;%Put text on each pixel
    
    if(~isempty(saveName))
        saveas(fi,['Output\' saveName '\TargetHitFARTable.fig']);
    end

    if(0)
        s = size(targetFoundConf);
        meanFA = mean(allFA,1);
    %    stepSize = max(allFA(allFA>min(targetFoundConf(:))))/100;
        stepSize = .0001;
    %    numFARIndex = ceil(max(allFA(:, find(allConfsSorted>min(targetFoundConf(targetFoundConf > 0)), 1, 'last')))/stepSize);
        numFARIndex = .1/stepSize;
        confList = zeros(1,numFARIndex);
        for i = 1:numFARIndex
            if(isempty(allConfsSorted(meanFA(2:end) < stepSize*i))) %THIS IS A BAD HACK FOR NOW
                confList(i) = max(allConfsSorted);
            else
                confList(i) = min(allConfsSorted(meanFA(2:end) < stepSize*i));
            end
        end;
        confCube = repmat(confList', [1 s(2) s(1)]);
        targetFoundConfCube = repmat(permute(targetFoundConf, [3 2 1]), [numFARIndex 1 1]);

        fi=figure(3);
        imagesc(sum(targetFoundConfCube >= confCube, 3))
        xlabel('TargetID');
        ylabel('FAR Alarms/m^2');
        if(numFARIndex > 100) %Bob: This is a hack and I need to fix it.
            for i=1:floor(numFARIndex/100)
                tickYNames{i,1} = sprintf('%f',i*.01);
            end;
            set(gca,'YTick',100:100:numFARIndex);
            set(gca,'YTickLabel',tickYNames);
        end
        if(~isempty(saveName))
            saveas(fi,['Output\' saveName '\TargetHitTable.fig']);
        end
    end
    
    fi=figure(2);
    clf;
    indTrueAll = [];
    indFalseAll = [];
    confSortAll = [];
    ind = 0;
    for i=1:numFiles
        confSortAll = [confSortAll; confSort{i}]; 
        indTrueAll = [indTrueAll indTrue{i}+ind];
        indFalseAll = [indFalseAll indFalse{i}+ind];
        ind = ind + length(confSort{i});
    end;
    [confSortAll2, ind2] = sort(confSortAll,'descend');
    trueInds = zeros(size(confSortAll));
    trueInds(indTrueAll) = 1;
    falseInds = zeros(size(confSortAll));
    falseInds(indFalseAll) = 1;
    trueIndsSort = find(trueInds(ind2));
    falseIndsSort = find(falseInds(ind2));
    plot(falseIndsSort, confSortAll2(falseIndsSort),'r*', 'MarkerSize', 5);hold on; plot(trueIndsSort,confSortAll2(trueIndsSort),'.b');
    xlabel('Alarm Index (Sorted)');
    ylabel('Alarm Confidence');
    legend('False Alarms', 'Target Hits');
    if(~isempty(saveName))
        saveas(fi,['Output\' saveName '\ConfSort.fig']);
    end
    
    fi=figure(1);
    clf;
%    plot(allFA',allPD',mean(allFA,1),mean(allPD,1),'--'); axis([0 max(.000001, max(allFA(:,end))) 0 1]);
    plot(allFA',allPD',mean(allFA,1),mean(allPD,1),'--'); axis([0 .05 0 1]);
    title(sprintf('ROC Halo:%.2f Target Type Scoring %d %d %d %d',halo, targetCategoryScore(1), targetCategoryScore(2), targetCategoryScore(3), targetCategoryScore(4)))
    xlabel('FAR (Alarms/m^2)');
    ylabel('PD');
    for i=1:size(fileNameTiger{1},1)
%        legendData{i,1} = [ReplaceChar(fileNameTiger{1}{i},'_','-'), ' ',ReplaceChar(fileNameTiger{2}{i},'_','-'), ' ', fileNameTiger{3}{i}];
%        legendData{i,1} = [fileNameTiger{1}{i}, ' ',fileNameTiger{2}{i}, ' ', ReplaceChar(fileNameTiger{3}{i},'_','-')];
        legendData{i,1} = [ReplaceChar(fileNameTiger{1}{i},'_','-'), ' ',ReplaceChar(fileNameTiger{2}{i},'_','-'), ' ', ReplaceChar(fileNameTiger{3}{i},'_','-')];
    end;
    legendData{i+1,1} = 'Average';
    legend(legendData);
    if(~isempty(saveName))
        saveas(fi,['Output\' saveName '\ROC.fig']);
    end
    
    setupNames = fileNameTiger{4};
    
    if(~isempty(saveName))
        save(['Output\' saveName '\Variables.mat'], 'allPD', 'allFA', 'allConfsSorted', 'targetFoundConf', 'detectFARate', 'setupNames');
    end
    
    fi = figure(90);
    
    if(~isempty(saveName))
        saveas(fi,['Output\' saveName '\Offsets.fig']);
    end