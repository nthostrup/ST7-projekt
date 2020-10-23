function [newPOffset]=calcPoff(ecg,POffset,QOnset)

[samples,nleads]=size(ecg);

POffWrong=1; %variabel til at tjekke om POffset skal flyttes -> foruds�tning for while-l�kke og startes derfor som true. 

while POffWrong==1
    
    POffWrong=0; %s�t den 0 -> den overskrives til 1 hvis arealet er >160 i en leadsne 
    
    for i=1:nleads %genneml�ber alle leads
        
        signal = ecg(POffset:QOnset,i); %udsnit af ecg (obs POffset �ndres (+1) for hver iteration af while-l�kken)
        
        coefficients = polyfit([POffset, QOnset],[ecg(POffset,i), ecg(QOnset,i)], 1);
        
        a(i) = coefficients(1);
        b(i) = coefficients(2);
        
        %alignedSignal = signal;             %Regressionslinjefratr�kkes signal
        
        for j=1:1:length(signal)
            alignedSignal(j)= signal(j)-(a(i)*(POffset+j-1)+b(i)); %her fratrækkes regressionen for alle punkter i i udsnittet signal.
        end
        
        % beregning af integralet mellem POffset og QOnset
        
        sum(i) = 0;                             % Integralet
        sum_inv(i) = 0;                         % integralet af den negative
        
        for j=2:1:length(alignedSignal) %
            % hvis p-loop efter fratrækning af regression
            % er større end 0, så summeres den (med trapexoid integrale) i variablen sum_p_loop.
            % her divideres med samplefrekvensen for at få mikrovolt*S. Derefter ganges med
            % 1000ms/s for at omregne enheden til mikroVolt*ms.
            
            if alignedSignal(j)>= 0
                %    sum_p_loop(nr) = sum_p_loop(nr) +
                %    10^6*(P_ecg_aligned(i))/(XML.TestInfo.ECGSampleBase * 1000);       Den gamle metode
                sum(i) = sum(i) + (trapz(alignedSignal(j-1:j))/500)*1000;
                
                if sum(i)>160
                    POffWrong=1; %sikrer at while l�kken k�res igen med skubbet p-offset
                end
            end
            if alignedSignal(j)< 0                  % Her summeres den negative del af p-loopet
                %    sum_p_inv_loop(nr) = sum_p_inv_loop(nr) + 10^6*(P_ecg_aligned(i))/(XML.TestInfo.ECGSampleBase * 1000);    % den gamle metode
                sum_inv(i) = sum_inv(i) + (-trapz(alignedSignal(j-1:j))/500)*1000;
                
                if sum_inv(i)>160
                    POffWrong=1;
                end
            end
        end
    end
    
    POffset=POffset+1; % T�ller op s� P offset er �get hvis while-l�kken skal k�res igen
end
newPOffset=POffset-1; % det er denne v�rdi der returneres (skal v�re -1 fordi der lige er lagt 1 til for at forberede til n�ste iteration i whilel�kken))
end