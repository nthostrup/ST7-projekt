function [leadprojlength, Pseudo_electrodes, numerationOfElectrodes,PC12_ratio, PC1_direction, PC3_direction] = PseudoLeadsCalc(VCG_in)
%% Purpose: 
%Inputs:
    %VCG_in: VCG either full ECG or p-loop only. size: 3xSamples. !!Not arranged according to correct convention!!
%Outputs:
    %leadprojlength: Length of the projection of each point returned (vector with leads).
    %Pseudo_electrodes: Coordinates for the electrodes which defines the endpoint of the leads
    %numerationOfElectrodes: Label for the electrodes returned
    %PC12_ratio: Ratio between PC1 and PC2.


%Arrange axis correct as by convention
VCG_T=[VCG_in(:,1) VCG_in(:,3) -VCG_in(:,2)];

%% PCA 
VCG_T=VCG_T';
nPoints = length(VCG_T);

VCGavg = mean(VCG_T,2);               % Compute mean of rows 
B = VCG_T - VCGavg*ones(1,nPoints);   % Mean-subtracted Data
[U,S,V] = svd(B/sqrt(nPoints),'econ'); % PCA via SVD and normalization with the number of points
% U describes the rotation of the points and S describes the varians
% (the principal components)

%% Check the direction of PC1. Invert if the direction is superior
if U(3,1)>0
    U(:,1) = U(:,1)*(-1); %Direction of PC1.
end
PC1_direction = U(:,1);
PC3_direction = U(:,3);

best_view = [1;-1;1;];
if dot(PC3_direction,best_view)<0
    PC3_direction = PC3_direction(:,1).*(-1);
end
U(:,3) = PC3_direction;
PC3_direction = PC3_direction';

PC1_from_origin=[U(1,1)*S(1,1) U(2,1)*S(1,1) U(3,1)*S(1,1)];
PC2_from_origin=[U(1,2)*S(2,2) U(2,2)*S(2,2) U(3,2)*S(2,2)]; 
PC12_ratio=(norm(PC2_from_origin))/(norm(PC1_from_origin)); 


%% Electrodeplacering ift origo 
c = 4; %Shifting factor to extend electrode placements.
PCA_origin=((dot(VCGavg,U(:,3)'))/(sqrt(U(1,3)^2+U(2,3)^2+U(3,3)^2)^2))*U(:,3); %Projection of VCG avg on U to get PCA origin on plane.

P0=[PCA_origin(1) + U(1,1)*S(1,1)*c PCA_origin(2) + U(2,1)*S(1,1)*c PCA_origin(3) + U(3,1)*S(1,1)*c]; %lead som de andre leads tager udgangspunkt i. Multiply by C to shift electrodes outwards to see them better
%Beregn elektrodepunkter fra origo til punkter på planet 
Pseudo_electrodes(1,:)=P0;
theta = zeros(1,35); %Preallocation
for i=1:35  
    theta(i) = 10*i*pi/180;
    Pseudo_electrodes(i+1,:) = P0*cos(theta(i)) +cross(U(:,3),P0)*sin(theta(i))+ U(:,3)'*dot(U(:,3),P0)*(1-cos(theta(i))); %Rodrigues formel 
end


%% Plot data med PCA-origo 
VCG_T_pca=VCG_T-PCA_origin;

%% Electrodes ift. PCA(0,0,0)

for i=1:36
    P_pca(i,:)=Pseudo_electrodes(i,:)-PCA_origin';
end

%% Projection 

%Preallocation:
    projvec = zeros(length(VCG_T_pca),3);
    leadprojvec = zeros(length(P_pca),length(VCG_T_pca),3);
    projlength = zeros(1,length(VCG_T_pca));
    leadprojlength = zeros(length(P_pca),length(VCG_T_pca));

numerationOfElectrodes = 0:35;

for j=1:length(P_pca) %ser kun på 180 grader. Gennemløber 180 graders leads
    lead=P_pca(j,:)'; 
    for i=1:length(VCG_T_pca) %gennemløber length(VCG_T_pca) antal datapunkter
        pointvec=VCG_T_pca(:,i); %vektoren som skal projekteres er det PC-plans-korrigerede punkt. 
        projvec(i,:)=((dot(pointvec,lead))/(sqrt(lead(1)^2+lead(2)^2+lead(3)^2)^2))*lead; %Projection af pointvec på valgte lead.
        leadprojvec(j,i,:)=projvec(i,:); %gemmer den beregnede projekterede vektor (i) i den tilhørende lead (j) 
        
        if dot(projvec(i,:),lead)<0 %Sørger for at gøre modsatrettet projection negativ vha. dot-product
            projlength(i)=-sqrt(projvec(i,1)^2+projvec(i,2)^2+projvec(i,3)^2); %beregning af projektionsvektor-længder. Negativ pga modsatrettet. 
            leadprojlength(j,i)=projlength(i);
        else
            projlength(i)=sqrt(projvec(i,1)^2+projvec(i,2)^2+projvec(i,3)^2); 
            leadprojlength(j,i)=projlength(i);
        end
    end
   
end

    
selectedLeadsAndElectrodes = [1:10,29:36]; %Look at the span from 0-90 degrees and from 280 to 350 degrees

leadprojlength = leadprojlength(selectedLeadsAndElectrodes,:);
Pseudo_electrodes = Pseudo_electrodes(selectedLeadsAndElectrodes,:);
numerationOfElectrodes = numerationOfElectrodes(selectedLeadsAndElectrodes);


end



