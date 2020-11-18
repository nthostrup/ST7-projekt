function [uniqueECGs] = loadUniqueECG_from_XML(XML_in)
%loadUniqueECG Summary of this function goes here
%  Inputs:
%   dir: Directory of data to load
%  Outputs
%   UniqueECGs: Array with serial ECG for each person and datetime stamp

personIDArray = char(zeros(length(XML_in),10));
XML = XML_in;

for i=1:length(XML)
    personIDArray(i,:) = XML(i).TestInfo.PatientID;  
end


uniqueIDs = unique(personIDArray,'rows');

uniqueECGs = struct('ID','','ECGs',0,'dateTimeAcq','','fileName','','POn',0,'POff',0);
for j=1:size(uniqueIDs,1)
    ID = uniqueIDs(j,:);
    uniqueECGs(j).ID=ID;
    k = 1;%Counter for a specific person.
    for i=1:length(XML)
        if(XML(i).TestInfo.PatientID == ID)
            uniqueECGs(j).ECGs(k,1:600,1:12) = XML(i).MedianECG.ECG12Leads; %All 12 lead ecgs.
            uniqueECGs(j).dateTimeAcq(k,:) = XML(i).TestInfo.AcqDateTime; %Date of aquisition of ekg
            uniqueECGs(j).fileName(k,:) = XML(i).TestInfo.Filename; %filename on the file used
            uniqueECGs(j).POn(k) = XML(i).TestInfo.POnset; %p-onset
            uniqueECGs(j).POff(k) = XML(i).TestInfo.POffset; %p-offset
            k = k+1;
        end
    end
end

end

