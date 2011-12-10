function [ wordSim ] = wordRecordSimilarity(wordRecord1, wordRecord2)

% Compute the wordSim of two word records
% Similarity is computed as an average of
% cross-correlation results over the window sets of the two word records


filterStack1=getField(wordRecord1, 'filterStack');
filterStack2=getField(wordRecord2, 'filterStack');
simArray=[];

for filterIndex=1:length(filterStack1)
    
    windowList1=filterStack1(filterIndex).windows;
    windowList2=filterStack2(filterIndex).windows;
    
    for wIndex1=1:length(windowList1)
        
        num1=windowList1(wIndex1).numerator;
        den1=windowList1(wIndex1).denominator;
        
        if den1 ~= 0
            
            for wIndex2=1:length(windowList2)
                
                num2=windowList2(wIndex2).numerator;
                den2=windowList2(wIndex2).denominator;
                windowSim=-1;
                
                if den2 ~= 0
                    windowSim=max([windowSim sum(num1.*num2)/(den1*den2)]);
                end
                
                if windowSim >= 0
                    simArray=[simArray windowSim];
                end
                
            end
            
        end
        
    end
    
end

wordSim=mean(simArray);