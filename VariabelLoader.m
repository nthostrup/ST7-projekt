%% Select folder to load files from
clear all;
close all; 

datafiledir='S:\IAB-data\AF-last-normal-ECG';
xmlfiles=dir(fullfile(datafiledir,'*xml'));

%% Clean datafiles to get rid of corrupted data
tic

for i = 1:1:length(xmlfiles)
%Angiv den konkrete fil der skal k�res i scriptet ved index af xmlfiler
XML(i) = XMLECGParser(xmlfiles(i).name);  
end
toc
    % beregn nu p-off
%% remove corrupted files
disp('starter')
%Removing NaN entries:
countNoPonorPoff = 0;
countNoAge = 0;
countNoGender = 0;
countInsignificantPwave = 0;
i = 1;
while i<=length(XML)
    if isnan(XML(i).TestInfo.POffset) || isnan(XML(i).TestInfo.POnset)
        XML(i)=[];
        countNoPonorPoff = countNoPonorPoff +1;
        continue;
    else %Calc only if pon/poff is available
        ecg12 = XML(i).MedianECG.ECG12Leads;
        pOn = XML(i).TestInfo.POnset;
        pOff = XML(i).TestInfo.POffset;

        II_Ploop = ecg12(pOn:pOff,2);         % det oprindelige p-loop for given lead
        III_Ploop = ecg12(pOn:pOff,3);         % det oprindelige p-loop for given lead
        aVF_Ploop = ecg12(pOn:pOff,6);         % det oprindelige p-loop for given lead

        II_Ploop = alignPloopWithRegression(II_Ploop);
        III_Ploop = alignPloopWithRegression(III_Ploop);
        aVF_Ploop = alignPloopWithRegression(aVF_Ploop);
    end
    
    if isnan(XML(i).TestInfo.PatientAge) || (XML(i).TestInfo.PatientAge < 18)
        XML(i)=[];
        countNoAge = countNoAge +1;
    elseif ~(strcmp(XML(i).TestInfo.Gender, 'MALE') || strcmp(XML(i).TestInfo.Gender, 'FEMALE'))
        XML(i)=[];
        countNoGender = countNoGender +1;
    elseif ~((max(II_Ploop) > 20 || min(II_Ploop) < -20) ...
    || (max(III_Ploop) > 20 || min(III_Ploop) < -20) ...
    || (max(aVF_Ploop) > 20 || min(aVF_Ploop) < -20))
        XML(i)=[];
        countInsignificantPwave = countInsignificantPwave +1;
    else
        i = i+1;%Only increase i when no set is removed.
    end
end
totalCount = countNoPonorPoff + countNoAge + countNoGender + countInsignificantPwave;
%No_AF_ever_XML_loaded = XML;
AF_last_normal_ECG_XML_loaded = XML;

disp("Removed " + totalCount + " datasets");
%% 
%Preallocation of variables:
    Off = zeros(1,length(XML));
    On = zeros(1,length(XML));


for i=1:length(XML)
    %Angiv den konkrete fil der skal køres i scriptet ved index af xmlfiler
    %XML = XMLECGParser(xmlfiles(i).name);
    
    infECG=[XML(i).MedianECG.II,XML(i).MedianECG.III,XML(i).MedianECG.aVF]; %infECG er midlertidig

    % Define part of ECG
    On(i)=XML(i).TestInfo.POnset;
    Off(i)=XML(i).TestInfo.POffset;
    %Qon=XML(i).TestInfo.QOnset;

    %Off(i)=calcPoff(infECG,GEOff,Qon);
    
end
disp('p_offset er beregnet')
    % transformaer til VCG 
%% 
%Kors regression
T=[-0.130 0.050 -0.010 0.140 0.060 0.540 0.380 -0.07;
     0.060 -0.020 -0.050 0.060 -0.170 0.130 -0.07 0.930;
     -0.430 -0.06 -0.140 -0.20 -0.110 0.310 0.110 -0.23]';
 
for i=1:1:length(XML)
 
%time = XML.MedianECG.time(On:Off);
ecg = [XML(i).MedianECG.V1 XML(i).MedianECG.V2 XML(i).MedianECG.V3 XML(i).MedianECG.V4 XML(i).MedianECG.V5 XML(i).MedianECG.V6 XML(i).MedianECG.I XML(i).MedianECG.II]; %Sætter EKG i rigtig rækkefølge ift. transformering

VCG_T(i,:,:) = (ecg*T); %transformed VCG
end 
disp('VCG er beregnet')
    % beregn pseudoleads calc
%%
for i=1:1:length(XML)
    [leadprojlength, Pseudo_electrodes(i,:,:), numerationOfElectrodes, PC12_ratio(i)] = PseudoLeadsCalc(squeeze(VCG_T(i,On(i):Off(i),:)));   
    
    [p_iab(i), biphasic_p_wave(i,:), sum_p_loop(i,:), sum_p_inv_loop(i,:), a(i,:), b(i,:), p_prime_ampl(i,:)] = detectionFile(leadprojlength', 1, length(leadprojlength));   
end
disp('detektion af pseudoleads er beregnet')
    % Beregn biphasic p-wave for de konventionelle ecg'er
for i =1:1:length(XML)
infECG=[XML(i).MedianECG.II,XML(i).MedianECG.aVF,XML(i).MedianECG.III]; %infECG er midlertidig
[konv_p_iab(i), konv_biphasic_p_wave(i,:), konv_sum_p_loop(i,:), konv_sum_p_inv_loop(i,:), konv_a(i,:), konv_b(i,:)] = detectionFile(infECG, On(i), Off(i));   
end 
disp('detektion af konv. inf leads er beregnet')
    % beregning af LoadUniqueEcgs
%uniqueECGS=loadUniqueECG_from_XML(XML);
disp('done!')


