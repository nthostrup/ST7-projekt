%Takes unique persons from folder and plots biphasic pseudoLead 0 as function of
%time

%sorting of leads in ecg12: I, II, III, aVR, aVL, aVF, V1, V2, V3, V4, V5, V6
close all
clear;
directorypath = 'S:\Testdata\';
uniqueECGS = loadUniqueECG(directorypath);
%%
%Kors matrix:
T=[0.3800   -0.0700   -0.1300    0.0500   -0.0100    0.1400    0.0600    0.5400;
             -0.0700    0.9300    0.0600   -0.0200   -0.0500    0.0600   -0.1700    0.1300;
            0.1100   -0.2300   -0.4300   -0.0600   -0.1400   -0.2000   -0.1100    0.3100]';
        
 allDur = [];
 allSum = [];
for j=1:size(uniqueECGS,2)%LOOPS through each person
    personECGs = uniqueECGS(j).ECGs;
    personacq = uniqueECGS(j).dateTimeAcq;
    Pons = uniqueECGS(j).POn;
    Poffs = uniqueECGS(j).POff;
    if(~isempty(find(isnan(Poffs),1)))
        break;%Maybe continue?
    end


    biphasic_p_wave = zeros(size(personECGs,1),3); %dimensions: ecg's recorded x leads to look at.
    sum_p_inv_loop= zeros(size(personECGs,1),3);
    
    dur = zeros(1,size(personacq,1));
    for i=1:size(personECGs,1)
        %Extract I,II,V1,V2,V3,V4,V5,V6
        lead8 = [squeeze(personECGs(i,:,1)); squeeze(personECGs(i,:,2));squeeze(personECGs(i,:,7));squeeze(personECGs(i,:,8));squeeze(personECGs(i,:,9));squeeze(personECGs(i,:,10));squeeze(personECGs(i,:,11));squeeze(personECGs(i,:,12))]';
        VCG = lead8*T;
        
        [leadprojlength, ~, ~] = PseudoLeadsCalc(VCG(Pons(i):Poffs(i),:)); %Give the calculator only the P-loop 
        
        [~, biphasic_p_wave(i,:), ~, sum_p_inv_loop(i,:),~, ~] = detectionFile([leadprojlength(1,:);leadprojlength(2,:);leadprojlength(18,:)]',1,size(leadprojlength,2));
        
        
        %Duration in years
        dur(i)=datenum(datetime(personacq(i,:),'InputFormat','yyyy-MM-dd HH:mm:ss')-datetime(personacq(1,:),'InputFormat','yyyy-MM-dd HH:mm:ss'))/365;

    end
    
    allDur = [allDur, dur];
    allSum = [allSum, sum(sum_p_inv_loop,2)'];
    %figure;
    %scatter(dur, sum(sum_p_inv_loop,2),'*') %plots sum of p' vs duration since first ecg
    %scatter(1:size(personECGs,1), sum(sum_p_inv_loop,2),'*') %plots sum of p'
    %title("Person "+j + " - p' area in P0")
    %plot(1:size(personECGs,1), sum(biphasic_p_wave,2))
    %title("Person "+j + " - nr. biphasic in P0")
    %hold on;
    %xlabel("Year after first ECG")
    %ylabel("µV*ms")
end
%% 
scatter(allDur, allSum,'*') %plots sum of p' vs duration since first ecg
title("Person - sum of p' vs year after first ecg")
xlabel("Year after first ECG")
ylabel("µV*ms")
%legend("person"+[1:size(uniqueECGS,2)]);