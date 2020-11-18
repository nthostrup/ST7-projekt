function [detectionOutput] = konventionalDetectionMethod(konv_biphasic_p_wave,  konv_p_iab)


for i=1:length(konv_biphasic_p_wave)
    if konv_biphasic_p_wave(i,1) == 1 && konv_biphasic_p_wave(i,2) == 1 && konv_biphasic_p_wave(i,3) == 1 && konv_p_iab(i) == 1
        detectionOutput(i) = 1;
    else
        detectionOutput(i) = 0;
    end
    
end