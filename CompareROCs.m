function CompareROCs(varargin)

    for k = 1:size(varargin,2)
        load(['Output\' varargin{k} '\Variables.mat'])
        plot(mean(allFA,1),mean(allPD,1), 'Color', hsv2rgb([(k-1)/size(varargin,2) 1 1]));
        hold on;
    %    plot(sort(data(:)));
    end
    xlabel('FAR (Alarms/m^2)');
    ylabel('PD');
    
    for i=1:size(varargin,2)
%        legendData{i,1} = ReplaceChar(varargin{i},'_','-');
        legendData{i,1} = StuffChar(varargin{i},'_');
    end;
    legend(legendData);