function [ score ] = compare_predicted_and_actual_rates(predicted_rates, observed_rates)
%computes a metric to see how predictive our model is against the actual
%observed rates
    number_of_bins = 10;
    fps = 14;
%     bin_edges = linspace(min(predicted_rates),max(predicted_rates),number_of_bins+1); %equally spaced bins
    bin_edges = quantile(predicted_rates, 0:1/number_of_bins:1); %bins have equal counts
    bin_centers = bin_edges(1:end-1) + diff(bin_edges)./2;
    
    [~,bin_categorizations] = histc(predicted_rates,bin_edges);
    
    observed_rates_for_predicted_rate = zeros(1,number_of_bins);
%     observed_errors = zeros(1,number_of_bins);
    for bin_number = 1:number_of_bins
        observed_events_for_predicted_rate = observed_rates(bin_categorizations == bin_number);
        observed_rates_for_predicted_rate(bin_number) = sum(observed_events_for_predicted_rate)/length(observed_events_for_predicted_rate)*fps*60;
    end
    
    score = sqrt(mean((observed_rates_for_predicted_rate-bin_centers).^2)); %RMSD in transitions/min
    
%     % plot the correlation
%     figure
%     hold on
%     plot(bin_centers,observed_rates_for_predicted_rate)
%     plot([0,1],[0,1])
%     xlabel('predicted rate (transitions/min)')
%     ylabel('actual rate (transitions/min)')
end

