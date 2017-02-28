%Function: AUC
%Normalized area under the curve.
%
%Inputs
%fileName: File name of Tiger output directory
%maxFA: Maximum false alarm rate allowed for area under the curve.
%
%or
%
%allFA: False alarm array returned by Tiger.
%allPD: Probability of detection array returned by Tiger.
%maxFA: Maximum false alarm rate allowed for area under the curve.
%
%Outputs
%allAUC: Float array values between [0 1].  Area under each curve.
%
%Usage
%allAUC = AUC('PreviousTigerOutputDirectory', .01)
%or
%allAUC = AUC(allFA, allPD, .01)
%
function allAUC = AUC(varargin)

    switch(size(varargin,2))
        case 2
            fileName = varargin{1};
            maxFA = varargin{2};
            load(['Output\' fileName '\Variables.mat'])
            allAUC = AUC(allFA, allPD, maxFA);
    
        case 3
            allFA = varargin{1};
            allPD = varargin{2};
            maxFA = varargin{3};
            
            allAUC = zeros(size(allFA,1), 1);

            for i=1:size(allAUC,1)
                j=1;
                lastFA = 0;
                lastPD = 0;
                while(j <= size(allFA,2))
                    if(allFA(i,j) ~= lastFA)
                        x = allFA(i,j)-lastFA;
                        allAUC(i) = allAUC(i) + x*lastPD + x*(allPD(i,j)-lastPD)/2;
                    end
                    lastFA = allFA(i,j);
                    lastPD = allPD(i,j);
                    j=j+1;
                    if(allFA(i,j) > maxFA)
                        x = allFA(i,j)-maxFA;
                        slope = (allPD(i,j)-lastPD)/(allFA(i,j)-lastFA);
                        y = x*slope;
                        allAUC(i) = allAUC(i) + x*lastPD + x*(y-lastPD)/2;
                        break;
                    end
                end
            end

            allAUC = allAUC/maxFA;
    end
