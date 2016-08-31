function [LNPStats, meanLEDPower, stdLEDPower] = FitLNP(Tracks)
%FitLNP takes in tracks and outputs the parameters of the LNP
%   Detailed explanation goes here
    fps = 14;
    numbins = 10;
    number_of_behaviors = size(Tracks(1).Behaviors,1);

    
    allLEDPower = [Tracks.LEDPower];
%     allLEDPower = [Tracks.LEDVoltages];
    meanLEDPower = mean(allLEDPower);
    stdLEDPower = std(allLEDPower);
    [BTA, trigger_count] = BehaviorTriggeredAverage([], Tracks);
    linear_kernel = BTA_to_kernel(BTA, trigger_count, meanLEDPower, stdLEDPower);

    %smooth the linear_kernel? Approximate by gaussian and exponential?
    
    LNPStats(number_of_behaviors).BTA = [];    
    LNPStats(number_of_behaviors).linear_kernel = [];
    LNPStats(number_of_behaviors).trigger_count = [];
    
    LNPStats(number_of_behaviors).non_linearity_fit = [];
    LNPStats(number_of_behaviors).bin_edges = [];
    LNPStats(number_of_behaviors).filtered_signal_histogram = [];
    LNPStats(number_of_behaviors).filtered_signal_given_reversal_histogram = [];
  
    all_behaviors = horzcat(Tracks.Behaviors);
    
    for behavior_index = 1:number_of_behaviors
        LNPStats(behavior_index).BTA = BTA(behavior_index,:);    
        LNPStats(behavior_index).linear_kernel = linear_kernel(behavior_index,:);
        LNPStats(behavior_index).trigger_count = trigger_count(behavior_index,:);
        
        if isempty(nonzeros(linear_kernel(behavior_index,:)))
            %special case: flat kernel
            bin_centers = 0:numbins-1;
            non_linearity = zeros(1,numbins);
            LNPStats(behavior_index).bin_edges = bin_centers;
            LNPStats(behavior_index).filtered_signal_histogram = [];
            LNPStats(behavior_index).filtered_signal_given_reversal_histogram = [];
            LNPStats(behavior_index).non_linearity_fit = fit(bin_centers',non_linearity','exp1');
            LNPStats(behavior_index).non_linearity = non_linearity;
            LNPStats(behavior_index).bin_centers = bin_centers;
            LNPStats(behavior_index).errors = zeros(1,numbins);
        else
            all_filtered_signal = [];
            for track_index = 1:length(Tracks)
                %convolve the linear kernels with the input signal of LED voltages
                filtered_signal = conv(Tracks(track_index).LEDPower, linear_kernel(behavior_index,:), 'same');
                filtered_signal = filtered_signal(1:length(Tracks(track_index).LEDPower)); %cut off the tail
                all_filtered_signal = [all_filtered_signal, filtered_signal];
            end

            %make histogram of filtered signal
            current_bin_edges = linspace(min(all_filtered_signal), max(all_filtered_signal), numbins+1);
            current_bin_edges(end) = current_bin_edges(end) + 1;
            LNPStats(behavior_index).bin_edges = current_bin_edges;

            [current_filtered_signal_histogram, bin_indecies] = histc(all_filtered_signal, current_bin_edges);
            current_filtered_signal_histogram = current_filtered_signal_histogram(1:end-1);
            LNPStats(behavior_index).filtered_signal_histogram = current_filtered_signal_histogram;

            %get histogram of filtered_signal given a reversal
            current_filtered_signal_given_behavior = all_filtered_signal(all_behaviors(behavior_index,:));
            current_filtered_signal_given_behavior_histogram = histc(current_filtered_signal_given_behavior, current_bin_edges);
            current_filtered_signal_given_behavior_histogram = current_filtered_signal_given_behavior_histogram(1:end-1);
            LNPStats(behavior_index).filtered_signal_given_reversal_histogram = current_filtered_signal_given_behavior_histogram;
        %     figure
        %     bar(bin_edges(1:end-1), filtered_signal_given_reversal_histogram');
        %     set(gca,'XTick',round(bin_edges*100)/100)
            [LNPStats(behavior_index).non_linearity_fit, LNPStats(behavior_index).non_linearity, ...
                LNPStats(behavior_index).bin_centers, LNPStats(behavior_index).errors] = ...
                fit_nonlinearity(current_filtered_signal_given_behavior_histogram, current_filtered_signal_histogram, current_bin_edges);
            
        end
        

        
    
    %     figure
    %     hold on
    %     plot(non_linearity_fit,bin_centers,non_linearity)
    %     hold off
    %     xlabel('filtered signal (a.u.)') % x-axis label
    %     ylabel('reversal rate (behaviors/worm/min)') % y-axis label
    end
end

