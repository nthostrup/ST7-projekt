 %%  No AF ever gruppen
load('No_AF_ever_XML_loaded.mat')

%% beregn duration i dage
XML = No_AF_ever_XML_loaded;
enddate = datetime(2015,12,31,23,59,59);

i = 1;
count=0;
k=1;
 while i<=length(XML) 
   if  strcmp(XML(i).TestInfo.Gender, 'MALE')
       NoAF_gender(i) = 0;
       i = i+1;             %% only add to counter if no sample is removed
   elseif strcmp(XML(i).TestInfo.Gender, 'FEMALE')
       NoAF_gender(i) = 1;
       i = i+1;             %% only add to counter if no sample is removed
   else
       XML(i) = [];
       indexesRemoved(k)=i+count;
       count = count+1;
       k=k+1;
       X_disp = sprintf('Sample %i removed',i);
       disp(X_disp)
   end 

 end
 %%
 k=1;
while k <= length(XML)
   NoAF_age(k) = XML(k).TestInfo.PatientAge;
   date_No_AF_ever_ECG{k} = XML(k).TestInfo.AcqDateTime;
    t = datetime(date_No_AF_ever_ECG(k),'InputFormat','yyyy-MM-dd HH:mm:ss');
    diff = enddate-t;
    NoAF_duration(k) = days(diff);
   k = k+1;
end

NoAF_gender = NoAF_gender';
NoAF_age = NoAF_age;
NoAF_duration = NoAF_duration';



 %% Detection på No AF Ever gruppen
load('No_AF_ever_variables_all_variables.mat')

 %%
 [x,y] = ismember(indexesRemoved,biphasic_p_wave);
 biphasic_p_wave(y(x)) = [];
 %%
% 
% % Konventionel  - få integreret p>120 ms
% [NoAF_konv_detection] = konventionalDetectionMethod(konv_biphasic_p_wave, konv_p_iab);
% NoAF_konv_detection = NoAF_konv_detection';
% Biphasic P0
[NoAF_biphasic_90_p0_detection] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave,90,0);
NoAF_biphasic_p0_detection = NoAF_biphasic_p0_detection';
% 
% % Biphasic +/- 50 OR
% [NoAF_biphasic_p0_OR_50_detection] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave,50,0);
% NoAF_biphasic_p0_OR_50_detection = NoAF_biphasic_p0_OR_50_detection';
% 
% % P0' area > 2 mikroV
% [NoAF_area_2microV] = areaDetectionMethod(sum_p_inv_loop, sum_p_loop, 2);
% NoAF_area_2microV = NoAF_area_2microV';
% 
% % P0' amplitude > 10 mikroV
% [NoAF_amplitude_10] = amplitudeDetectionMethod(p_prime_ampl, 10);
% NoAF_amplitude_10 = NoAF_amplitude_10';


% Alle Biphasic +/- AND metoder
% span = [10;20;30;40;50;60;70;80;90;100];
% for i=1:length(span)
% [NoAF_amplitude_detection(:,i)] = amplitudeDetectionMethod(p_prime_ampl, span(i));
% end
%NoAF_biphasic_area_detection = NoAF_biphasic_area_detection(:,9);
%%
NoAF_event = zeros(length(XML),1);
 
NoAF_matrix = [NoAF_event NoAF_duration NoAF_konv_detection NoAF_biphasic_p0_detection NoAF_biphasic_p0_OR_50_detection NoAF_biphasic_p0_AND_10_detection NoAF_area_2microV NoAF_amplitude_10];
%NoAF_matrix = [NoAF_event NoAF_duration NoAF_amplitude_detection];


%% Find tid mellem last normal og first AF ECG gruppen
load('AF_first_ECG.mat')
load('AF_last_normal_ECG_XML_loaded.mat')

%% Fjern data med kun én tid og beregn duration i dage
[intersectedData] = intersectXMLsOnIDs(AF_first_ECG,AF_last_normal_ECG_XML_loaded);
%%
AF_index = [intersectedData.IndexLastNormal]';
AF_duration = [intersectedData.duration]';
AF_data_onlyIndex = AF_last_normal_ECG_XML_loaded(AF_index);



j = 1;          %% Rykke tjek for gender op over intersecteddata
 while j<=length(AF_data_onlyIndex) 
    if  strcmp(AF_data_onlyIndex(j).TestInfo.Gender, 'MALE')
       AF_gender(j) = 0;
       j = j+1;
    elseif strcmp(AF_data_onlyIndex(j).TestInfo.Gender, 'FEMALE')
       AF_gender(j) = 1;
       j = j+1;
    else
       AF_data_onlyIndex(j) = [];
       Y_disp = j;
       disp(Y_disp)
    end 
   
 end
 
 AF_gender = AF_gender';

 %%
 
for i = 1:length(AF_data_onlyIndex)
    AF_age(i) = AF_data_onlyIndex(i).TestInfo.PatientAge;
end
AF_age = AF_age';

%% Detection på AF gruppen    
load('AF_last_normal_ECG_GEpoffset_workspace.mat')
%%
% % Konventionel  - få integreret p>120 ms
% [AF_konv_detection] = konventionalDetectionMethod(konv_biphasic_p_wave(AF_index,:), konv_p_iab(AF_index));
% AF_konv_detection = AF_konv_detection';
% 
% % Biphasic P0
% [AF_biphasic_p0_detection] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave(AF_index,:),0,0);
% AF_biphasic_p0_detection = AF_biphasic_p0_detection';
% 
% % P0' area > 2 mikroV
% [AF_area_2microV] = areaDetectionMethod(sum_p_inv_loop(AF_index), sum_p_loop(AF_index), 2);
% AF_area_2microV = AF_area_2microV';
% 
% % P0' amplitude > 10 mikroV
% [AF_amplitude_10] = amplitudeDetectionMethod(p_prime_ampl(AF_index), 10);
% AF_amplitude_10 = AF_amplitude_10';

span = [10;20;30;40;50;60;70;80;90;100];
for i=1:length(span)
[AF_amplitude_detection(:,i)] = amplitudeDetectionMethod(p_prime_ampl(AF_index,:), span(i));
end
%AF_biphasic_area_detection = AF_biphasic_area_detection;

%% Lav AF matrice

AF_event = ones(length(AF_duration),1);

%AF_matrix = [AF_event AF_duration AF_konv_detection AF_biphasic_p0_detection AF_biphasic_p0_OR_50_detection AF_biphasic_p0_AND_10_detection AF_area_2microV AF_amplitude_10];
AF_matrix = [AF_event AF_duration AF_amplitude_detection];

%% Combine AF and No AF matrices
ampl_matrix = [AF_matrix;NoAF_matrix];

% Biphasic_OR_matrix = [AF_matrix;NoAF_matrix];                         % 80;160;320;640;1280;2560
% %
% 
ampl_table = array2table(ampl_matrix, 'VariableNames',{'Event','Duration','10','20','30','40','50','60','70','80','90','100'});
datestr
 writetable(ampl_table,strcat('ampl_Table_',datestr(datetime("now")),'.csv'))



