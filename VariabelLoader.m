%% kør alle funktionerne for data i en mappe 

% beregning af Poffset:

%load() %% insert file

%% beregn nu p-off
XML = aIAB_XML_loaded;          
for i=1:length(XML)
    %Angiv den konkrete fil der skal køres i scriptet ved index af xmlfiler
    %XML = XMLECGParser(xmlfiles(i).name);
    
    if isnan(XML(i).TestInfo.POffset)
        disp("found one at " + i)%Skip (automatically sets all values to zero)
    else
        
        infECG=[XML(i).MedianECG.II,XML(i).MedianECG.III,XML(i).MedianECG.aVF]; %infECG er midlertidig
        
        % Define part of ECG
        On(i)=XML(i).TestInfo.POnset;
        GEOff=XML(i).TestInfo.POffset;
        Qon=XML(i).TestInfo.QOnset;
        
        Off(i)=calcPoff(infECG,GEOff,Qon);
    end
end

%% transformaer til VCG 

%Kors regression
T=[-0.130 0.050 -0.010 0.140 0.060 0.540 0.380 -0.07;
     0.060 -0.020 -0.050 0.060 -0.170 0.130 -0.07 0.930;
     -0.430 -0.06 -0.140 -0.20 -0.110 0.310 0.110 -0.23]';
 
for i=1:1:length(XML)
 
%time = XML.MedianECG.time(On:Off);
ecg = [XML(i).MedianECG.V1 XML(i).MedianECG.V2 XML(i).MedianECG.V3 XML(i).MedianECG.V4 XML(i).MedianECG.V5 XML(i).MedianECG.V6 XML(i).MedianECG.I XML(i).MedianECG.II]; %Sætter EKG i rigtig rækkefølge ift. transformering

VCG_T(i,:,:) = (ecg*T); %transformed VCG
end 

%% beregn pseudoleads calc

for i=1:1:length(XML)
   [leadprojlength, Pseudo_electrodes(i,:,:), numerationOfElectrodes, PC12_ratio(i)] = PseudoLeadsCalc(squeeze(VCG_T(i,On(i):Off(i),:)));   
[p_iab(i), biphasic_p_wave(i,:), sum_p_loop(i,:), sum_p_inv_loop(i,:), a(i,:), b(i,:)] = detectionFile(leadprojlength', 1, length(leadprojlength));   
end


%% beregning af LoadUniqueEcgs

loadUnique


