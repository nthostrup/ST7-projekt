%%  No AF ever gruppen
load('Variables_for_No_AF_Ever.mat')%starter med denne gruppe da den er mindst

NoAF_biphasicleads = biphasic_p_wave;

% choose the span that fits the method used
span = [0;10;20;30;40;50;60;70;80]; %Degree span
%span=[10;20;40;80;160;320;640;1280;2580]; % Area
%span=[2;4;8;10;20;30;40;50;60;70;80;90;100]; % Amplitude 

for i=1:length(span)
    %[NoAF_detection(:,i)] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave,span(1),0); %P0
    [NoAF_detection(:,i)]=konventionalDetectionMethod(konv_biphasic_p_wave,konv_p_iab); 
    %[NoAF_detection(:,i)] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave,span(i),0);
    %[NoAF_detection(:,i)] = areaDetectionMethod(sum_p_inv_loop, sum_p_loop, span(i));
    %[NoAF_detection(:,i)] = amplitudeDetectionMethod(p_prime_ampl,span(i));
end


NoAF_event = zeros(length(NoAF_biphasicleads),1);
NoAF_matrix = [NoAF_event NoAF_detection];

load('Variables_for_AF-last-normal.mat')

for i=1:length(span)
    %[AF_detection(:,i)] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave,span(1),0);
    [AF_detection(:,i)]=konventionalDetectionMethod(konv_biphasic_p_wave,konv_p_iab); 
    %[AF_detection(:,i)] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave,span(i),0);
    %[AF_detection(:,i)] = areaDetectionMethod(sum_p_inv_loop, sum_p_loop, span(i));
    %[AF_detection(:,i)] = amplitudeDetectionMethod(p_prime_ampl,span(i));
end


AF_event = ones(length(AF_detection),1);
AF_matrix = [AF_event AF_detection];

total_matrix = [AF_matrix;NoAF_matrix];

total_matrix_for_SPSS=total_matrix(:,1);

total_matrix_for_SPSS=total_matrix(:,1);

%% P0 and Conv
total_matrix_for_SPSS=total_matrix(:,(1:2));

%% Use when AND, amplitude or Area is calculated

% for i=1:length(total_matrix)
%     if  total_matrix(i,13)==1
%         total_matrix_for_SPSS(i,2)=12;
%     elseif  total_matrix(i,12)==1
%         total_matrix_for_SPSS(i,2)=11;
%     elseif  total_matrix(i,11)==1
%         total_matrix_for_SPSS(i,2)=10;
%     elseif total_matrix(i,10)==1
%         total_matrix_for_SPSS(i,2)=9;
%     elseif total_matrix(i,9)==1
%         total_matrix_for_SPSS(i,2)=8;
%     elseif total_matrix(i,8)==1
%         total_matrix_for_SPSS(i,2)=7;
%     elseif total_matrix(i,7)==1
%         total_matrix_for_SPSS(i,2)=6;
%     elseif total_matrix(i,6)==1
%         total_matrix_for_SPSS(i,2)=5;
%     elseif total_matrix(i,5)==1
%         total_matrix_for_SPSS(i,2)=4;
%     elseif total_matrix(i,4)==1
%         total_matrix_for_SPSS(i,2)=3;
%     elseif total_matrix(i,3)==1
%         total_matrix_for_SPSS(i,2)=2;
%     elseif total_matrix(i,2)==1
%         total_matrix_for_SPSS(i,2)=1;
%     end
% end

%% Use when OR is calculated

% for i=1:length(total_matrix)
%     if  total_matrix(i,2)==1
%         total_matrix_for_SPSS(i,2)=10;
%     elseif total_matrix(i,3)==1
%         total_matrix_for_SPSS(i,2)=9;
%     elseif total_matrix(i,4)==1
%         total_matrix_for_SPSS(i,2)=8;
%     elseif total_matrix(i,5)==1
%         total_matrix_for_SPSS(i,2)=7;
%     elseif total_matrix(i,6)==1
%         total_matrix_for_SPSS(i,2)=6;
%     elseif total_matrix(i,7)==1
%         total_matrix_for_SPSS(i,2)=5;
%     elseif total_matrix(i,8)==1
%         total_matrix_for_SPSS(i,2)=4;
%     elseif total_matrix(i,9)==1
%         total_matrix_for_SPSS(i,2)=3;
%     elseif total_matrix(i,10)==1
%         total_matrix_for_SPSS(i,2)=2;
%    % elseif total_matrix(i,11)==1
%     %    total_matrix_for_SPSS(i,2)=1;
%     end
% end