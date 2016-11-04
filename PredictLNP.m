function [predicted_behavior_rate] = PredictLNP(LEDVoltages, linear_kernel, exp_fit_a, exp_fit_b, bin_size)
%Predicts the behavioral rate based on LNP model parameters
%   Detailed explanation goes here

    fps = 14;
    if nargin < 5
        %no bin size specified
        bin_size = 1;
    end
    
    filtered_signal = conv(LEDVoltages, linear_kernel, 'same');
    predicted_behavior_rate = exp_fit_a*exp(exp_fit_b*filtered_signal);
    predicted_behavior_rate = reshape(predicted_behavior_rate, [], bin_size);
    predicted_behavior_rate = mean(predicted_behavior_rate, 2)' .* fps * 60;
end

