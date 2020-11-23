

%load('S:\IAB-data\AF_last_normal_ECG_XML_loaded.mat')
%XML = AF_last_normal_ECG_XML_loaded;
%% Check insignificant p-wave
countInsignificantPwave = 0;
 for i=1:length(XML) 
    ecg12 = XML(i).MedianECG.ECG12Leads;
    pOn = XML(i).TestInfo.POnset;
    pOff = XML(i).TestInfo.POffset;

    II_Ploop = ecg12(pOn:pOff,2);         % det oprindelige p-loop for given lead
    III_Ploop = ecg12(pOn:pOff,3);         % det oprindelige p-loop for given lead
    aVF_Ploop = ecg12(pOn:pOff,6);         % det oprindelige p-loop for given lead
    
    II_Ploop = alignPloopWithRegression(II_Ploop);
    III_Ploop = alignPloopWithRegression(III_Ploop);
    aVF_Ploop = alignPloopWithRegression(aVF_Ploop);

    % Beregning af ligningen for linjen mellem 2 punkter.  

    
    if ((max(II_Ploop) > 20 || min(II_Ploop) < -20) ...
    || (max(III_Ploop) > 20 || min(III_Ploop) < -20) ...
    || (max(aVF_Ploop) > 20 || min(aVF_Ploop) < -20))
        %Do nothing
    else       
        countInsignificantPwave = countInsignificantPwave + 1;
   end 
 end
 disp("Datasets with insignificant p-wave " + countInsignificantPwave);
 
 
 %% Check missing gender
countNoGender = 0;
 for i=1:length(XML) 
   if  strcmp(XML(i).TestInfo.Gender, 'MALE') || strcmp(XML(i).TestInfo.Gender, 'FEMALE')
       %Do nothing
   else
       countNoGender = countNoGender + 1;
   end 
 end
 disp("Datasets with no gender " + countNoGender);
 
  %% Check missing age
countNoAge = 0;
 for i=1:length(XML) 
   if  isnan(XML(i).TestInfo.PatientAge)
        countNoAge = countNoAge + 1;
   end 
 end
 disp("Datasets with no age " + countNoAge);
 
   %% Check missing pOn or Poff
countPonPoff = 0;
 for i=1:length(XML) 
   if  isnan(XML(i).TestInfo.POnset) || isnan(XML(i).TestInfo.POffset)
        countPonPoff = countPonPoff + 1;
   end 
 end
 disp("Datasets with no pOn or Poff " + countPonPoff);
 