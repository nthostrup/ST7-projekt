%Takes unique ecgs from folder and plots each persons traditional biphasic p-waves as
%function of time.
close all
clear;
directorypath = 'S:\Testdata\';
uniqueECGS = loadUniqueECG(directorypath);
%% 
for j=1:size(uniqueECGS,2)
    person1ECGs = uniqueECGS(j).ECGs;
    Pons = uniqueECGS(j).POn;
    Poffs = uniqueECGS(j).POff;
    if(~isempty(find(isnan(Poffs),1)))
        break;
    end


    p_iab = zeros(size(person1ECGs,1),3);
    biphasic_p_wave = zeros(size(person1ECGs,1),3);
    sum_p_loop = zeros(size(person1ECGs,1),3);
    sum_p_inv_loop= zeros(size(person1ECGs,1),3);
    a = zeros(size(person1ECGs,1),3);
    b = zeros(size(person1ECGs,1),3);

    for i=1:size(person1ECGs,1)
        lead23aVF = [squeeze(person1ECGs(i,:,2));squeeze(person1ECGs(i,:,3));squeeze(person1ECGs(i,:,6))];
        [p_iab(i,:), biphasic_p_wave(i,:), sum_p_loop(i,:), sum_p_inv_loop(i,:), a(i,:), b(i,:)] = ...
        detectionFile(lead23aVF',Pons(i),Poffs(i));
    end

    figure;
    plot(1:size(person1ECGs,1),sum(sum_p_inv_loop,2)) %plots sum of p'
    %plot(1:size(person1ECGs,1),sum(biphasic_p_wave,2))
    
    title("Person "+j)
end