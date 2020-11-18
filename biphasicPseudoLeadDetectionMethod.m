function [detectionOutput] = biphasicPseudoLeadDetectionMethod(data,  degreeSpan, andOrModifier )
% detectionOutput er en variabel, som med 1 eller 0 indikerer om metoden har fundet den givne karakteristika.
% Data: biphasic_p_wave-matrice som er X*18 stor (X=antal subjekter) 
% DegreeSpan: plus/minus gradspænd omkring P0, maks 80. Min 0.
% andOrModifier: modtager 0 = OR og 1 = AND


%gradspænd
switch(degreeSpan)
    case 0
        P = [1];
    case 10
        P = [1 2 18];
    case 20
        P = [1,2,3,17,18];
    case 30
        P = [1,2,3,4,16,17,18];
    case 40
        P = [1,2,3,4,5,15,16,17,18];
    case 50
         P = [1,2,3,4,5,6,14,15,16,17,18];
    case 60
        P = [1,2,3,4,5,6,7,13,14,15,16,17,18];
    case 70
        P = [1,2,3,4,5,6,7,8,12,13,14,15,16,17,18];
    case 80
        P = [1,2,3,4,5,6,7,8,9,11,12,13,14,15,16,17,18];
    case 90
        P = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18];
end




if andOrModifier == 0
    for i=1:length(data)
        for j=1:length(P)
            if data(i,P(j)) == 1
                W(i,j) = 1;
            else
                W(i,j) = 0;
            end
        end
        if sum(W(i,:)) >= 1
            detectionOutput(i) = 1;
        else
            detectionOutput(i) = 0;
        end
    end
    
elseif andOrModifier == 1
    for i=1:length(data)
        for j=1:length(P)
            if data(i,P(j)) == 1
                W(i,j) = 1;
            else
                W(i,j) = 0;
            end
        end
        if sum(W(i,:)) >= length(P)
            detectionOutput(i) = 1;
        else
            detectionOutput(i) = 0;
        end
    end  
        
end




end
