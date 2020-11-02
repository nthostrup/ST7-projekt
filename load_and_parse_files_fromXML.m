clear all;
close all; 

datafiledir='S:\IAB-data\No-AF-ever';
xmlfiles=dir(fullfile(datafiledir,'*xml'));

%% Define dataset, transformation type and interval
tic
for i = 1:1:length(xmlfiles)
%Angiv den konkrete fil der skal køres i scriptet ved index af xmlfiler
No_AF_ever_XML_loaded(i) = XMLECGParser(xmlfiles(i).name);  
end
toc