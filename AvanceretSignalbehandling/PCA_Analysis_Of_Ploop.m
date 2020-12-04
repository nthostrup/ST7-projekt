%Arrange axis correct as by convention
%subject=30;
for subject=1:length(VCG_T)
    VCG_ploop=squeeze(VCG_T(subject,On(subject):Off(subject),:));
    VCG_ploop=[VCG_ploop(:,1) VCG_ploop(:,3) -VCG_ploop(:,2)]; % om-arranger så retninger passer
    
    %plot3(VCG_ploop(:,1),VCG_ploop(:,2),VCG_ploop(:,3))
    %axis square
    %grid on
    
    % PCA
    VCG_ploop=VCG_ploop';
    nPoints = length(VCG_ploop);
    
    VCGavg = mean(VCG_ploop,2);               % Compute mean of rows
    B = VCG_ploop - VCGavg*ones(1,nPoints);   % Mean-subtracted Data
    [U,S,V] = svd(B,'econ'); % PCA via SVD. U describes the rotation of the points and S describes the singular value, standard deviation
    
    % calc eigen
    eigen(subject,:)=(diag(S).^2)';
    
    total_eigen=sum(eigen(subject,:));
    
    for i=1:3
        pct(subject,i)=eigen(subject,i)/total_eigen;
    end
    
    VCG_ploop=[];%clear for next subject 
end
%%
%stem(1,pct(1)); hold on
%stem(2,pct(2));
%stem(3,pct(3));

eigen_mean=mean(pct,1);
eigen_std=std(pct,1);

plot([eigen_mean(1) eigen_mean(2) eigen_mean(3)]); hold on 
set(gca,'xTick',(1:3))
xticklabels({'PC1','PC2','PC3'})
title('Scree plot: Mean eigenvalue ratios');
grid on
xlabel('N')
ylabel('Eigenvalues')
