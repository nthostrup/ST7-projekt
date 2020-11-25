% funktionen for detektion ved brug af fil med ECG (hvor kolonner er leads, og rÃ¦kker er samples)  

function[p_iab, biphasic_p_wave, sum_p_loop, sum_p_inv_loop, a, b, p_prime_ampl] = detectionFile_contWave(ecg, POnset, POffset)   
%Purpose: Calculate biphasic p-waves, sum(size) of positive wave and
%sum(size) of negative wave, gives coefficients a and b of regression line
%for p-wave and p_prime_ampl for largest negative amplitude of P prime.

%OUTPUT:
% p_iab kan vÃ¦re 0 eller 1 og indikere om subjekt har partiel IAB. 
% biphasic_p_wave er en 1*M vektor og angiver om p-bÃ¸lgen er bifasisk i henholdvis ecg(:,1), ecg(:,2) osv....
% sum_p_loop er den den integrerede p-loop(den positive del) ift regressionslinjen i enheden [mikroV*mS]
% sum_p_inv_loop er den den integrerede p'-loop(den negative del) ift regressionslinjen i enheden [mikroV*mS]
% a: Slope of the regression line in p-wave.
% b: b-coefficient of the regression line in the p-wave
% p_prime_ampl: Amplitude of p-prime (is negative)

%INPUT:
%ecg: ECG with leads in columns for ONE person only.
%Ponset: Onset of p-wave (=1 if p-wave is given in "ecg")
%POffset: Offset of p-wave (=end if p-wave is given in "ecg")

P=[POnset POffset];       % Vektor med P_onset og P_Offset

[r,c] = size(ecg);

%Preallocation of variables for speed:
a = zeros(1,c);
b = zeros(1,c);
sum_p_loop = zeros(1,c);
sum_p_inv_loop = zeros(1,c);
biphasic_p_wave = zeros(1,c);
p_prime_ampl = zeros(1,c);

% Her kÃ¸res et loop for hver lead. eks. Hvis nr = 1, analyseres lead II (da ecg(;,1) er lead II).  
for nr=1:1:c                            % c er antallet af leads (kolonner) 
% Definere p-loop
P_loop = ecg(P(1,1):P(1,2),nr);         % det oprindelige p-loop for given lead

% Beregning af ligningen for linjen mellem 2 punkter.  
coefficients = polyfit([P(1,1), P(1,2)], [ecg(P(1,1),nr), ecg(P(1,2),nr)], 1);  %funktion polyfit(x,y,degree) finder koeficienter for ligning mellem 2 punkter. 
% x-koordinaterne er p_onset og p_offset, y er ekg'et til x'erne, og antal
% frihedsgrader er 1 da det er imellem 2 punkter. 
a(nr) = coefficients (1);
b(nr) = coefficients (2);

% FratrÃ¦kker overstÃ¥ende funktion fra det oprindelindelige p-loop.
% SÃ¥ledes er P_onset = 0 og P_offset = 0. 
P_ecg_aligned = P_loop;             %P_ecg_aligned er P-loopet hvor regressionen er fratrukket
for i=1:1:length(P_loop)
   P_ecg_aligned(i)= P_ecg_aligned(i)-(a(nr)*(P(1,1)+i-1)+b(nr)); %her fratrÃ¦kkes regressionen for alle punkter i p-loopet.   
end

%Finding the amplitude of p_prime
p_prime_ampl(nr)=min(P_ecg_aligned);

% beregning af integralet af p-loopet
continous_p_wave=0;
continous_inv_p_wave=0; 
sum_p_loop(nr) = 0;                             % Integralet af P
sum_p_inv_loop(nr) = 0;                         % integrallet af den negative P
% hvis trapez-integralet er >=0 summeres det til sum_p_loop. 
% hvis trapez-integralet er <0 summeres det til sum_p_inv_loop. 
% her divideres med samplefrekvensen for at fÃ¥ mikrovolt*S. Derefter ganges med 
% 1000ms/s for at omregne enheden til mikroVolt*ms.   

    %NYT: 
  for i=2:1:length(P_ecg_aligned)

    if sign(P_ecg_aligned(i))<sign(P_ecg_aligned(i-1)) %skifter fra pos til neg bølge
        continous_p_wave=0; %start forfra med at tælle
    end 
     if sign(P_ecg_aligned(i))>sign(P_ecg_aligned(i-1)) %skifter fra neg til pos bølge
        continous_inv_p_wave=0; %start forfra med at tælle 
     end 
    
    sum_p_midl = (trapz(P_ecg_aligned(i-1:i))/500)*1000;%Divide by 500(Fs) and times 1000 gives µV*ms 
    
    if sum_p_midl >=0
        continous_p_wave=continous_p_wave+sum_p_midl;
        if continous_p_wave>sum_p_loop %gemmer den største positive bølge 
        sum_p_loop(nr) = continous_p_wave;
        end
    end 
    if sum_p_midl<0
       continous_inv_p_wave=continous_inv_p_wave+sum_p_midl;
       if continous_inv_p_wave<sum_p_inv_loop(nr) %gemmer den største negative bølge 
       sum_p_inv_loop(nr) = continous_inv_p_wave;
       end
    end
  end
% Enheden for sum_p_loop og sum_p_inv_loop er mikroVolt*ms.

% Detection af bifasisk p-bÃ¸lge
biphasic_p_wave(nr) = 0;                    % Initialiseres og sÃ¦ttes til 0.
if  (sum_p_inv_loop(nr)<=-160 && sum_p_loop(nr) >= 160)               % Treshold er 160 mikroV*mS           
    biphasic_p_wave(nr)=1;
end 


% Detection af partiel IAB - detectionen af p-IAB er den samme for alle
% leads. 
p_iab = 0;                                  %initialiseres og sÃ¦ttes til 0.
if length(P_loop)*2 >=120                   % Treshold er 120 ms for detection af partiel IAB   
    p_iab = 1;                              % Returnerer 1, hvis sandt 
end 
if length(P_loop)*2 < 120
    p_iab = 0;                              % Returnerer 0 hvis falsk
end
end
end

