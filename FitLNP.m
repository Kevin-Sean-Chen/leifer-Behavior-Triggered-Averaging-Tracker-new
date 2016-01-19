function [linear_kernel, non_linearity_fit, BTA, meanLEDVoltage, pirouetteCount, bin_edges, filtered_signal_histogram, filtered_signal_given_reversal_histogram] = FitLNP(Tracks)
%FitLNP takes in tracks and outputs the parameters of the LNP
%   Detailed explanation goes here

    fps = 14;
    BTA_seconds_before = 10;
    BTA_seconds_after = 1;
    kernel_seconds_before = 6;
    numbins = 10;
    
    meanLEDVoltage = mean([Tracks.LEDVoltages]);
    [BTA, pirouetteCount] = BehaviorTriggeredAverage([], Tracks);
    linear_kernel = BTA((BTA_seconds_before-kernel_seconds_before)*fps+1:length(BTA)-(BTA_seconds_after*fps)); %will have size fps*kernel_seconds_before+1 because frame at 0 is also counted
    linear_kernel = fliplr(linear_kernel - meanLEDVoltage); %time in BTA is reversed in linear kernel
% 
%     %plot BTA
%     figure
%     hold on
%     shadedErrorBar(-BTA_seconds_before:1/fps:BTA_seconds_after, BTA, 2/sqrt(pirouetteCount)*ones(1,length(BTA)));
%     meanLEDVoltageY = zeros(1,length(BTA));
%     meanLEDVoltageY(:) = meanLEDVoltage;
%     plot(-BTA_seconds_before:1/fps:BTA_seconds_after, meanLEDVoltageY, 'r')
%     hold off
%     xlabel(strcat('second (', num2str(pirouetteCount), ' behaviors analyzed)')) % x-axis label
%     ylabel('voltage') % y-axis label
%     axis([-10 2 0.64 0.84])

    %smooth the linear_kernel? Approximate by gaussian and exponential?
        
    for track_index = 1:length(Tracks)
        %convolve the linear kernels with the input signal of LED voltages
        filtered_signal = conv(Tracks(track_index).LEDVoltages, linear_kernel);
        Tracks(track_index).FilteredSignal = filtered_signal(1:length(Tracks(track_index).LEDVoltages)); %cut off the tail
    end
    
    
    %make histogram of filtered signal
    all_filtered_signal = [Tracks.FilteredSignal];
    bin_edges = linspace(min(all_filtered_signal), max(all_filtered_signal), numbins+1);
    bin_edges(end) = bin_edges(end) + 1;
    [filtered_signal_histogram, bin_indecies] = histc(all_filtered_signal, bin_edges);
    filtered_signal_histogram = filtered_signal_histogram(1:end-1);
    
%     figure
%     bar(bin_edges(1:end-1), filtered_signal_histogram);
%     set(gca,'XTick',round(bin_edges*100)/100)

%     % Get binary array of when certain behaviors start
%     for track_index = 1:length(Tracks)
%         pirouettes = Tracks(track_index).Pirouettes;
%         behaviors = zeros(1, length(Tracks(track_index).LEDVoltages)); %a binary array of when behaviors occur
%         for pirouette_index = 1:size(pirouettes,1)
%             pirouetteStart = pirouettes(pirouette_index,1);
%             behaviors(pirouetteStart) = 1;
%         end
%         Tracks(track_index).Behaviors = logical(behaviors);
%     end
        
    %get histogram of filtered_signal given a reversal
    filtered_signal_given_reversal = all_filtered_signal(logical([Tracks.Behaviors]));
    filtered_signal_given_reversal_histogram = histc(filtered_signal_given_reversal, bin_edges);
    filtered_signal_given_reversal_histogram = filtered_signal_given_reversal_histogram(1:end-1);
    
%     figure
%     bar(bin_edges(1:end-1), filtered_signal_given_reversal_histogram');
%     set(gca,'XTick',round(bin_edges*100)/100)

    non_linearity = filtered_signal_given_reversal_histogram ./ filtered_signal_histogram * 60 *fps;
    bin_centers = bin_edges(1:end-1)+(diff(bin_edges(1:2)/2));
    non_linearity_fit = fit(bin_centers',non_linearity','exp1');

    
%     figure
%     hold on
%     plot(non_linearity_fit,bin_centers,non_linearity)
%     hold off
%     xlabel('filtered signal (a.u.)') % x-axis label
%     ylabel('reversal rate (behaviors/worm/min)') % y-axis label
end

