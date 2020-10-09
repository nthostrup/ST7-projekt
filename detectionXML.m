% funktionen for detektion ved brug af XML-fil  - mangler at summere med trapez. 
function[p_iab, biphasic_p_wave, sum_p_loop, sum_p_inv_loop] = detectionXML(XML)   
% p_iab kan være 0 eller 1 og indikere om subjekt har partiel IAB. 
% biphasic_p_wave er en 1*3 vektor og angiver om p-bølgen er bifasisk i henholdvis lead II, aVF og III.
% sum_p_loop er den den integrerede p-loop(den positive del) ift regressionslinjen i enheden [mikroV/mS]
% sum_p_inv_loop er den den integrerede p'-loop(den negative del) ift regressionslinjen i enheden [mikroV/mS]

% Henter data fra XML-filen
ecg = [XML.MedianECG.II XML.MedianECG.aVF XML.MedianECG.III]; % initialisere den inferiore afledninger
P=[XML.TestInfo.POnset XML.TestInfo.POffset];       % Vektor med P_onset og P_Offset

[r,c] = size(ecg);

% Her køres et loop for hver lead. eks. Hvis nr = 1, analyseres lead II (da ecg(;,1) er lead II).  
for nr=1:1:c                            % c er antallet af leads (kolonner) 
% Definere p-loop
P_loop = ecg(P(1,1):P(1,2),nr);         % det oprindelige p-loop for given lead

% Beregning af ligningen for linjen mellem 2 punkter.  
coefficients = polyfit([P(1,1), P(1,2)], [ecg(P(1,1),nr), ecg(P(1,2),nr)], 1);  %funktion polyfit(x,y,degree) finder koeficienter for ligning mellem 2 punkter. 
% x-koordinaterne er p_onset og p_offset, y er ekg'et til x'erne, og antal
% frihedsgrader er 1 da det er imellem 2 punkter. 
a(nr) = coefficients (1);
b(nr) = coefficients (2);

% Fratrækker overstående funktion fra det oprindelindelige p-loop.
% Således er P_onset = 0 og P_offset = 0. 
P_ecg_aligned = P_loop;             %P_ecg_aligned er P-loopet hvor regressionen er fratrukket
for i=1:1:length(P_loop)
   P_ecg_aligned(i)= P_ecg_aligned(i)-(a(nr)*(P(1,1)+i-1)+b(nr)); %her fratrækkes regressionen for alle punkter i p-loopet.   
end

%kan plottes med følgende udkommenterede: (figur 1 er lead II, figur 2 er lead aVF, figur 3 er lead III)
figure(nr), subplot(2,1,1)          
plot(P_loop)
hold on 
t=[1:length(P_loop)];
x= [P(1,1):P(1,2)];
plot(t,a(nr)*x+b(nr))
legend('oprindelige p-loop')
subplot(2,1,2)
plot(P_ecg_aligned)
legend('modificeret p-loop uden hældning') %note: p_onset og p_offset er nu det samme efter fratrækning af regressionen. 

% beregning af integralet af p-loopet
sum_p_loop(nr) = 0;                             % Integralet af P
sum_p_inv_loop(nr) = 0;                         % integrallet af den negative P
for i=1:1:length(P_ecg_aligned)
% hvis p-loop efter fratrækning af regression
% er større end 0, så summeres den i variablen sum_p_loop. her ganges med
% 10^6, for at omregne til mikrovolt. Der divideres med (samplefrekvensen * 1000ms/s)
% for at omregne til ms. 
    if P_ecg_aligned(i)>= 0                 
    sum_p_loop(nr) = sum_p_loop(nr) + 10^6*(P_ecg_aligned(i))/(XML.TestInfo.ECGSampleBase * 1000);
    end 
    if P_ecg_aligned(i)< 0                  % Her summeres den negative del af p-loopet
    sum_p_inv_loop(nr) = sum_p_inv_loop(nr) + 10^6*(P_ecg_aligned(i))/(XML.TestInfo.ECGSampleBase * 1000);        
    end  
end
% Enheden for sum_p_loop og sum_p_inv_loop er mikroVolt/ms

% Detection af bifasisk p-bølge
biphasic_p_wave(nr) = 0;                    % Initialiseres og sættes til 0.
if  sum_p_inv_loop(nr)<=-160                % Treshold er 160 mikroV/mS           
    biphasic_p_wave(nr)=1;
end 
if  sum_p_inv_loop(nr)>-160
    biphasic_p_wave(nr)=0;
end 

% Detection af partiel IAB - detectionen af p-IAB er den samme for alle
% leads. 
p_iab = 0;                                  %initialiseres og sættes til 0.
if length(P_loop)*2 >=120                   % Treshold er 120 ms for detection af partiel IAB   
    p_iab = 1;                              % Returnerer 1, hvis sandt 
end 
if length(P_loop)*2 < 120
    p_iab = 0;                              % Returnerer 0 hvis falsk
end
end
end

% lav trapez sumering istedet. 
