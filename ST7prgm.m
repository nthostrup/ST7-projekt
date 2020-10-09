% Clear all og Load data 
clear all;
close all; 

datafiledir='Testdata\';
xmlfiles=dir(fullfile(datafiledir,'*xml'));

%% Define dataset, transformation type and interval

%Angiv den konkrete fil der skal køres i scriptet ved index af xmlfiler
XML = XMLECGParser(xmlfiles(5).name);  

% Define part of ECG
On=XML.TestInfo.POnset;
Off=XML.TestInfo.POffset;
%On=1;
%Off=length(VCG_T);

% Invers Dower 
% T=[-0.172,-0.073,0.122,0.231,0.239,0.193,0.156,-0.009;
%     0.057,-0.019,-0.106,-0.022,0.040,0.048,-0.227,0.886;
%     -0.228,-0.310,-0.245,-0.063,0.054,0.108,0.021,0.102]';  

%Kors regression
T=[-0.130 0.050 -0.010 0.140 0.060 0.540 0.380 -0.07;
     0.060 -0.020 -0.050 0.060 -0.170 0.130 -0.07 0.930;
     -0.430 -0.06 -0.140 -0.20 -0.110 0.310 0.110 -0.23]';

%% Transformation
ecg = [XML.MedianECG.V1 XML.MedianECG.V2 XML.MedianECG.V3 XML.MedianECG.V4 XML.MedianECG.V5 XML.MedianECG.V6 XML.MedianECG.I XML.MedianECG.II]; %Sætter EKG i rigtig rækkefølge ift. transformering
III=XML.MedianECG.III;
aVF=XML.MedianECG.aVF;

VCG_T = (ecg*T); %transformed VCG

% Plot VCG + axis 
 figure()
scatter3(VCG_T(On:Off,1),VCG_T(On:Off,3),-VCG_T(On:Off,2),'r','.')
axis square
axis equal
axl=200; %axislength
axis([-axl axl -axl axl -axl axl]); 
grid on
xlabel('x');
ylabel('y');
zlabel('z');
hold on

str = axl;
plot3([-str str],[0 0],[0 0],'k',[0 0],[-str str],[0 0],'k',[0 0],[0 0],[-str str],'k'); % plotter et kryds i 3D plottet
text(str,0,0,'Left'); text(-str,0,0,'Right'); text(0,str,0,'Posterior'); text(0,-str,0,'Anterior'); text(0,0,str,'Superior'); text(0,0,-str,'Inferior');

%% PCA 
VCG_T=[VCG_T(On:Off,1) VCG_T(On:Off,3) (-VCG_T(On:Off,2))];
VCG_T=VCG_T';

nPoints = length(VCG_T);

VCGavg = mean(VCG_T,2);               % Compute mean of rows 
B = VCG_T - VCGavg*ones(1,nPoints);   % Mean-subtracted Data
[U,S,V] = svd(B/sqrt(nPoints),'econ'); % PCA via SVD and normalization with the number of points
% U describes the rotation of the points and S describes the varians
% (the principal components)

%Define principal component (point)
PC1=[VCGavg(1)+U(1,1)*S(1,1) VCGavg(2)+U(2,1)*S(1,1) VCGavg(3)+U(3,1)*S(1,1)]; %PC1
PC2=[VCGavg(1)+U(1,2)*S(2,2) VCGavg(2)+U(2,2)*S(2,2) VCGavg(3)+U(3,2)*S(2,2)]; %PC2
PC3=[VCGavg(1)+U(1,3)*S(3,3) VCGavg(2)+U(2,3)*S(3,3) VCGavg(3)+U(3,3)*S(3,3)]; %PC3

% plot principal components 
 plot3([VCGavg(1) PC1(1)],[VCGavg(2) PC1(2)],[VCGavg(3) PC1(3)], 'b-')
 plot3([VCGavg(1) PC2(1)],[VCGavg(2) PC2(2)],[VCGavg(3) PC2(3)], 'g-')
 plot3([VCGavg(1) PC3(1)],[VCGavg(2) PC3(2)],[VCGavg(3) PC3(3)], 'c-')
 
%% Create plane 
% Normalvektoren til planet er vores 3. principalkomponents retning (U). 
syms x y z
planeeq=dot(U(:,3),[x,y,z]-VCGavg');
Z=solve(planeeq==0,z);

fsurf(Z,'FaceColor','y','EdgeColor','none','facealpha',0.2)


%% PCA origo 
%pcaorig=solve(dot(pcaorig(:,3),[x,y,z]-VCGavg'==0),pcaorig);

%% Electrodes ift. origo 
Ori = [0;0;0]; %origo 
c=5; %konstant til at forlænge pseudoleads

P1=[VCGavg(1)+U(1,1)*S(1,1)*c VCGavg(2)+U(2,1)*S(1,1)*c VCGavg(3)+U(3,1)*S(1,1)*c]; %lead som de andre leads tager udgangspunkt i 

%Beregn elektrodepunkter fra origo til punkter på planet 
P(1,:)=P1;
for i=1:35  
    theta(i) = 10*i*pi/180;
    P(i+1,:) = P1*cos(theta(i)) +cross(U(:,3),P1)*sin(theta(i))+ U(:,3)'*dot(U(:,3),P1)*(1-cos(theta(i))); %Rodrigues formel 
end

pcaorig=sum(P,1)/length(P);
%plot3([0 U(1,3)*20],[0 U(2,3)*20],[0 U(3,3)*20]);
plot3([0 pcaorig(1)],[0 pcaorig(2)],[0 pcaorig(3)]);

%Plot pseudoleads
for i=1:36
   plot3([pcaorig(1) P(i,1)],[pcaorig(2) P(i,2)], [pcaorig(3) P(i,3)],'g') 
end

%% plot 
VCG_T=VCG_T-pcaorig';
scatter3(VCG_T(1,:),VCG_T(2,:),VCG_T(3,:),'r','.')

%% Electrodes ift. PCA(0,0,0)

for i=1:36
    P_new(i,:)=P(i,:)-pcaorig;
end

for i=1:36
   plot3([0 P_new(i,1)],[0 P_new(i,2)], [0 P_new(i,3)],'g') 
end



%% Projection 
%Indtil videre beregnes kun for lead 1. Der er heller ikke inkoorporeret
%den "negative længde"

%lead=P(1,:)'; 
figure()
for j=1:length(P)/2 %ser kun på 180 grader
    lead=P(j,:)';
    for i=1:length(VCG_T)
        pointvec=VCG_T(:,i);
        projvec(i,:)=((dot(pointvec,lead))/(sqrt(lead(1)^2+lead(2)^2+lead(3)^2)^2))*lead; %Projection af pointvec på valgte lead.
        leadprojvec(j,i,:)=projvec(i,:);
        
        if dot(projvec(i,:),lead)<0
            projlength(i)=-sqrt(projvec(i,1)^2+projvec(i,2)^2+projvec(i,3)^2); %beregning af projektionsvektor-længder
            leadprojlength(j,i)=projlength(i);
        else
            projlength(i)=sqrt(projvec(i,1)^2+projvec(i,2)^2+projvec(i,3)^2); %beregning af projektionsvektor-længder
            leadprojlength(j,i)=projlength(i);
        end
    end
    subplot(2,1,1)
    plot(leadprojlength(j,:)); hold on; 
    axis square 
end

subplot(2,1,2) 
plot(ecg(On:Off));hold on;
plot(III(On:Off));
plot(aVF(On:Off));
axis square


