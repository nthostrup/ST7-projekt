%% Paired ROC test 
% Variables to be defined 

AUC_1=[0.592 0.680 0.593 0.622 0.631]; %[P0 OR AND Area Amplitude]
AUC_2=0.528; %conv 

SE_1=[0.005 0.005 0.005 0.005 0.005]; %(de er først forskellige på 4. decimal)
SE_2=0.005; 

r=[0.422 0.316 0.584 0.422 0.425]; %correlation coefficient 

% Calculation of Z. If Z is greater than 1,96 (two-sided) the curves are significantly
% different 

for i=1:length(AUC_1)
Z(i)=(AUC_1(i)-AUC_2)/sqrt(SE_1(i)^2+SE_2^2-r(i)*2*SE_1(i)*SE_2); 
end 

