%Function: CompareDetectFARate
%Compare detectFARateImage between scorings.
%
%Inputs
%varargin: Names of Tiger output directories to compare.
%
%Outputs
%None.
%
%Usage
%CompareDetectFARate('PreviousTigerOutputDirectory1', 'PreviousTigerOutputDirectory2', [0 .01])
%
%or
%
%CompareDetectFARate('PreviousTigerOutputDirectory1', 'PreviousTigerOutputDirectory2', 'PreviousTigerOutputDirectory3', [0 .001])
%
function CompareDetectFARate(varargin)
    clf;
    detectFARateAll = [];
    names = {};
    for k = 1:size(varargin,2)-1
        load(['Output\' varargin{k} '\Variables.mat'])
        
        detectFARateAll = [detectFARateAll; detectFARate];
        
        names = cat(1,names, setupNames);
    end
    
    detectFARateImage = detectFARateAll;
    
    detectFARateImage(detectFARateImage == -1) = max(detectFARateImage(:));
    
    imagesc(detectFARateImage, varargin{end});
    
    set(gca,'ytick',1:size(names,1),'yticklabel',names)
    xlabel('Target Number');
    
    colormap(hot);
    hold on;
    
    s = size(detectFARateImage);
    for i=1:s(1)
        for j=1:s(2)
            if(detectFARateAll(i,j) == -1)
%                text(j-.25,i,'N/A','Color','white');
                text(j-.25,i,'N/A');
            else
%                text(j,i,sprintf('%.5f',detectFARate(i,j)));
            end;
        end;
    end;%Put text on each target not detected