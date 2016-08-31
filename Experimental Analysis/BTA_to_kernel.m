function [linear_kernel] = BTA_to_kernel(BTA, trigger_count, meanLEDPower, stdLEDPower)
%This function gets the kernel section of the BTA
%   The kernel is defined as bounded by zeros that contain all the significant
%   regions

    fps = 14;
    duration_threshold = 1*fps;
    significance = 3; %how many times the mean of the angular error?
    linear_kernel = zeros(size(BTA));
    
    for behavior_index = 1:size(BTA,1)
        significance_threshold = significance*stdLEDPower*sqrt(2/trigger_count(behavior_index));

        flat_kernel = false;
        
        behavior_BTA = BTA(behavior_index, :);
        %mean offset
        mean_subtracted_BTA = behavior_BTA - meanLEDPower;
        %find where the BTA is above the threshold
        abs_mean_subtracted = abs(mean_subtracted_BTA);
        significant_indecies = find(abs_mean_subtracted > significance_threshold);

        if isempty(significant_indecies)
            %nothing is above signficance, flat kernel
            flat_kernel = true;
        else
            %something is above significance, find where it starts and ends

            %find the zeros of the BTA
            BTA_sign = sign(mean_subtracted_BTA);
            flag_cross = [(diff(BTA_sign)==2), false] | [(diff(BTA_sign)==-2), false] | (BTA_sign==0);
            zero_indecies = find(flag_cross);

            %the zeros at which begin and end the significance stretch defines
            %the borders of the linear kernel

            %find the largest zero smaller than when the BTA becomes
            %significant, confined by BTA indecies
            kernel_start = max([zero_indecies(zero_indecies < min(significant_indecies)), 1]);
            kernel_end = min([zero_indecies(zero_indecies > max(significant_indecies)), length(BTA)]);

            BTA_indecies = kernel_start:kernel_end;
            if length(BTA_indecies) < duration_threshold
                %significance is smaller than the duration threshold, flat
                %kernel
                flat_kernel = true;
            end
        end

        if ~flat_kernel
            linear_kernel(behavior_index,BTA_indecies) = mean_subtracted_BTA(BTA_indecies);
        end
    end
end

