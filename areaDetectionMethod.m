function [detectionOutput] = areaDetectionMethod(sum_p_inv_loop, sum_p_loop, threshold)
% % detectionOutput er en variabel, som med 1 eller 0 indikerer om metoden har fundet den givne karakteristika.
% Sum_p_inv_loop: Array med værdi for areal for P’ kurve for P0.
% sum_p_loop: Array med værdi for arealet af positive kurve for P0.
% Threshold: grænseværdi for det minimumsareal for detektion. (min 0, max 10000)


for i=1:length(sum_p_inv_loop)
    if sum_p_inv_loop(i,1) < 0
    sum_p_inv_loop(i,1) = sum_p_inv_loop(i,1)*-1;         %%Sørger for at arealet er positivt
    end 
    if sum_p_inv_loop(i,1) >= threshold && sum_p_loop(i,1) >= 160    % Den skal have to bølger før at vi kan sige at den er bifasisk       
    detectionOutput(i) = 1;
    else
    detectionOutput(i) = 0;
    end
end

end