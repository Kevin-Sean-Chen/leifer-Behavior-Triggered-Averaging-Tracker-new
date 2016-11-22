function [linear_kernel] = BTA_to_kernel(BTA, BTA_stats, meanLEDPower)
%This function gets the kernel section of the BTA
%   The kernel is defined as bounded by zeros that contain all the significant
%   regions

    linear_kernel = zeros(size(BTA));
    percentile_threshold = 0.99;
    
    for behavior_index = 1:size(BTA,1)
        if isfield(BTA_stats, 'BTA_percentile') && BTA_stats.BTA_percentile(behavior_index) < percentile_threshold
            %BTA not above percentile level, flat kernel
            flat_kernel = false;
        else
            flat_kernel = true;
        end

        if ~flat_kernel
            %mean offset
            linear_kernel(behavior_index, :) = BTA(behavior_index, :) - meanLEDPower;
            %the linear kernel is time reversed BTA
            linear_kernel(behavior_index,:) = fliplr(linear_kernel(behavior_index,:));
        end
    end
end

