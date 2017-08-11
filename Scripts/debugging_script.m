    for behavior_index = 1:number_of_behaviors
        LNPStats(behavior_index).BTA = BTA(behavior_index,:);    
        LNPStats(behavior_index).BTA_RMSD = BTA_RMSD(behavior_index,:);    
        LNPStats(behavior_index).linear_kernel = linear_kernel(behavior_index,:);
        LNPStats(behavior_index).trigger_count = trigger_count(behavior_index,:);
        
        if isempty(BTA_stats)
            LNPStats(behavior_index).BTA_norm = [];
            LNPStats(behavior_index).shuffle_norms = [];
            LNPStats(behavior_index).BTA_percentile = [];

        else
            LNPStats(behavior_index).BTA_norm = BTA_stats.BTA_norm(behavior_index);
            LNPStats(behavior_index).shuffle_norms = BTA_stats.shuffle_norms(behavior_index,:);
            LNPStats(behavior_index).BTA_percentile = BTA_stats.BTA_percentile(behavior_index);
        end
        
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
           
            %calculate the filtered LEDVoltages for all experiments
            all_filtered_LEDVoltages = cell(1,length(folders));
            for folder_index = 1:length(folders)
                %convolve the linear kernels with the input signal of LED voltages
%                 all_filtered_LEDVoltages{folder_index} = conv(all_LEDVoltages{folder_index}-meanLEDVoltages{folder_index}, linear_kernel(behavior_index,:), 'same');
                all_filtered_LEDVoltages{folder_index} = padded_conv(all_LEDVoltages{folder_index}-meanLEDVoltages{folder_index}, linear_kernel(behavior_index,:));
            end
            
            %get all the filtered signals concatenated together
            all_filtered_signal = zeros(1, length(allLEDPower));
            current_frame_index = 1;
            for track_index = 1:length(Tracks)
                current_LEDVoltages2Power = Tracks(track_index).LEDVoltage2Power;
                filtered_signal = current_LEDVoltages2Power .* all_filtered_LEDVoltages{folder_indecies(track_index)}(Tracks(track_index).Frames);
                all_filtered_signal(current_frame_index:current_frame_index+length(Tracks(track_index).Frames)-1) = filtered_signal;
                current_frame_index = current_frame_index+length(Tracks(track_index).Frames);
            end

            %make histogram of filtered signal
            current_bin_edges = linspace(min(all_filtered_signal), max(all_filtered_signal), numbins+1);
            current_bin_edges(end) = current_bin_edges(end) + 1;
            LNPStats(behavior_index).bin_edges = current_bin_edges;

            [current_filtered_signal_histogram, ~] = histc(all_filtered_signal, current_bin_edges);
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
    end
