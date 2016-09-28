function [LNPStats, meanLEDPower, stdLEDPower] = FitLNP(Tracks,folder_indecies,folders)
%FitLNP takes in tracks and outputs the parameters of the LNP
%   Detailed explanation goes here
    numbins = 10;
    if ~isfield(Tracks, 'Behaviors')
        %does not support tracks without behaviors
        return
    end
    number_of_behaviors = size(Tracks(1).Behaviors,1);

    %get all the LEDVoltages from all experiments
    all_LEDVoltages = cell(1,length(folders));
    for folder_index = 1:length(folders)
        curDir = folders{folder_index};
        % Load Voltages
        fid = fopen([curDir, '\LEDVoltages.txt']);
        all_LEDVoltages{folder_index} = transpose(cell2mat(textscan(fid,'%f','HeaderLines',0,'Delimiter','\t'))); % Read data skipping header
        fclose(fid);
    end
    
    allLEDPower = [Tracks.LEDPower];
%     allLEDPower = [Tracks.LEDVoltages];
    meanLEDPower = mean(allLEDPower);
    stdLEDPower = std(allLEDPower);

    allLEDVoltages = [Tracks.LEDVoltages];
    meanLEDVoltages = mean(allLEDVoltages);

    
    %calculate the BTA and linear kernel
    Behaviors = {Tracks(:).Behaviors};
    LEDPowers = {Tracks(:).LEDPower};
    [BTA, trigger_count] = BehaviorTriggeredAverage(Behaviors, LEDPowers);
    clear Behaviors LEDPowers

%     %debug load BTA from previous file
%     load('C:\Users\mochil\Dropbox\LeiferShaevitz\presentations\high res mec-4\symmetric\16_09_20_embedding_ret_LNPFit.mat')
%     BTA = vertcat(LNPStats(:).BTA);
%     trigger_count = vertcat(LNPStats(:).trigger_count);

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
        
%         if behavior_index == 8
%            a =1; 
%         end
        
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
            
            %calculate the filtered LEDVoltages for all experiments
            all_filtered_LEDVoltages = cell(1,length(folders));
            for folder_index = 1:length(folders)
                %convolve the linear kernels with the input signal of LED voltages
                all_filtered_LEDVoltages{folder_index} = conv(all_LEDVoltages{folder_index}-meanLEDVoltages, linear_kernel(behavior_index,:), 'same');
            end
            
            for track_index = 1:length(Tracks)
                filtered_signal = all_filtered_LEDVoltages{folder_indecies(track_index)}(Tracks(track_index).Frames);
                filtered_signal = filtered_signal .* Tracks(track_index).LEDPower ./ Tracks(track_index).LEDVoltages;
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
            disp(num2str(behavior_index));
        end
        

        
    
    %     figure
    %     hold on
    %     plot(non_linearity_fit,bin_centers,non_linearity)
    %     hold off
    %     xlabel('filtered signal (a.u.)') % x-axis label
    %     ylabel('reversal rate (behaviors/worm/min)') % y-axis label
    end
end

