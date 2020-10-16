function [leadprojlength, Pseudo_electrodes, numerationOfElectrodes] = PseudoLeadsCalc(VCG_in)

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

%Define principal component (point)
PC1=[VCGavg(1)+U(1,1)*S(1,1) VCGavg(2)+U(2,1)*S(1,1) VCGavg(3)+U(3,1)*S(1,1)]; %PC1
PC2=[VCGavg(1)+U(1,2)*S(2,2) VCGavg(2)+U(2,2)*S(2,2) VCGavg(3)+U(3,2)*S(2,2)]; %PC2
PC3=[VCGavg(1)+U(1,3)*S(3,3) VCGavg(2)+U(2,3)*S(3,3) VCGavg(3)+U(3,3)*S(3,3)]; %PC3

%% Create plane 
% Normalvektoren til planet er vores 3. principalkomponents retning (U). 
syms x y z
planeeq=dot(U(:,3),[x,y,z]-VCGavg');
Z=solve(planeeq==0,z);

%% Electrodeplacering ift origo 
c = 5; %Shifting factor to extend electrode placements.
PCA_origin=((dot(VCGavg,U(:,3)'))/(sqrt(U(1,3)^2+U(2,3)^2+U(3,3)^2)^2))*U(:,3);
%P1=[VCGavg(1)+U(1,1)*S(1,1) VCGavg(2)+U(2,1)*S(1,1) VCGavg(3)+U(3,1)*S(1,1)]; %lead som de andre leads tager udgangspunkt i 

P1=[PCA_origin(1)+U(1,1)*S(1,1) PCA_origin(2)+U(2,1)*S(1,1) PCA_origin(3)+U(3,1)*S(1,1)]; %lead som de andre leads tager udgangspunkt i 
P1 = P1 .* c;
%Beregn elektrodepunkter fra origo til punkter på planet 
Pseudo_electrodes(1,:)=P1;
for i=1:35  
    theta(i) = 10*i*pi/180;
    Pseudo_electrodes(i+1,:) = P1*cos(theta(i)) +cross(U(:,3),P1)*sin(theta(i))+ U(:,3)'*dot(U(:,3),P1)*(1-cos(theta(i))); %Rodrigues formel 
end

%% Beregner pseudoleads ift PCA(0,0,0)
pcaorig=sum(Pseudo_electrodes,1)/length(Pseudo_electrodes); %bestemmer punkt på plan som er vinkelret til origo

%% Plot data med PCA-origo 
VCG_T_pca=VCG_T-pcaorig';

%% Electrodes ift. PCA(0,0,0)

for i=1:36
    P_pca(i,:)=Pseudo_electrodes(i,:)-pcaorig;
end

%% Projection 
% numerationOfElectrodes = zeros(1,18);
% for i=1:10
%     numerationOfElectrodes(i) = 37-i;
%     inf_p_leads1(i,:) = P_pca(i,:);
% end
% for j=29:36
%     i = i+1;
%     numerationOfElectrodes(i) = 37-j;
%     inf_p_leads2(j,:) = P_pca(j,:);
% end
% 
% inf_p_leads = [inf_p_leads1(1:10,:);inf_p_leads2(29:36,:)];
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



