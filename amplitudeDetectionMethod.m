function [detectionOutput] = amplitudeDetectionMethod(PprimeAmp, threshold)
% detectionOutput er en variabel, som med “1” eller “0” indikerer om metoden har fundet den givne karakteristika.
% PprimeAmp: Array med amplitude målt i de 18 pseudo leads.
% Threshold: threshold for amplituden, skal være positiv


for i=1:length(PprimeAmp)
    if PprimeAmp(i,1) < 0
    PprimeAmp(i,1) = PprimeAmp(i,1)*-1;         %%Sørger for at amplituden er positivt
    end 
    if max(PprimeAmp(i,1)) > threshold     %mikroV %%%%%% kig HER. har ændret fra min(PprimeAmp(i,1)) < threshold -> synes ikke det giver mening
    detectionOutput(i) = 1;
    else
    detectionOutput(i) = 0;
    end
end


end