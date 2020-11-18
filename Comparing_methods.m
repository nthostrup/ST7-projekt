close all

%% Load data

load('aIAB_biphasic_p_wave.mat');
load('aIAB_konv_biphasic_p_wave.mat')
load('aIAB_sum_p_inv_loop')

N=length(biphasic_p_wave);
M = 100;


%% Konventionelle leads 3 bifasiske = A-IAB = 1

for i=1:length(konv_biphasic_p_wave)
    if konv_biphasic_p_wave(i,1) == 1 && konv_biphasic_p_wave(i,2) == 1 && konv_biphasic_p_wave(i,3) == 1 && konv_p_iab(i) == 1
    S(i) = 1;
    else
    S(i) = 0;
    end
end
konv_bipha = nonzeros(S);
konv_bipha_pc = (length(konv_bipha)/N)*100;


%% Bifasisk P0 = 1

P0_biphasic = nonzeros(biphasic_p_wave(:,1));
P0_bipha_pc = (length(P0_biphasic)/N)*100;

%% Bifasisk i P0/P1/P35 = 1  (OR)

for i=1:length(biphasic_p_wave)
    if biphasic_p_wave(i,1) == 1 || biphasic_p_wave(i,2) == 1 || biphasic_p_wave(i,18) == 1
    T(i) = 1;
    else
    T(i) = 0;
    end
end
degree_10_OR_bipha = nonzeros(T);
degree_10_OR_bipha_pc = (length(degree_10_OR_bipha)/N)*100;

%% Bifasisk i P0+P1+P35 = 1  (AND)

for i=1:length(biphasic_p_wave)
    if biphasic_p_wave(i,1) == 1 && biphasic_p_wave(i,2) == 1 && biphasic_p_wave(i,18) == 1
    U(i) = 1;
    else
    U(i) = 0;
    end
end
degree_10_AND_bipha = nonzeros(U);
degree_10_AND_bipha_pc = (length(degree_10_AND_bipha)/N)*100;

%% Bifasisk i P0+P1+P2+P34+P35 = 1  (AND)

for i=1:length(biphasic_p_wave)
    if biphasic_p_wave(i,1) == 1 && biphasic_p_wave(i,2) && biphasic_p_wave(i,3) == 1 && biphasic_p_wave(i,17) == 1 && biphasic_p_wave(i,18) == 1
    V(i) = 1;
    else
    V(i) = 0;
    end
end
degree_20_AND_bipha = nonzeros(V);
degree_20_AND_bipha_pc = (length(degree_20_AND_bipha)/N)*100;

%% Areal = ?? = 1

for i=1:length(sum_p_inv_loop)
    if sum_p_inv_loop(i,1) < -500
    W(i) = 1;
    else
    W(i) = 0;
    end
end

area_p0_biphasic = nonzeros(W);
area_p0_biphasic_pc = (length(area_p0_biphasic)/N)*100;


%% Plot

Xlabels = {'Total number' ; 'Conventional method' ;'Biphasic P-wave in P0';'Biphasic P-wave in P0, P1 or P35';'Biphasic P-wave in P0, P1 AND P35';'Biphasic P-wave in P0, P1, P2, P34 AND P35';'Area < -500'};


figure(1)
stem(0,M,'LineWidth',3)
hold on
stem(1,konv_bipha_pc,'LineWidth',3)
stem(2,P0_bipha_pc,'LineWidth',3)
stem(3,degree_10_OR_bipha_pc,'LineWidth',3)
stem(4,degree_10_AND_bipha_pc,'LineWidth',3)
stem(5,degree_20_AND_bipha_pc,'LineWidth',3)
stem(6,area_p0_biphasic_pc,'LineWidth',3)

% Navngivning af labels og ticks
axis([0 6.5 0 110])
grid on
xlabel('Method','FontSize', 14)
ylabel('% of population having A-IAB','FontSize', 14)

xTicks=0:1:6;          %Antal ticks og step size
set(gca,'xTick',xTicks);   %Sætter ticks hvert x'ne længde

for i=1:7
names(i,:)= Xlabels(i);
end
set(gca, 'xTickLabels', names);
xtickangle(35)

str = 8;
text(0, M +5, num2str(M), 'HorizontalAlignment', 'center','rotation',90);
text(1, konv_bipha_pc + str, num2str(konv_bipha_pc), 'HorizontalAlignment', 'center','rotation',90);
text(2, P0_bipha_pc + 6, num2str(P0_bipha_pc), 'HorizontalAlignment', 'center','rotation',90);
text(3, degree_10_OR_bipha_pc + str, num2str(degree_10_OR_bipha_pc), 'HorizontalAlignment', 'center','rotation',90);
text(4, degree_10_AND_bipha_pc + str, num2str(degree_10_AND_bipha_pc), 'HorizontalAlignment', 'center','rotation',90);
text(5, degree_20_AND_bipha_pc + str, num2str(degree_20_AND_bipha_pc), 'HorizontalAlignment', 'center','rotation',90);
text(6, area_p0_biphasic_pc + str, num2str(area_p0_biphasic_pc), 'HorizontalAlignment', 'center','rotation',90);

