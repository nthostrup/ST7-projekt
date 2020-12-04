 %%  No AF ever gruppen
load('No_AF_ever_XML_loaded.mat')

%% beregn duration i dage
XML = No_AF_ever_XML_loaded;

for i=1:length(XML) 
   if  strcmp(XML(i).TestInfo.Gender, 'MALE')
       NoAF_gender(i) = 0;
   elseif strcmp(XML(i).TestInfo.Gender, 'FEMALE')
       NoAF_gender(i) = 1;
   else
       disp('error')
   end 
end

 for j = 1:length(XML)
        if isnan(XML(j).TestInfo.PatientAge)
            %NoAF_age(j) = 0;
            disp('Error')
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
load('Variables_for_NO_AF_Ever.mat')

 %%
% 
% % Konventionel  - få integreret p>120 ms
[NoAF_konv_detection] = konventionalDetectionMethod(konv_biphasic_p_wave, konv_p_iab);
NoAF_konv_detection = NoAF_konv_detection';
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
%Alle Biphasic +/- AND metoder
%span = [10;20;40;80;160;320;640;1280;2580];
span = [10;20;30;40;50;60;70;80;90;100];
%span = [0;10;20;30;40;50;60;70;80;90];
for i=1:length(span)
[NoAF_amplitude_detection(:,i)] = amplitudeDetectionMethod(p_prime_ampl, span(i));
end
%NoAF_biphasic_AND_detection = NoAF_biphasic_AND_detection';
%%
NoAF_event = zeros(length(XML),1);
 
NoAF_matrix = [NoAF_event NoAF_duration NoAF_age NoAF_gender NoAF_konv_detection];


%% Find tid mellem last normal og first AF ECG gruppen
load('AF_first_ECG.mat')
load('AF_last_normal_ECG_XML_loaded.mat')


%% Fjern data med kun én tid og beregn duration i dage
%[intersectedData] = intersectXMLsOnIDs(AF_first_ECG,AF_last_normal_ECG_XML_loaded);
%%
%AF_index = [intersectedData.IndexLastNormal]';
%AF_duration = [intersectedData.duration]';
 
%% Tjek for gender og alder N/A
%XML = AF_last_normal_ECG_XML_loaded(AF_index);
%%

for i=1:length(XML) 
   if  strcmp(XML(i).TestInfo.Gender, 'MALE')
       AF_gender(i) = 0;
       
   elseif strcmp(XML(i).TestInfo.Gender, 'FEMALE')
       AF_gender(i) = 1;
   else
       %AF_gender(i) = 3;          %% skriv 3 hvis deres køn er N/A
       disp('Error')
   end 
end

 for j = 1:length(XML)
        if isnan(XML(j).TestInfo.PatientAge)
            AF_age(j) = 0;
            disp('Error')
        else
           AF_age(j) = XML(j).TestInfo.PatientAge;
        end
 end

 AF_gender = AF_gender';
 AF_age = AF_age';

%% Detection på AF gruppen    
load('Variables_for_AF-last-normal.mat')
%%
biphasic_p_wave = biphasic_p_wave(AF_index,:);

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
%span = [10;20;40;80;160;320;640;1280;2580];
span = [10;20;30;40;50;60;70;80;90;100];
%span = [0;10;20;30;40;50;60;70;80;90];
for i=1:length(span)
[AF_amplitude_detection(:,i)] = amplitudeDetectionMethod(p_prime_ampl(AF_index), span(i));
end%AF_biphasic_area_detection = AF_biphasic_area_detection;

%% Lav AF matrice

AF_event = ones(length(AF_biphasic_AND_detection),1);

[AF_konv_detection] = konventionalDetectionMethod(konv_biphasic_p_wave(AF_index,:), konv_p_iab(AF_index));
AF_konv_detection = AF_konv_detection';

%AF_matrix = [AF_event AF_duration AF_konv_detection AF_biphasic_p0_detection AF_biphasic_p0_OR_50_detection AF_biphasic_p0_AND_10_detection AF_area_2microV AF_amplitude_10];
AF_matrix = [AF_event AF_duration AF_age AF_gender AF_konv_detection];

%% Combine AF and No AF matrices
konv_matrix = [AF_matrix;NoAF_matrix];

%%
% Biphasic_OR_matrix = [AF_matrix;NoAF_matrix];                         % 80;160;320;640;1280;2560
% '0','10','20','30','40','50','60','70','80','90'
% '10','20','30','40','50','60','70','80','90','100'
% 'P0','P1','P2','P3','P4','P5','P6','P7','P8','P9','P28','P29','P30','P31','P32','P33','P34','P35'
konv_table = array2table(konv_matrix, 'VariableNames',{'Event','Duration','Age','Gender','Konventional'});
writetable(konv_table,'konv_table.csv')

%% 
AND_matrix_for_SPSS=AND_matrix(:,1);

% for i=1:length(AND_matrix)
% if  AND_matrix(i,11)==1
%     AND_matrix_for_SPSS(i,2)=10; 
% elseif AND_matrix(i,10)==1
%          AND_matrix_for_SPSS(i,2)=9; 
% elseif AND_matrix(i,9)==1
%          AND_matrix_for_SPSS(i,2)=8; 
% elseif AND_matrix(i,8)==1
%          AND_matrix_for_SPSS(i,2)=7; 
% elseif AND_matrix(i,7)==1
%          AND_matrix_for_SPSS(i,2)=6;
% elseif AND_matrix(i,6)==1
%          AND_matrix_for_SPSS(i,2)=5;
% elseif AND_matrix(i,5)==1
%          AND_matrix_for_SPSS(i,2)=4;
% elseif AND_matrix(i,4)==1
%          AND_matrix_for_SPSS(i,2)=3;
% elseif AND_matrix(i,3)==1
%          AND_matrix_for_SPSS(i,2)=2;
% elseif AND_matrix(i,2)==1
%          AND_matrix_for_SPSS(i,2)=1;
% end
% end

%% 
AND_matrix_for_SPSS=AND_matrix(:,1);

for i=1:length(AND_matrix)
if  AND_matrix(i,2)==1
    AND_matrix_for_SPSS(i,2)=10; 
elseif AND_matrix(i,3)==1
         AND_matrix_for_SPSS(i,2)=9; 
elseif AND_matrix(i,4)==1
         AND_matrix_for_SPSS(i,2)=8; 
elseif AND_matrix(i,5)==1
         AND_matrix_for_SPSS(i,2)=7; 
elseif AND_matrix(i,6)==1
         AND_matrix_for_SPSS(i,2)=6;
elseif AND_matrix(i,7)==1
         AND_matrix_for_SPSS(i,2)=5;
elseif AND_matrix(i,8)==1
         AND_matrix_for_SPSS(i,2)=4;
elseif AND_matrix(i,9)==1
         AND_matrix_for_SPSS(i,2)=3;
elseif AND_matrix(i,10)==1
         AND_matrix_for_SPSS(i,2)=2;
elseif AND_matrix(i,11)==1
         AND_matrix_for_SPSS(i,2)=1;
end
end