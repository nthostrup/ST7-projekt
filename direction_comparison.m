
function[]=direction_comparison(NewMethod)
%% obs: Alle variablerne skal være loadet for XML filen!
load('AF_last_normal_ECG_XML_loaded.mat')
XML = AF_last_normal_ECG_XML_loaded;
load('Variables_for_AF-last-normal.mat');
%%
XML = AF_last_normal_ECG_XML_loaded;
NewMethod = 2           % den test du vil vise plots på 

X=['Analysering af metode M',num2str(NewMethod)];
disp(X)
% beregn hvem der har konv A-IAB
[detectionOutput] = konventionalDetectionMethod(konv_biphasic_p_wave,  konv_p_iab); 

nr = 1;
clear AIAB_population;
for i=1:1:length(XML)   
    if detectionOutput(i) == 1
    AIAB_population(1,nr) = XML(1,i);
    nr=nr+1;
    end 
end 

%%
% Beregn populationen der er detekteret med den angivne metode
switch NewMethod
    case 1 % P0-bifase
        detectionOutput = 0;
        detectionOutput = biphasic_p_wave(:,1); % kolonne for P0. 
        legend_title = 'M1';
        figureTitle = 'Primary unitary vector for an A-IAB and M1 detected population';
        figureTitle_AF = 'Unitary PC1 for M1 positives, conventional positives and AF population';
        
    case 2 % bifasisk i et range (OR) for 50 grader! 
        detectionOutput = 0;
        gradspaend = 50;
        [detectionOutput] = biphasicPseudoLeadDetectionMethod(biphasic_p_wave,  gradspaend, 0); % 0 betyder OR-modifier 
        legend_title = 'M2';
        figureTitle = 'Primary unitary vector for an A-IAB and M2 detected population';
        figureTitle_AF = 'Unitary PC1 for M2 positives, conventional positives and AF population';

    case 3 % bifasisk i et range (AND) for 0 grader (samme som case 1)
        detectionOutput = 0;
        detectionOutput = biphasic_p_wave(:,1); % kolonne for P0, da det er i et gradspænd på 0 grader!       
        legend_title = 'M3';
        figureTitle = 'Primary unitary vector for an A-IAB and M3 detected population';
        figureTitle_AF = 'Unitary PC1 for M3 positives, conventional positives and AF population';

    case 4 %Areal på 20 muV*ms
        threshold = 20;
        for i=1:1:length(a)
        [detectionOutput(i)] = areaDetectionMethod(sum_p_inv_loop(i,1), sum_p_loop(i,1), threshold);
        end 
        legend_title = 'M4';
        figureTitle = 'Primary unitary vector for an A-IAB and M4 detected population';
        figureTitle_AF = 'Unitary PC1 for M4 positives, conventional positives and AF population';

    case 5 % Amplitude på 4 mu V
         for i=1:1:length(a)
        threshold = 4;     
        [detectionOutput(i)] = amplitudeDetectionMethod(p_prime_ampl(i,1), threshold);
         end 
         legend_title = 'M5';
        figureTitle = 'Primary unitary vector for an A-IAB and M5 detected population';
        figureTitle_AF = 'Unitary PC1 for M5 positives, conventional positives and AF population';

    otherwise
        disp('Du har angivet en metode, der ikke findes din torsk')
end

nr = 1;
clear NewMethod_population 
for i=1:1:length(XML)   
    if detectionOutput(i) == 1
    NewMethod_population(1,nr) = XML(1,i);
    nr=nr+1;
    end 
end  %%%%%% vær sikker på at den ikke overskriver  mellem metoderne
%%
%% Beregn retninger for populationerne 

[AIAB_PC1_direction,AIAB_PC1_direction_total_mean, AIAB_PC1_direction_total_SD] = directionCalc(AIAB_population);
%%
clear NewMethod_PC1_direction NewMethod_PC1_direction_total_mean NewMethod_PC1_direction_total_SD;
[NewMethod_PC1_direction,NewMethod_PC1_direction_total_mean, NewMethod_PC1_direction_total_SD] = directionCalc(NewMethod_population);

%% lav plot hvor standardafviglerne er givet. Det er plottet uden prikker  


% variables: 
% A-IAB:

AIABx = AIAB_PC1_direction_total_mean(1,1);
AIABy = AIAB_PC1_direction_total_mean(1,2);
AIABz = AIAB_PC1_direction_total_mean(1,3);
AIAB_SDx = AIAB_PC1_direction_total_SD(1,1);
AIAB_SDy = AIAB_PC1_direction_total_SD(1,2);
AIAB_SDz = AIAB_PC1_direction_total_SD(1,3);


% variables: 
% bifasisk i p0:
NewMethodx = NewMethod_PC1_direction_total_mean(1,1);
NewMethody = NewMethod_PC1_direction_total_mean(1,2);
NewMethodz = NewMethod_PC1_direction_total_mean(1,3);
NewMethod_SDx = NewMethod_PC1_direction_total_SD(1,1);
NewMethod_SDy = NewMethod_PC1_direction_total_SD(1,2);
NewMethod_SDz = NewMethod_PC1_direction_total_SD(1,3);

figure;
for i=1:1:3
subplot(1,3,i);
% A-IAB
plot3([0 AIABx], [0 AIABy], [0 AIABz], 'r', 'LineWidth',2)
hold on
% P0 bifasisk  
plot3([0 NewMethodx], [0 NewMethody], [0 NewMethodz],'b', 'LineWidth',2)
hold on 


% SD - A-IAB

switch i
    case 1
        view([0,0,1])
%kryds i midten
hold on
Linewidth=3;
plot3([AIABx-AIAB_SDx AIABx+AIAB_SDx],[AIABy AIABy],[AIABz AIABz],'r','Marker','|', 'LineWidth',Linewidth) %x SD
plot3([AIABx AIABx],[AIABy-AIAB_SDy AIABy+AIAB_SDy],[AIABz AIABz],'r','Marker','_', 'LineWidth',Linewidth) %y_SD
plot3([AIABx AIABx],[AIABy AIABy],[AIABz-AIAB_SDz AIABz+AIAB_SDz],'r','Marker','_', 'LineWidth',Linewidth) %z_SD


% SD - P0 bifasisk 
hold on
plot3([NewMethodx-NewMethod_SDx NewMethodx+NewMethod_SDx],[NewMethody NewMethody],[NewMethodz NewMethodz],'b','Marker','|', 'LineWidth',Linewidth) %x SD
plot3([NewMethodx NewMethodx],[NewMethody-NewMethod_SDy NewMethody+NewMethod_SDy],[NewMethodz NewMethodz],'b','Marker','_', 'LineWidth',Linewidth) %y_SD
plot3([NewMethodx NewMethodx],[NewMethody NewMethody],[NewMethodz-NewMethod_SDz NewMethodz+NewMethod_SDz],'b','Marker','_', 'LineWidth',Linewidth) %z_SD


hold on 
str = 1;
plot3([-str str],[0 0],[0 0],'k',[0 0],[-str str],[0 0],'k',[0 0],[0 0],[-str str],'k'); % plotter et kryds i 3D plottet
text(str,0,0,'Left'); text(-str,0,0,'Right'); text(0,str,0,'Posterior'); text(0,-str,0,'Anterior'); text(0,0,str,''); text(0,0,-str,'');

axis square;
    case 2
        view([0,1,0])
%kryds i midten
hold on
Linewidth=3;
plot3([AIABx-AIAB_SDx AIABx+AIAB_SDx],[AIABy AIABy],[AIABz AIABz],'r','Marker','|', 'LineWidth',Linewidth) %x SD
plot3([AIABx AIABx],[AIABy-AIAB_SDy AIABy+AIAB_SDy],[AIABz AIABz],'r','Marker','_', 'LineWidth',Linewidth) %y_SD
plot3([AIABx AIABx],[AIABy AIABy],[AIABz-AIAB_SDz AIABz+AIAB_SDz],'r','Marker','_', 'LineWidth',Linewidth) %z_SD


% SD - P0 bifasisk 
hold on
plot3([NewMethodx-NewMethod_SDx NewMethodx+NewMethod_SDx],[NewMethody NewMethody],[NewMethodz NewMethodz],'b','Marker','|', 'LineWidth',Linewidth) %x SD
plot3([NewMethodx NewMethodx],[NewMethody-NewMethod_SDy NewMethody+NewMethod_SDy],[NewMethodz NewMethodz],'b','Marker','_', 'LineWidth',Linewidth) %y_SD
plot3([NewMethodx NewMethodx],[NewMethody NewMethody],[NewMethodz-NewMethod_SDz NewMethodz+NewMethod_SDz],'b','Marker','_', 'LineWidth',Linewidth) %z_SD



hold on 
str = 1;
plot3([-str str],[0 0],[0 0],'k',[0 0],[-str str],[0 0],'k',[0 0],[0 0],[-str str],'k'); % plotter et kryds i 3D plottet
text(str,0,0,'Left'); text(-str,0,0,'Right'); text(0,str,0,''); text(0,-str,0,''); text(0,0,str,'Superior'); text(0,0,-str,'Inferior');
axis square;
   
        
        
    case 3
        view([1,0,0])
%kryds i midten
hold on
Linewidth=3;
plot3([AIABx-AIAB_SDx AIABx+AIAB_SDx],[AIABy AIABy],[AIABz AIABz],'r','Marker','|', 'LineWidth',Linewidth) %x SD
plot3([AIABx AIABx],[AIABy-AIAB_SDy AIABy+AIAB_SDy],[AIABz AIABz],'r','Marker','|', 'LineWidth',Linewidth) %y_SD
plot3([AIABx AIABx],[AIABy AIABy],[AIABz-AIAB_SDz AIABz+AIAB_SDz],'r','Marker','_', 'LineWidth',Linewidth) %z_SD


% SD - P0 bifasisk 
hold on
plot3([NewMethodx-NewMethod_SDx NewMethodx+NewMethod_SDx],[NewMethody NewMethody],[NewMethodz NewMethodz],'b','Marker','|', 'LineWidth',Linewidth) %x SD
plot3([NewMethodx NewMethodx],[NewMethody-NewMethod_SDy NewMethody+NewMethod_SDy],[NewMethodz NewMethodz],'b','Marker','|', 'LineWidth',Linewidth) %y_SD
plot3([NewMethodx NewMethodx],[NewMethody NewMethody],[NewMethodz-NewMethod_SDz NewMethodz+NewMethod_SDz],'b','Marker','_', 'LineWidth',Linewidth) %z_SD


hold on 
str = 1;
plot3([-str str],[0 0],[0 0],'k',[0 0],[-str str],[0 0],'k',[0 0],[0 0],[-str str],'k'); % plotter et kryds i 3D plottet
text(str,0,0,''); text(-str,0,0,''); text(0,str,0,'Posterior'); text(0,-str,0,'Anterior'); text(0,0,str,'Superior'); text(0,0,-str,'Inferior');

axis square;

% hold on 
%scatter3(P0_PC1_direction(1,:),P0_PC1_direction(2,:),P0_PC1_direction(3,:),'b','.')
%hold on 
%scatter3(AIAB_PC1_direction(1,:),AIAB_PC1_direction(2,:),AIAB_PC1_direction(3,:),'r','.')
end 
grid on
end 

%% teststatistik mellem AIAB og P0 bifasisk
disp('Teststatistik mellem AIAB og ny metode indikeret som inputparameter')
disp('x')
[h,p,~,~] = vartest2(NewMethod_PC1_direction(1,:),AIAB_PC1_direction(1,:))
disp('y')
[h,p,~,~] = vartest2(NewMethod_PC1_direction(2,:),AIAB_PC1_direction(2,:))
disp('z')
[h,p,~,~] = vartest2(NewMethod_PC1_direction(3,:),AIAB_PC1_direction(3,:))


%% lav plots med A-IAB og newMethod (plottet med prikkerne) 

% figure, subplot(1,2,1);
% scatter3(NewMethod_PC1_direction(1,:),NewMethod_PC1_direction(2,:),NewMethod_PC1_direction(3,:), 10,'filled','b')
% hold on 
% scatter3(0.99.*AIAB_PC1_direction(1,:),0.99.*AIAB_PC1_direction(2,:),0.99.*AIAB_PC1_direction(3,:), 10,'filled','r')
% hold on 
% str = 1;
% move = 0.2;
% plot3([-str str],[0 0],[0 0],'k',[0 0],[-str str],[0 0],'k',[0 0],[0 0],[-str str],'k', 'LineWidth',1); % plotter et kryds i 3D plottet
% textSize = 10;
% text(str+move,0,0,'Left','FontSize', textSize, 'fontweight', 'bold'); text(-str-move,0,0,'Right','FontSize', textSize, 'fontweight', 'bold' ); text(0,str+move,0,'Posterior','FontSize', textSize, 'fontweight', 'bold'); text(0,-str-move,0,'Anterior','FontSize', textSize, 'fontweight', 'bold'); text(0,0,str+move,'Superior','FontSize', textSize, 'fontweight', 'bold'); text(0,0,-str-move,'Inferior','FontSize', textSize, 'fontweight', 'bold');
% title(figureTitle)
% 
% legend(legend_title, 'A-IAB')
% axis square
% xlabel('x')
% ylabel('y')
% zlabel('z')

%% lav varianstest mellem hele last_normal_ecg og p0_bif
[LastNormalECG_PC1_direction,LastNormalECG_PC1_direction_total_mean, LastNormalECG_PC1_direction_total_SD] = directionCalc(AF_last_normal_ECG_XML_loaded);

%% lav plots med hele AF-populationen, newMethod og A-IAB (plottet med prikkerne) 

%subplot(1,2,2);
figure;
scatter3(LastNormalECG_PC1_direction(1,:),LastNormalECG_PC1_direction(2,:),LastNormalECG_PC1_direction(3,:), 10,'filled','b')
hold on 
scatter3(0.99.*NewMethod_PC1_direction(1,:),0.99.*NewMethod_PC1_direction(2,:),0.99.*NewMethod_PC1_direction(3,:), 10,'filled','g')
hold on 
scatter3(0.98.*AIAB_PC1_direction(1,:),0.98.*AIAB_PC1_direction(2,:),0.98.*AIAB_PC1_direction(3,:), 10,'filled','r')


str = 1;
plot3([-str str],[0 0],[0 0],'k',[0 0],[-str str],[0 0],'k',[0 0],[0 0],[-str str],'k', 'LineWidth',1); % plotter et kryds i 3D plottet
textSize = 10;
move = 0.2;
text(str+move,0,0,'Left','FontSize', textSize, 'fontweight', 'bold'); text(-str-move,0,0,'Right','FontSize', textSize, 'fontweight', 'bold' ); text(0,str+move,0,'Posterior','FontSize', textSize, 'fontweight', 'bold'); text(0,-str-move,0,'Anterior','FontSize', textSize, 'fontweight', 'bold'); text(0,0,str+move,'Superior','FontSize', textSize, 'fontweight', 'bold'); text(0,0,-str-move,'Inferior','FontSize', textSize, 'fontweight', 'bold');
title(figureTitle_AF)

%hold on 
%plot3([0 LastNormalECG_PC1_direction_total_mean(1,1)], [0 LastNormalECG_PC1_direction_total_mean(1,2)], [0 LastNormalECG_PC1_direction_total_mean(1,3)],'LineWidth',5,'Marker','o', 'Color','b')
%hold on
%plot3([0 AIABx], [0 AIABy], [0 AIABz],'LineWidth',5,'Marker','o','Color','r')

legend('AF population', legend_title, 'A-IAB') %% husk at ændre til Conventional
axis square
xlabel('x')
ylabel('y')
zlabel('z')
%Linewidth = 2;
%plot3([x_direction_mean-x_direction_SD x_direction_mean+x_direction_SD],[y_direction_mean y_direction_mean],[z_direction_mean z_direction_mean],'k','LineWidth',Linewidth,'Marker','|')
%plot3([x_direction_mean x_direction_mean],[y_direction_mean-y_direction_SD y_direction_mean+y_direction_SD],[z_direction_mean z_direction_mean],'k','LineWidth',Linewidth,'Marker','|')
%plot3([x_direction_mean x_direction_mean],[y_direction_mean y_direction_mean],[z_direction_mean-z_direction_SD z_direction_mean+z_direction_SD],'k','LineWidth',Linewidth,'Marker','|')




%% test statistik mellem P0 bifasisk og hele gruppen der får AF
disp('Teststatistik mellem  ny metode indikeret som inputparameter og hele AF gruppen')

disp('x')
[h,p,~,~] = vartest2(NewMethod_PC1_direction(1,:),LastNormalECG_PC1_direction(1,:))
disp('y')
[h,p,~,~] = vartest2(NewMethod_PC1_direction(2,:),LastNormalECG_PC1_direction(2,:))
disp('z')
[h,p,~,~] = vartest2(NewMethod_PC1_direction(3,:),LastNormalECG_PC1_direction(3,:))

disp('SD for last normal ECG')
disp(LastNormalECG_PC1_direction_total_SD)


end 