 %%  No AF ever gruppen
load('No_AF_ever_XML_loaded.mat')

%% beregn duration i dage
XML = No_AF_ever_XML_loaded;
counter = 0;

for i=1:length(XML) 
   if  strcmp(XML(i).TestInfo.Gender, 'MALE')
       NoAF_gender(i) = 0;
   elseif strcmp(XML(i).TestInfo.Gender, 'FEMALE')
       NoAF_gender(i) = 1;
   else
       NoAF_gender(i) = 3;          %% skriv 3 hvis deres køn er N/A
       counter = counter +1;
%        XML(i) = [];
%        indexesRemoved(k)=i+count;
%        count = count+1;
%        k=k+1;
       X_disp = sprintf('Sample %i removed',i);
       disp(X_disp)
   end 
 end
 

 for j = 1:length(XML)
        if isnan(XML(j).TestInfo.PatientAge)
            NoAF_age(j) = 0;
            counter = counter +1;
            Y_disp = sprintf('Sample %i removed',j);
            disp(Y_disp)
%             XML(i) = [];
%             indexesRemoved(k)=i+count;
%             count = count+1;
%             k=k+1;
%             X_disp = sprintf('Sample %i removed',i);
%             disp(X_disp)
            %i = i-1;
        else
           NoAF_age(j) = XML(j).TestInfo.PatientAge;
%             XML(i) = [];
%             indexesRemoved(k)=i+count;
%             count = count+1;
%             k=k+1;
%             X_disp = sprintf('Sample %i removed',i);
%             disp(X_disp)
        end
 end
 
 
 %%
 enddate = datetime(2015,12,31,23,59,59);
 l=1;
while l <= length(XML)
   date_No_AF_ever_ECG{l} = XML(l).TestInfo.AcqDateTime;
   t = datetime(date_No_AF_ever_ECG(l),'InputFormat','yyyy-MM-dd HH:mm:ss');
   diff = enddate-t;
   NoAF_duration(l) = days(diff);
   l = l+1;
end

NoAF_gender = NoAF_gender';
NoAF_age = NoAF_age';
NoAF_duration = NoAF_duration';

 %% Detection på No AF Ever gruppen
load('No_AF_ever_variables_all_variables.mat')

 %%
% 
% % Konventionel  - få integreret p>120 ms
% [NoAF_konv_detection] = konventionalDetectionMethod(konv_biphasic_p_wave, konv_p_iab);
% NoAF_konv_detection = NoAF_konv_detection';
% Biphasic P0
% [NoAF_biphasic_90_p0_detection] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave,90,0);
% NoAF_biphasic_p0_detection = NoAF_biphasic_p0_detection';
% 
% % Biphasic +/- 50 OR
% [NoAF_biphasic_p0_O0R_50_detection] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave,50,0);
% NoAF_biphasic_p0_OR_50_detection = NoAF_b'i'phasic_p0_OR_50_detection';
% 
% % P0' area > 2 mikroV
% [NoAF_area_2microV] = areaDetectionMethod(sum_p_inv_loop, sum_p_loop, 2);
% NoAF_area_2microV = NoAF_area_2microV';
% 
% % P0' amplitude > 10 mikroV
% [NoAF_amplitude_10] = amplitudeDetectionMethod(p_prime_ampl, 10);
% NoAF_amplitude_10 = NoAF_amplitude_10';
%%
NoAF_biphasicleads = biphasic_p_wave;
%%
%Alle Biphasic +/- AND metoder
span = [0;10;20;30;40;50;60;70;80;90];
for i=1:length(span)
[NoAF_biphasic_AND_detection(:,i)] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave,span(i),1);
end
%NoAF_biphasic_AND_detection = NoAF_biphasic_AND_detection';
%%
NoAF_event = zeros(length(XML),1);
 
NoAF_matrix = [NoAF_event NoAF_duration NoAF_age NoAF_gender NoAF_biphasic_AND_detection];


%% Find tid mellem last normal og first AF ECG gruppen
%load('AF_first_ECG.mat')
%load('AF_last_normal_ECG_XML_loaded.mat')


%% Fjern data med kun én tid og beregn duration i dage
[intersectedData] = intersectXMLsOnIDs(AF_first_ECG,AF_last_normal_ECG_XML_loaded);
%%
AF_index = [intersectedData.IndexLastNormal]';
AF_duration = [intersectedData.duration]';
 
%% Tjek for gender og alder N/A
XML = AF_last_normal_ECG_XML_loaded(AF_index);
%%

for i=1:length(XML) 
   if  strcmp(XML(i).TestInfo.Gender, 'MALE')
       AF_gender(i) = 0;
       
   elseif strcmp(XML(i).TestInfo.Gender, 'FEMALE')
       AF_gender(i) = 1;
   else
       AF_gender(i) = 3;          %% skriv 3 hvis deres køn er N/A
       counter = counter +1;
       Z_disp = sprintf('Sample %i removed',i);
       disp(Z_disp)
   end 
end
 


 for j = 1:length(XML)
        if isnan(XML(j).TestInfo.PatientAge)
            AF_age(j) = 0;
            counter = counter +1;
            A_disp = sprintf('Sample %i removed',j);
            disp(A_disp)
        else
           AF_age(j) = XML(j).TestInfo.PatientAge;
        end
 end





%%
 AF_gender = AF_gender';
 AF_age = AF_age';

%% Detection på AF gruppen    
load('AF_last_normal_ECG_GEpoffset_workspace.mat')
%%
biphasic_p_wave = biphasic_p_wave(AF_index,:);
AF_biphasicleads = biphasic_p_wave;

%%
% % Konventionel  - få integreret p>120 ms
% [AF_konv_detection] = konventionalDetectionMethod(konv_biphasic_p_wave(AF_index,:), konv_p_iab(AF_index));
% AF_konv_detection = AF_konv_detection'; 
% % P0' area > 2 mikroV
% [AF_area_2microV] = areaDetectionMethod(sum_p_inv_loop(AF_index), sum_p_loop(AF_index), 2);
% AF_area_2microV = AF_area_2microV';
% % P0' amplitude > 10 mikroV
% [AF_amplitude_10] = amplitudeDetectionMethod(p_prime_ampl(AF_index), 10);
% AF_amplitude_10 = AF_amplitude_10';


%Alle Biphasic +/- AND metoder
span = [0;10;20;30;40;50;60;70;80;90];
for i=1:length(span)
[AF_biphasic_AND_detection(:,i)] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave,span(i),1);
end%AF_biphasic_area_detection = AF_biphasic_area_detection;

%% Lav AF matrice

AF_event = ones(length(AF_duration),1);

%AF_matrix = [AF_event AF_duration AF_konv_detection AF_biphasic_p0_detection AF_biphasic_p0_OR_50_detection AF_biphasic_p0_AND_10_detection AF_area_2microV AF_amplitude_10];
AF_matrix = [AF_event AF_duration AF_age AF_gender AF_biphasic_AND_detection];

%% Combine AF and No AF matrices
%AND_matrix = [AF_matrix;NoAF_matrix];

%Age_matrix = [AF_age;NoAF_age];
%Gender_matrix = [AF_gender;NoAF_gender];
biphasic_matrix = [AF_biphasicleads;NoAF_biphasicleads];

%%
% Biphasic_OR_matrix = [AF_matrix;NoAF_matrix];                         % 80;160;320;640;1280;2560
% %
% 
P0AND_table = array2table(AND_matrix, 'VariableNames',{'Event','Duration','Age','Gender','0','10','20','30','40','50','60','70','80','90'});
 writetable(P0AND_table,'P0AND_table2.csv')



