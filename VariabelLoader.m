%% kør alle funktionerne for data i en mappe 
%USE: LOAD XML MANUALLY, SET XML = TO THIS DATA (L. 9):

% beregning af Poffset:

%load() %% insert file

    % beregn nu p-off
XML = AF_last_normal_ECG_XML_loaded; 
disp('starter')
%Removing NaN entries:
count = 0;
i = 1;
while i<=length(XML)
    if isnan(XML(i).TestInfo.POffset)
        XML(i)=[];
        count = count +1;
    else
        i = i+1;%Only increase i when no set is removed.
    end
end
disp("Removed " + count + " datasets");
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
    GEOff=XML(i).TestInfo.POffset;
    Qon=XML(i).TestInfo.QOnset;

    Off(i)=calcPoff(infECG,GEOff,Qon);
    
end
disp('p_offset er beregnet')
    % transformaer til VCG 

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
uniqueECGS=loadUniqueECG_from_XML(XML);
disp('done!')


