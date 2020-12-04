function[PC1_direction,PC1_direction_total_mean, PC1_direction_total_SD] = directionCalc(XML)
% input: 
% XML filer som er loaded, og kørt igennem parser'en. De hedder eksempelvis AF_last_normal_ECG_XML_loaded

% output: 
% PC1_direction er alle PC1-retninger for alle subjekter (3*(antal subjekter matrice))
% PC1_direction_total_mean er gennemsnit af alle retningerne for PC1_direction (1*3 matrice)
% PC1_direction_total_SD er en samlet matrice med standardafvigelsen i x, y og z retningen (1*3 matrice) 

% kors transformation
T=[-0.130 0.050 -0.010 0.140 0.060 0.540 0.380 -0.07;
     0.060 -0.020 -0.050 0.060 -0.170 0.130 -0.07 0.930;
     -0.430 -0.06 -0.140 -0.20 -0.110 0.310 0.110 -0.23]';
 
for i=1:length(XML)
    % Define part of ECG
    On(i)=XML(i).TestInfo.POnset;
    Off(i)=XML(i).TestInfo.POffset;    
end 

for i=1:1:length(XML)
    ecg = [XML(i).MedianECG.V1 XML(i).MedianECG.V2 XML(i).MedianECG.V3 XML(i).MedianECG.V4 XML(i).MedianECG.V5 XML(i).MedianECG.V6 XML(i).MedianECG.I XML(i).MedianECG.II]; %Sætter EKG i rigtig rækkefølge ift. transformering
    VCG_T(i,:,:) = (ecg*T); %transformed VCG
end 

%
for i=1:1:length(XML)
    [leadprojlength, Pseudo_electrodes(i,:,:), numerationOfElectrodes, PC12_ratio(i),PC1_direction(:,i)] = PseudoLeadsCalc(squeeze(VCG_T(i,On(i):Off(i),:)));   
end

% PC1_direction er nu beregnet til en 3*(antal af subjekter) matrice. 

% plot 
%close all
%scatter3(PC1_direction(1,:),PC1_direction(2,:),PC1_direction(3,:))
%hold on 
%str = 1;
%plot3([-str str],[0 0],[0 0],'k',[0 0],[-str str],[0 0],'k',[0 0],[0 0],[-str str],'k'); % plotter et kryds i 3D plottet
%text(str,0,0,'Left'); text(-str,0,0,'Right'); text(0,str,0,'Posterior'); text(0,-str,0,'Anterior'); text(0,0,str,'Superior'); text(0,0,-str,'Inferior');


% means og SD 
x_direction_mean = mean(PC1_direction(1,1:end),2);
y_direction_mean = mean(PC1_direction(2,1:end),2);
z_direction_mean = mean(PC1_direction(3,1:end),2);
PC1_direction_total_mean = [x_direction_mean,y_direction_mean,z_direction_mean];

x_direction_SD = std(PC1_direction(1,1:end));
y_direction_SD = std(PC1_direction(2,1:end));
z_direction_SD = std(PC1_direction(3,1:end));
PC1_direction_total_SD = [x_direction_SD, y_direction_SD, z_direction_SD];

%hold on 
%plot3([0 x_direction_mean], [0 y_direction_mean], [0 z_direction_mean])
%hold on
%Linewidth = 2;
%plot3([x_direction_mean-x_direction_SD x_direction_mean+x_direction_SD],[y_direction_mean y_direction_mean],[z_direction_mean z_direction_mean],'k','LineWidth',Linewidth,'Marker','|')
%plot3([x_direction_mean x_direction_mean],[y_direction_mean-y_direction_SD y_direction_mean+y_direction_SD],[z_direction_mean z_direction_mean],'k','LineWidth',Linewidth,'Marker','|')
%plot3([x_direction_mean x_direction_mean],[y_direction_mean y_direction_mean],[z_direction_mean-z_direction_SD z_direction_mean+z_direction_SD],'k','LineWidth',Linewidth,'Marker','|')

end 