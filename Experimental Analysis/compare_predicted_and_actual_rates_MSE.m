function MSE = compare_predicted_and_actual_rates_MSE(predicted_rates, observed_rates)
%computes the MSE to see how predictive our model is against the actual
%observed rates
    fps = 14;
    observed_rates = double(observed_rates)*fps*60; % put it in transitions/min
    MSE = mean((predicted_rates-observed_rates).^2);
end