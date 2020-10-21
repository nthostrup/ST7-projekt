function [uniqueECGs] = loadUniqueECG(directorypath)
%loadUniqueECG Summary of this function goes here
%  Inputs:
%   dir: Directory of data to load
%  Outputs
%   UniqueECGs: Array with serial ECG for each person and datetime stamp

xmlfiles = dir(fullfile(directorypath,'*xml'));
personIDArray = char(zeros(length(xmlfiles),10));

for i=1:length(xmlfiles)
    XML(i) = XMLECGParser(xmlfiles(i).name);
    personIDArray(i,:) = XML(i).TestInfo.PatientID;  
end


uniqueIDs = unique(personIDArray,'rows');

uniqueECGs = struct('ID','','ECGs',0,'dateTimeAcq','','fileName','','POn',0,'POff',0);
for j=1:size(uniqueIDs,1)
    ID = uniqueIDs(j,:);
    uniqueECGs(j).ID=ID;
    k = 1;
    for i=1:length(XML)
        if(XML(i).TestInfo.PatientID == ID)
            uniqueECGs(j).ECGs(k,1:600,1:12) = XML(i).MedianECG.ECG12Leads;
            uniqueECGs(j).dateTimeAcq(k,:) = XML(i).TestInfo.AcqDateTime;
            uniqueECGs(j).fileName(k,:) = XML(i).TestInfo.Filename;
            uniqueECGs(j).POn(k) = XML(i).TestInfo.POnset;
            uniqueECGs(j).POff(k) = XML(i).TestInfo.POffset;
            k = k+1;
        end
    end
end

end

