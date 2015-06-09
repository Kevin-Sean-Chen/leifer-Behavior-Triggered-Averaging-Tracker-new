function [predicted_reversal_rate] = PredictLNP(LEDVoltages, linear_kernel, exp_fit_a, exp_fit_b, bin_size)
%Predicts the behavioral rate based on LNP model parameters
%   Detailed explanation goes here

    fps = 14;
    if nargin < 5
        %no bin size specified
        bin_size = 1;
    end
    
    filtered_signal = conv(LEDVoltages, linear_kernel);
    filtered_signal = filtered_signal(1:length(LEDVoltages)); %cut off the tail
    predicted_reversal_rate = exp_fit_a*exp(exp_fit_b*filtered_signal);
    predicted_reversal_rate = reshape(predicted_reversal_rate, [], bin_size);
    predicted_reversal_rate = mean(predicted_reversal_rate, 2)' .* fps * 60;
end

