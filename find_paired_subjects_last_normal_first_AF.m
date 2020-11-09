%% Find tid mellem last normal og first AF ECG
%load('AF_first_ECG.mat')
%load('AF_last_normal_ECG_XML_loaded.mat')

%% Læg XML sammen
%bothFiles = [AF_first_ECG AF_last_normal_ECG_XML_loaded];

% Hver række = 1 person, 
% man kan så se på datoerne.
% dato stempel for 2
%[uniqueECGs] = loadUniqueECG_from_XML(bothFiles);
%load('uniqueECGs.mat')



%% Fjern data med kun én tid
ECGs = uniqueECGs;

for i =1:length(ECGs)-1051      %% 1051 fjernes da der kun er ét sample
    if length(ECGs(i).POff) < 2
        ECGs(i) = [];
    else
        d = ECGs(i).dateTimeAcq;

        t = datetime(d,'InputFormat','yyyy-MM-dd HH:mm:ss');
    
        difference(i) = t(1)-t(2);
        dura(i) = days(difference(i));


    end
end
%%
for i=1:length(ECGs)
    % Kør igennem detectionFile
    EKGet(i,:,:) = squeeze(ECGs(i).ECGs(2,:,:));        %% 1x600x12 til 600x12
    [p_iab, biphasic_p_wave, sum_p_loop, sum_p_inv_loop, a, b, p_prime_ampl] = detectionFile(EKGet(i), ECGs(i).POn(2), ECGs(i).POff(2)); %Find bifaser i data 
    %ECG, Pon og Poff er nr 2 værdi i datasættet
end
    %[detectionOutput] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave, 0, 1); %Brug dette til at bruge de forskellige metoder   

%% for No AF ever

%enddate = 









