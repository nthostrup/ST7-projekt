%% Find tid mellem last normal og first AF ECG gruppen
%load('AF_first_ECG.mat')
%load('AF_last_normal_ECG_GEpoffset_workspace.mat')

%% Læg XML sammen
%bothFiles = [AF_first_ECG AF_last_normal_ECG_XML_loaded];


%[uniqueECGs] = loadUniqueECG_from_XML(bothFiles);
%load('uniqueECGs.mat')


%% Fjern data med kun én tid og beregn duration i dage
data = uniqueECGs;

i=1;

 while i<=length(data)      %% 1051 fjernes da der kun er ét sample
     s = size(data(i).ECGs);
     if s(1) < 2
        data(i) = [];
     else
        d = data(i).dateTimeAcq;

        t = datetime(d,'InputFormat','yyyy-MM-dd HH:mm:ss');
    
        difference = t(1)-t(2);
        duration_last_norm_first_AF(i) = days(difference);
        
        i = i+1;
    end
end

     %% Detection på AF gruppen
% Konventionel  - få integreret p>120 ms
konv_biphasic_p_wave  

% Biphasic P0

% Biphasic +/- 50 OR

% Biphasic +/- 10 AND

% P0' area > 2 mikroV

% P0' amplitude > 10 mikroV

%% Lav AF matrice

event = ones(length(xx),1);
%duration
%


%%  No AF ever gruppen
% load('No_AF_ever_variables_all_variables.mat')
% XML = No_AF_ever_XML_loaded;

count = 0;
i = 1;
    while i<=length(XML)
        if isnan(XML(i).TestInfo.AcqDateTime)
            XML(i)=[];
            count = count +1;
        else
            i = i+1;%Only increase i when no set is removed.
        end
    end
    disp("Removed " + count + " datasets");

%% beregn duration i dage

enddate = datetime(2015,12,31,23,59,59);
    
    
 for i = 1:length(XML)
   date_AF_first_ECG{i} = XML(i).TestInfo.AcqDateTime;
   t = datetime(date_AF_first_ECG(i),'InputFormat','yyyy-MM-dd HH:mm:ss');
   diff = enddate-t;
   duration_no_af_ever(i) = days(diff);
 end

 %% Detection på No AF Ever gruppen
% Konventionel  - få integreret p>120 ms

% Biphasic P0

% Biphasic +/- 50 OR

% Biphasic +/- 10 AND

% P0' area > 2 mikroV

% P0' amplitude > 10 mikroV
 







