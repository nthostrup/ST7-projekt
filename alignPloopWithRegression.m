function [pLoopAligned] = alignPloopWithRegression(pLoop)
%Removeregression Summary of this function goes here
%   Detailed explanation goes here
coefficients = polyfit([1, length(pLoop)], [pLoop(1), pLoop(end)], 1);  %funktion polyfit(x,y,degree) finder koeficienter for ligning mellem 2 punkter. 
% x-koordinaterne er p_onset og p_offset, y er ekg'et til x'erne, og antal
% frihedsgrader er 1 da det er imellem 2 punkter. 
a = coefficients (1);
b = coefficients (2);

% Fratrækker overstående funktion fra det oprindelindelige p-loop.
% Således er P_onset = 0 og P_offset = 0. 
pLoopAligned = pLoop;             %P_ecg_aligned er P-loopet hvor regressionen er fratrukket
for i=1:1:length(pLoop)
    pLoopAligned(i) = pLoopAligned(i)-(a*i+b); %her fratrækkes regressionen for alle punkter i p-loopet.   
end
end

