function [intersectedData] = intersectXMLsOnIDs(XML1_AFdata,XML2_LastNormaldata)
%intersectXMLsOnIDs intersect two XML's by pairing their respective patient
%ID's. Returns unique patients and the difference between AF and last
%normal 
%   
%XML1 AF data
%XML2 Last normal ECG data

IDxml1_AFdata = char(zeros(length(XML1_AFdata),10));
for i=1:length(XML1_AFdata)
    IDxml1_AFdata(i,:) = XML1_AFdata(i).TestInfo.PatientID;  
end

IDxml2_LastNormal = char(zeros(length(XML2_LastNormaldata),10));
for i=1:length(XML2_LastNormaldata)
    IDxml2_LastNormal(i,:) = XML2_LastNormaldata(i).TestInfo.PatientID;  
end

%C is patientID, IAF is index in AFdata of the match, ILastNormal is index
%in Last normal data of match.
[C, IAF, ILastNormal] = intersect(IDxml1_AFdata, IDxml2_LastNormal,'rows');

intersectedData = struct('ID','','timeOfAF','','timeLastNormal','','IndexLastNormal',0,'duration',0);


for i = 1:length(C)
    intersectedData(i).ID = C(i,:); %ID of patient
    intersectedData(i).timeOfAF(1,:) = XML1_AFdata(IAF(i)).TestInfo.AcqDateTime; %Date of AF;
    intersectedData(i).timeLastNormal(1,:) = XML2_LastNormaldata(ILastNormal(i)).TestInfo.AcqDateTime; %Date of Last normal ECG.
    intersectedData(i).IndexLastNormal = ILastNormal(i);
    intersectedData(i).duration = days(datetime(intersectedData(i).timeOfAF,'InputFormat','yyyy-MM-dd HH:mm:ss')-datetime(intersectedData(i).timeLastNormal,'InputFormat','yyyy-MM-dd HH:mm:ss'));
end


end

