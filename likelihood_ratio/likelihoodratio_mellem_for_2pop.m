%% protokol  
%Jeg køre AF-last-normal-ECG-variables -> GEP_offset -> AF_last_normal_ECG_GEpoffset_workspace og no_AF_ever_variables workspace ->No_AF_ever_variables_all_variables 
% kommando for første population: 
% load('\\hst.aau.dk\fileshares\CGraff-students1\IAB-data\AF-last-normal-ECG-variables\GE_POffset\AF_last_normal_ECG_GEpoffset_workspace.mat')

%kommando for anden population:
% load('No_AF_ever_variables_all_variables.mat')


% ny variabel med resultater for begge populationer (population1 i kollonne 1 og population 2 i kollonne 2): 
%resultater = zeros(109,2);
%rækker:
% 1. antal subjekter
% 2. antal konv_a-iab
% 3. antal bifasiske P0 med areal >160 
% 4-11 antal bifasiske +- x ift. 0. (ELLER) række 4 = +- 10, række 5= +-20 osv 
% 12-19 antal bifasiske +- x ift. 0. (OG) række 12 = +- 10, række 13= +-20 osv 
% 20-70 antal EKG'er, hvor arealet er over threshold. række 20 -> areal> 160, interval 100, op til 5160. 
% 71-110 antal EKG'er, hvor amplituden er over threshold. raekke 71 -> areal>10, interval 5, til 200 

%%
nrPopulation=2;
% antal subjekter i alt
resultater(1,nrPopulation)=length(a);

var= zeros(length(a),1);
for i=1:1:length(a)
if (konv_biphasic_p_wave(i,1) == 1) && (konv_biphasic_p_wave(i,2) == 1) && (konv_biphasic_p_wave(i,3) == 1) && (p_iab(1,i)==1)
    var(i) = 1;
end 
end
resultater(2,nrPopulation)=nnz(var);        % gem resulater

% bif p_0 med areal>160
var= zeros(length(a),1);
for i=1:1:length(a)
    if biphasic_p_wave(i,1) ==1 && p_iab(i)==1
        var(i) = 1; 
    end 
end 
resultater(3,nrPopulation)=nnz(var);        % gem resulater

disp('3 første test er kørt')

% 4-11 antal bifasiske +- x ift. 0. række 4 = +- 10, række 5= +-20 osv
for gradspaend = 10:10:80
    var= zeros(length(a),1);
    [detectionOutput_or] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave,  gradspaend, 0);
    % detectionOutput er en variabel, som med “1” eller “0” indikerer om metoden har fundet den givne karakteristika.
    % Data: biphasic_p_wave-matrice som er X*18 stor (X=antal subjekter) 
    % DegreeSpan: plus/minus gradspænd omkring P0, maks 80. Min 0.
    % andOrModifier: modtager 0 = OR og 1 = AND
    for i=1:1:length(a)
        if detectionOutput_or(i)==1 && p_iab(i)==1
            var(i)=1;
        end
    end 
    resultater(3+gradspaend/10,nrPopulation)=nnz(var);        % gem resulater i række 4-11
end

disp('færdig med eller')
%
% 12-19 antal bifasiske +- x ift. 0. (OG) række 12 = +- 10, række 13= +-20 osv  

for gradspaend = 10:10:80
    var= zeros(length(a),1);
    [detectionOutput_and] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave,  gradspaend, 1);
    % detectionOutput er en variabel, som med “1” eller “0” indikerer om metoden har fundet den givne karakteristika.
    % Data: biphasic_p_wave-matrice som er X*18 stor (X=antal subjekter) 
    % DegreeSpan: plus/minus gradspænd omkring P0, maks 80. Min 0.
    % andOrModifier: modtager 0 = OR og 1 = AND
    for i=1:1:length(a)
        if detectionOutput_and(i)==1 && p_iab(i)==1              % husk at lave variablen om til AND
            var(i)=1;
        end
    end
    resultater(11+gradspaend/10,nrPopulation)=nnz(var);        % gem resulater i række 12-19
end

disp('færdig med og')

% Areal
raekke = 0;
for threshold = 160:100:5160
    raekke = raekke + 1; 
    var= zeros(length(a),1);
    for i=1:1:length(a)
        [detectionOutput] = areaDetectionMethod(sum_p_inv_loop(i,1), sum_p_loop(i,1), threshold);
        % % detectionOutput er en variabel, som med “1” eller “0” indikerer om metoden har fundet den givne karakteristika.
        % Sum_p_inv_loop: Array med værdi for areal for P’ kurve for P0.
        % Threshold: grænseværdi for det minimumsareal for detektion. (min 0, max 10000
        if detectionOutput==1 && p_iab(i)==1
            var(i)=1;
        end
    end 
    resultater(19+raekke,nrPopulation)=nnz(var);        % gem resulater i række 20-50
    disp(raekke)
end 
disp('færdig med areal')

% amplitude
raekke = 0;
for threshold = 10:5:200
    raekke = raekke + 1; 
    var= zeros(length(a),1);
    for i=1:1:length(a)
        [detectionOutput] = amplitudeDetectionMethod(p_prime_ampl(i,1), threshold);
        % detectionOutput er en variabel, som med “1” eller “0” indikerer om metoden har fundet den givne karakteristika.
        % PprimeAmp: Array med amplitude målt i de 18 pseudo leads.
        % Threshold: threshold for amplituden, skal være positiv
        if detectionOutput==1 && p_iab(i)==1
            var(i)=1;
        end
    end 
    resultater(70+raekke,nrPopulation)=nnz(var);        % gem resulater i række 70-110
end 

disp('færdig ')

disp(resultater)


%% likelihood ratio
%resultater: (kopieret)
% 1. antal subjekter
% 2. antal konv_a-iab
% 3. antal bifasiske P0 med areal >160 
% 4-11 antal bifasiske +- x ift. 0. (ELLER) række 4 = +- 10, række 5= +-20 osv 
% 12-19 antal bifasiske +- x ift. 0. (OG) række 12 = +- 10, række 13= +-20 osv 
% 20-70 antal EKG'er, hvor arealet er over threshold. række 20 -> areal> 160, interval 100, op til 5160. 
% 71-110 antal EKG'er, hvor amplituden er over threshold. raekke 71 -> areal>10, interval 5, til 200

nrPopulation = 1; % skal være 1.
% rækkerne er test
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

likelihood_data = zeros(109,2);
% TP
for test = 2:1:length(resultater)
likelihood_data(test,1) = resultater(test,nrPopulation);                            %TP
likelihood_data(test,2) = resultater(1,nrPopulation)-resultater(test,nrPopulation);  %FN
likelihood_data(test,3) = resultater(test,nrPopulation+1);                            %FP
likelihood_data(test,4) = resultater(1,nrPopulation+1)-resultater(test,nrPopulation+1);  %TN
likelihood_data(test,5) = likelihood_data(test,1)/(likelihood_data(test,1)+likelihood_data(test,4)); % TPR (sensitivity)
likelihood_data(test,6) = likelihood_data(test,2)/(likelihood_data(test,2)+likelihood_data(test,1)); % FNR
likelihood_data(test,7) = likelihood_data(test,3)/(likelihood_data(test,3)+likelihood_data(test,4)); % FPR
likelihood_data(test,8) = likelihood_data(test,4)/(likelihood_data(test,4)+likelihood_data(test,3)); % TNR (specificity)
likelihood_data(test,9) = likelihood_data(test,5)/likelihood_data(test,7); % LR+
likelihood_data(test,10) = likelihood_data(test,6)/likelihood_data(test,8); % LR-
likelihood_data(test,11) = likelihood_data(test,9)/likelihood_data(test,10);    %DOR
end 

%% plot
figure;
plot(likelihood_data(:,11))
legend('DOR')

figure;
plot(likelihood_data(:,9))
legend('LR+')

figure;
plot(likelihood_data(:,10))
legend('LR-')

%% 
for i=1:1:length(a)
    if sum_p_inv_loop(i,1)==-160
        disp(i)
    end
end 
