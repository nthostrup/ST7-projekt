% This script will calculate the different demographics of the datasets
%Count
%Age
%Gender
%Heart rate
%P-wave duration
% 
Fs = 500;
%% No af ever

%load('S:\IAB-data\No_AF_ever_XML_loaded.mat')
XML = No_AF_ever_XML_loaded;

%Removing NaN entries:
count = 0;
i = 1;
while i<=length(XML)
    if isnan(XML(i).TestInfo.POffset)
        XML(i)=[];
        count = count +1;
    elseif isnan(XML(i).TestInfo.PatientAge)
        XML(i)=[];
        count = count +1;
    elseif ~(strcmp(XML(i).TestInfo.Gender, 'MALE') || strcmp(XML(i).TestInfo.Gender, 'FEMALE'))
        XML(i)=[];
        count = count +1;
    else
        i = i+1;%Only increase i when no set is removed.
    end
end


totalCountNoAfEver = length(XML);

agesNoAFEver = zeros(length(XML),1); %In years
heartRatesNoAfEver = zeros(length(XML),1); %In BPM
pWaveDurationsNoAfEver = zeros(length(XML),1); %in ms
countMaleNoAFEver = 0; %count
countFemaleNoAfEver = 0; %count
 for i=1:length(XML) 
   
   %Gender
   if  strcmp(XML(i).TestInfo.Gender, 'MALE') 
       countMaleNoAFEver = countMaleNoAFEver + 1;
   elseif strcmp(XML(i).TestInfo.Gender, 'FEMALE')
       countFemaleNoAfEver = countFemaleNoAfEver + 1;
   end 
   
   %Ages:
   if(~isnan(XML(i).TestInfo.PatientAge))
        agesNoAFEver(i) = XML(i).TestInfo.PatientAge;
   else
       agesNoAFEver(i) = 0;
   end
   %Ventricular rate / HeartRate
   heartRatesNoAfEver(i) = XML(i).TestInfo.VentricularRate;
   
   %Pwave duration
   pWaveDurationsNoAfEver(i) = XML(i).TestInfo.POffset-XML(i).TestInfo.POnset;
   
 end
 
 
 pWaveDurationsNoAfEver = (pWaveDurationsNoAfEver./500)*1000;%Get in ms
 
 disp("Done No AF Ever");
 %% AF Last normal
 
%load('S:\IAB-data\AF_last_normal_ECG_XML_loaded.mat')
XML = AF_last_normal_ECG_XML_loaded;

%Removing NaN entries:
count = 0;
i = 1;
while i<=length(XML)
    if isnan(XML(i).TestInfo.POffset)
        XML(i)=[];
        count = count +1;
    elseif isnan(XML(i).TestInfo.PatientAge)
        XML(i)=[];
        count = count +1;
    elseif ~(strcmp(XML(i).TestInfo.Gender, 'MALE') || strcmp(XML(i).TestInfo.Gender, 'FEMALE'))
        XML(i)=[];
        count = count +1;
    else
        i = i+1;%Only increase i when no set is removed.
    end
end



totalCountLastNormal = length(XML);

agesLastNormal = zeros(length(XML),1);
heartRatesLastNormal = zeros(length(XML),1);
pWaveDurationsLastNormal = zeros(length(XML),1);
countMaleLastNormal = 0;
countFemaleLastNormal = 0;
 for i=1:length(XML) 
   
   %Gender
   if  strcmp(XML(i).TestInfo.Gender, 'MALE') 
       countMaleLastNormal = countMaleLastNormal + 1;
   elseif strcmp(XML(i).TestInfo.Gender, 'FEMALE')
       countFemaleLastNormal = countFemaleLastNormal + 1;
   end 
   
   %Ages:
   agesLastNormal(i) = XML(i).TestInfo.PatientAge;
   
   %Ventricular rate / HeartRate
   heartRatesLastNormal(i) = XML(i).TestInfo.VentricularRate;
   
   %Pwave duration
   pWaveDurationsLastNormal(i) = XML(i).TestInfo.POffset-XML(i).TestInfo.POnset;
   
 end
 
 pWaveDurationsLastNormal = (pWaveDurationsLastNormal./500)*1000; %in ms
 disp("Done Last Normal ECG");
 
 %% Calculations


%Age
meanAgeNoAF = mean(agesNoAFEver);
stdAgeNoAF = std(agesNoAFEver);

meanAgeLastNormal = mean(agesLastNormal);
stdAgeLastNormal = std(agesLastNormal);

[H, P] = ttest2(agesNoAFEver,agesLastNormal)

%Gender
pctMaleNoAF = ((countMaleNoAFEver)/totalCountNoAfEver)*100;
pctFemaleNoAF = ((countFemaleNoAfEver)/totalCountNoAfEver)*100;

pctMaleLastNormal = ((countMaleLastNormal)/totalCountLastNormal)*100;
pctFemaleLastNormal=((countFemaleLastNormal)/totalCountLastNormal)*100;

%Heart Rate
meanHRNoAF = mean(heartRatesNoAfEver);
stdHRNoAF = std(heartRatesNoAfEver);

meanHRLastNormal = mean(heartRatesLastNormal);
stdHRLastNormal = std(heartRatesLastNormal);

[H, P] =ttest2(heartRatesNoAfEver,heartRatesLastNormal)

%P-wave duration
meanPwaveDurNoAF = mean(pWaveDurationsNoAfEver);
stdPwaveDurNoAF = std(pWaveDurationsNoAfEver);

meanPwaveDurLastNormal = mean(pWaveDurationsLastNormal);
stdPwaveDurLastNormal = std(pWaveDurationsLastNormal);

[H, P] =ttest2(pWaveDurationsNoAfEver,pWaveDurationsLastNormal)

disp("Done calculating")

%Collect variables

totalCount = [totalCountNoAfEver,totalCountLastNormal];
meanAge = [meanAgeNoAF, meanAgeLastNormal];
stdAge = [stdAgeNoAF, stdAgeLastNormal];
maleCount = [countMaleNoAFEver, countMaleLastNormal];
femaleCount = [countFemaleNoAfEver,countFemaleLastNormal];
malePct = [pctMaleNoAF, pctMaleLastNormal];
femalePct = [pctFemaleNoAF, pctFemaleLastNormal];
meanHeartRate = [meanHRNoAF, meanHRLastNormal];
stdHR = [stdHRNoAF, stdHRLastNormal];
meanPwaveDur = [meanPwaveDurNoAF, meanPwaveDurLastNormal];
stdPwaveDur = [stdPwaveDurNoAF, stdPwaveDurLastNormal];

disp("Done Collecting");

TableNoAF_LastNormal = table(totalCount, meanAge,stdAge,maleCount, malePct,femaleCount,femalePct,meanHeartRate,stdHR,meanPwaveDur,stdPwaveDur)

 %writetable(TableNoAF_LastNormal,"Demographic_table.xlsx")