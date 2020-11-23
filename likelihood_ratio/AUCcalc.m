
% load "res_og_likelihood_for_med_og_uden_dur_krav.mat"

%R�kker
% 1. antal subjekter
% 2. antal konv_a-iab
% 3. antal bifasiske P0 med areal >160
% 4-11 antal bifasiske +- x ift. 0. (ELLER) række 4 = +- 10, række 5= +-20 osv
% 12-19 antal bifasiske +- x ift. 0. (OG) række 12 = +- 10, række 13= +-20 osv
% 20-219 antal EKG'er, hvor arealet er over threshold. række 20 -> areal> 10, interval 10, op til 2000.
% 220-269 antal EKG'er, hvor amplituden er over threshold. raekke 220 -> amplitude >2, interval 2, til 100


%Likelihood variabel
%kolonnerne er:
% 1. True positive
% 2. False negative
% 3. False positive
% 4. True negative
% 5. sensitivity = true positive ratio = TP/(TP+FN)
% 6. False Negative Ratio (FNR) -> FN/(TP+FN)
% 7. False Positive Ratio (FPR) -> FP/(FP+TN)
% 8. specificity (True Negative Ratio (TNR)) -> TN/(FP+TN)
% 9. LR+ -> TPR/FPR
% 10. LR- -> FNR/TNR
% 11. DOR = LR+/LR-

%% Calc ROC-curve
% 1=MED duration >120ms
% 2= UDEN duration krav for pseudoleads
method_iterations=diff(opdeling);

OR_curve_sens=[];
OR_curve_falsePos=[];
AND_curve_sens=[];
AND_curve_falsePos=[];
Area_curve_sens=[];
Area_curve_falsePos=[];
Amp_curve_sens=[];
Amp_curve_falsePos=[];

for n=1:2
    if n==1
        likelihood_data=likelihood_data_MED_dur_krav;
    else
        likelihood_data=likelihood_data_UDEN_dur_krav;
    end
    %conv
    conv_curve_sens(n,:)=[0 likelihood_data(2,5) 1];
    conv_curve_falsePos(n,:)=[0 likelihood_data(2,7) 1];
    
    % P0
    P0_curve_sens(n,:)=[0 likelihood_data(3,5) 1];
    P0_curve_falsePos(n,:)=[0 likelihood_data(3,7) 1];
    
    %OR
    for i=1:method_iterations(3)
        OR_curve_sens_temp(i)=likelihood_data(opdeling(3)+i-1,5);
        OR_curve_falsePos_temp(i)=likelihood_data(opdeling(3)+i-1,7);
        
    end
    OR_curve_sens(n,:)=[0 likelihood_data(3,5) OR_curve_sens_temp 1]; %MED P0
    OR_curve_falsePos(n,:)=[0 likelihood_data(3,7) OR_curve_falsePos_temp 1]; %MED P0
    
    %AND
    for i=1:method_iterations(4)
        AND_curve_sens_temp(i)=likelihood_data(opdeling(4)+i-1,5);
        AND_curve_falsePos_temp(i)=likelihood_data(opdeling(4)+i-1,7);
    end
    AND_curve_sens(n,:)=[0 flip(AND_curve_sens_temp) likelihood_data(3,5) 1]; %MED P0
    AND_curve_falsePos(n,:)=[0 flip(AND_curve_falsePos_temp) likelihood_data(3,7) 1]; % MED P0
    
    %Area
    for i=1:method_iterations(5)
        Area_curve_sens_temp(i)=likelihood_data(opdeling(5)+i-1,5);
        Area_curve_falsePos_temp(i)=likelihood_data(opdeling(5)+i-1,7);
    end
    Area_curve_sens(n,:)=[0 flip(Area_curve_sens_temp) 1];
    Area_curve_falsePos(n,:)=[0 flip(Area_curve_falsePos_temp) 1];
    
    %Amplitude
    for i=1:method_iterations(6)
        Amp_curve_sens_temp(i)=likelihood_data(opdeling(6)+i-1,5);
        Amp_curve_falsePos_temp(i)=likelihood_data(opdeling(6)+i-1,7);
    end
    
    Amp_curve_sens(n,:)=[0 flip(Amp_curve_sens_temp) 1];
    Amp_curve_falsePos(n,:)=[0 flip(Amp_curve_falsePos_temp) 1];
    
end

%% Plot
for n=1:2
    subplot(1,2,n)
    plot(OR_curve_falsePos(n,:),OR_curve_sens(n,:),'-*','LineWidth',1.5); hold on;
    plot(Amp_curve_falsePos(n,:),Amp_curve_sens(n,:),'-*','LineWidth',1.5)
    plot(Area_curve_falsePos(n,:),Area_curve_sens(n,:),'-*','LineWidth',1.5)
    plot(P0_curve_falsePos(n,:),P0_curve_sens(n,:),'-*','LineWidth',1.5)
    plot(AND_curve_falsePos(n,:),AND_curve_sens(n,:),'--*','LineWidth',1.5)
    plot(conv_curve_falsePos(n,:),conv_curve_sens(n,:),'-*','LineWidth',1.5);
    plot([0 1],[0 1],'k','LineWidth',1)
    hold off
    legend('OR','Amplitude','Area','P0','AND','Conventional A-IAB','Random line')
    grid on;
    xlabel('1-Specificity')
    ylabel('Sensitivity')
    if n==1
        title('ROC curves (p-wave duration >120)')
    else
        title('ROC curves (no restictions to p-wave duration)')
    end
    axis square
end

%% Calc AUC MED dur
for n=1:2
    AUC_conv(n)=trapz(conv_curve_falsePos(n,:),conv_curve_sens(n,:));
    AUC_P0(n)=trapz(P0_curve_falsePos(n,:),P0_curve_sens(n,:));
    AUC_OR(n)=trapz(OR_curve_falsePos(n,:),OR_curve_sens(n,:));
    AUC_AND(n)=trapz(AND_curve_falsePos(n,:),AND_curve_sens(n,:));
    AUC_Area(n)=trapz(Area_curve_falsePos(n,:),Area_curve_sens(n,:));
    AUC_Amp(n)=trapz(Amp_curve_falsePos(n,:),Amp_curve_sens(n,:));
    
    AUC_All(:,n)=[AUC_P0(n);AUC_OR(n);AUC_AND(n);AUC_Area(n);AUC_Amp(n)]
end

%% Determine the most effective threshold for each method (uden pdur)
[conv_max,conv_max_index]=max(conv_curve_sens(2,:)-conv_curve_falsePos(2,:));
[OR_max,OR_max_index]=max(OR_curve_sens(2,:)-OR_curve_falsePos(2,:));
[AND_max,AND_max_index]=max(AND_curve_sens(2,:)-AND_curve_falsePos(2,:));
[Area_max,Area_max_index]=max(Area_curve_sens(2,:)-Area_curve_falsePos(2,:));
[Amp_max,Amp_max_index]=max(Amp_curve_sens(2,:)-Amp_curve_falsePos(2,:));


