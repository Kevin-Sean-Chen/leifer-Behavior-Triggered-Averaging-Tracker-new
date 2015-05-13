% analyzes a group of experiments and saves the properties
% they will be saved inside the first folder
function Experiments = CreateExperimentGroup()
    %clear all;
   
    fps = 14;
    BTA_seconds_before = 10;
    BTA_seconds_after = 1;
    kernel_seconds_before = 6;
    folders = {};
    Experiments = [];
    
    [filename,pathname] = uiputfile('*.mat','Save Experiment Group As');
    
    if isequal(filename,0) || isequal(pathname,0)
        %cancel
       return
    else
        saveFileName = fullfile(pathname,filename);
        if exist(saveFileName, 'file')
          % File exists.  Load the folders
          load(saveFileName)
          folders = {Experiments(1:end-1).Folder};
          Experiments = [];
          for i = 1:length(folders)
              Experiments(i).Folder = folders{i};
          end
        else
          % File does not exist. Ask for experiment folders
            while true
                if isempty(folders)
                    start_path = pathname;
                else
                    start_path = fileparts(fullfile(folders{length(folders)}, '..', filename)); %display the parent folder
                end
                folder_name = uigetdir(start_path, 'Select Experiment Folder')
                if folder_name == 0
                    break
                else
                    folders{length(folders)+1} = folder_name;
                    Experiments(length(folders)).Folder = folder_name;
                end
            end
        end
    end
    allTracks = struct([]);

    figure
    plot_BTA = 1;
    plot_linear_filter = 1;
    plot_speed = 0;
    plot_LED_voltage = 0;
    plot_filtered_signal = 0;
    plot_filtered_signal_histogram = 1;
    plot_filtered_signal_given_reversal_histogram = 1;
    plot_non_linearity = 1;
    plot_reversal_rate = 0;
    
    
    BTA_plot_number = plot_BTA;
    linear_filter_plot_number = BTA_plot_number+plot_linear_filter;
    speed_plot_number = linear_filter_plot_number+plot_speed;
    LED_voltage_plot_number = speed_plot_number+plot_LED_voltage;
    filtered_signal_plot_number = LED_voltage_plot_number+plot_filtered_signal;
    filtered_signal_histogram_plot_number = filtered_signal_plot_number+plot_filtered_signal_histogram;
    filtered_signal_given_reversal_histogram_plot_number = filtered_signal_histogram_plot_number+plot_filtered_signal_given_reversal_histogram;
    non_linearity_plot_number = filtered_signal_given_reversal_histogram_plot_number+plot_non_linearity;
    reversal_rate_plot_number = non_linearity_plot_number+plot_reversal_rate;
    
    rows_per_page = 3;
    plots_per_experiment = reversal_rate_plot_number;
    
    for folder_index = 1:length(folders)
        folder_name = folders{folder_index};
        cd(folder_name) %open the directory of image sequence
        load('tracks.mat')
        load('LEDVoltages.txt')
        if length(allTracks) == 0
            allTracks = Tracks;
        else
            allTracks = [allTracks, Tracks];
        end
        
        meanLEDVoltage = mean(LEDVoltages);
        %plot BTA
        [Experiments(folder_index).BTA, Experiments(folder_index).pirouetteCount] = BehaviorTriggeredAverage([], Tracks);
        if plot_BTA
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(folder_index-1) + BTA_plot_number);
            hold on
                shadedErrorBar(-BTA_seconds_before:1/fps:BTA_seconds_after, Experiments(folder_index).BTA, 2/sqrt(Experiments(folder_index).pirouetteCount)*ones(1,length(Experiments(folder_index).BTA)));
                meanLEDVoltageY = zeros(1,length(Experiments(folder_index).BTA));
                meanLEDVoltageY(:) = meanLEDVoltage;
                plot(-BTA_seconds_before:1/fps:BTA_seconds_after, meanLEDVoltageY, 'r')
            hold off
            xlabel(strcat('second (', num2str(Experiments(folder_index).pirouetteCount), ' reversals analyzed)')) % x-axis label
            ylabel('voltage') % y-axis label
            axis([-10 2 0.64 0.84])
            %axis([-10 2 0 5])
        end
        
        %plot speed
        [Experiments(folder_index).Speed, speed_sum, frame_count] = SpeedHistogram(folders(folder_index));
        if plot_speed
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(folder_index-1) + speed_plot_number);
            plot(Experiments(folder_index).Speed)
            xlabel(['minutes (average speed = ', num2str(sum(speed_sum)/sum(frame_count)),')']) % x-axis label
            ylabel('speed (mm/s)') % y-axis label
            axis([1 30 0 0.3])
        end
        
        Experiments(folder_index).ReversalRate = ReversalRate(folders(folder_index),1);
        
        %plot LEDVoltages
        Experiments(folder_index).LEDVoltages = LEDVoltages;
        if plot_LED_voltage
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(folder_index-1) + LED_voltage_plot_number);
            plot(1/fps:1/fps:length(Experiments(folder_index).LEDVoltages)/fps, Experiments(folder_index).LEDVoltages)
            xlabel(['minutes (average speed = ', num2str(sum(speed_sum)/sum(frame_count)),')']) % x-axis label
            ylabel('voltage (V)') % y-axis label
        end
    end
    
    meanLEDVoltage = mean([Experiments.LEDVoltages]);
    
    %the very last entry in Experiments is the average of all experiments
    [Experiments(length(folders)+1).BTA, Experiments(length(folders)+1).pirouetteCount] = BehaviorTriggeredAverage(folders);
    if plot_BTA
        scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*length(folders) + BTA_plot_number);
        meanLEDVoltageY = zeros(1,length(Experiments(folder_index).BTA));
        meanLEDVoltageY(:) = meanLEDVoltage;
        hold on
        shadedErrorBar(-BTA_seconds_before:1/fps:BTA_seconds_after, Experiments(length(folders)+1).BTA, 2/sqrt(Experiments(length(folders)+1).pirouetteCount)*ones(1,length(Experiments(length(folders)+1).BTA)));
        plot(-BTA_seconds_before:1/fps:BTA_seconds_after, meanLEDVoltageY, 'r')
        hold off
        xlabel(strcat('second (', num2str(Experiments(length(folders)+1).pirouetteCount), ' reversals analyzed)')) % x-axis label
        ylabel('voltage') % y-axis label
        axis([-10 2 0.64 0.84])
        %axis([-10 2 0 5])
    end
    
    [Experiments(length(folders)+1).Speed, speed_sum, frame_count]  = SpeedHistogram(folders);
    if plot_speed
        scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*length(folders) + speed_plot_number);
        plot(Experiments(length(folders)+1).Speed)
        xlabel(['minutes (average speed = ', num2str(sum(speed_sum)/sum(frame_count)),')']) % x-axis label
        ylabel('speed (mm/s)') % y-axis label
        axis([1 30 0 0.3])
    end
    %Experiments(length(folders)+1).ReversalRate = ReversalRate(folders,1);
    
    
    %get the linear kernel from BTA
    BTA = Experiments(length(folders)+1).BTA;
    pirouetteCount = Experiments(folder_index+1).pirouetteCount;
    BTA = BTA((BTA_seconds_before-kernel_seconds_before)*fps+1:length(BTA)-(BTA_seconds_after*fps)); %will have size fps*kernel_seconds_before+1 because frame at 0 is also counted
    linear_kernel = fliplr(BTA - meanLEDVoltage); %time in BTA is reversed in linear kernel
    
    %linear_kernel = fliplr(BTA - min(BTA)); %time in BTA is reversed in linear kernel
    %smooth the linear_kernel? Approximate by gaussian and exponential?
    
    %plot linear kernel
    if plot_linear_filter
        scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*length(folders) + linear_filter_plot_number);
        shadedErrorBar(0:1/fps:kernel_seconds_before, linear_kernel, 2/sqrt(pirouetteCount)*ones(1,length(linear_kernel)));
        xlabel(strcat('second (', num2str(pirouetteCount), ' reversals analyzed)')) % x-axis label
        ylabel('voltage') % y-axis label
    end
    
    for folder_index = 1:length(folders)+1
        %convolve the linear kernels with the input signal of LED voltages
        if folder_index > length(folders)
            %the average case, concatenate all the filtered signals found
            %before
            Experiments(folder_index).FilteredSignal = [Experiments.FilteredSignal];
        else
            filtered_signal = conv(Experiments(folder_index).LEDVoltages, linear_kernel);
            Experiments(folder_index).FilteredSignal = filtered_signal(1:length(Experiments(folder_index).LEDVoltages)); %cut off the tail
        end
        
        if plot_filtered_signal
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(folder_index-1) + filtered_signal_plot_number);
            plot(1/fps:1/fps:length(Experiments(folder_index).FilteredSignal)/fps, Experiments(folder_index).FilteredSignal)
        end
        
        %make histogram of filtered signal
        numbins = 10;
        bin_edges = linspace(min(Experiments(folder_index).FilteredSignal), max(Experiments(folder_index).FilteredSignal), numbins+1);
        bin_edges(end) = bin_edges(end) + 1;
        [filtered_signal_histogram, bin_indecies] = histc(Experiments(folder_index).FilteredSignal, bin_edges);
        filtered_signal_histogram = filtered_signal_histogram(1:end-1);
        if plot_filtered_signal_histogram
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(folder_index-1) + filtered_signal_histogram_plot_number);
            bar(bin_edges(1:end-1), filtered_signal_histogram);
            set(gca,'XTick',round(bin_edges*100)/100)
        end
        
        if folder_index > length(folders)
            %the average case, concatenate all the reversals
            Experiments(folder_index).ReversalRate = [Experiments.ReversalRate];
        end
        %get histogram of filtered_signal given a reversal
        filtered_signal_given_reversal_histogram = accumarray(bin_indecies', Experiments(folder_index).ReversalRate / fps / 60')';
        if plot_filtered_signal_given_reversal_histogram
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(folder_index-1) + filtered_signal_given_reversal_histogram_plot_number);
            bar(bin_edges(1:end-1), filtered_signal_given_reversal_histogram');
            set(gca,'XTick',round(bin_edges*100)/100)
        end
        
        non_linearity = filtered_signal_given_reversal_histogram ./ filtered_signal_histogram;
        bin_centers = bin_edges(1:end-1)+(diff(bin_edges(1:2)/2));
        non_linearity_fit = fit(bin_centers',non_linearity','exp1');
        Experiments(folder_index).exp_fit_a = non_linearity_fit.a;
        Experiments(folder_index).exp_fit_b = non_linearity_fit.b;
        if plot_non_linearity
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(folder_index-1) + non_linearity_plot_number);
            hold on
            plot(non_linearity_fit,bin_centers,non_linearity)
            hold off
            xlabel('filtered signal (a.u.)') % x-axis label
            ylabel('reversal rate (reversals/worm/min)') % y-axis label
        end
        
        %plot it along along with the rate of reversals
        if plot_reversal_rate
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(folder_index-1) + reversal_rate_plot_number);
            hold on
            plot(Experiments(folder_index).FilteredSignal/max(Experiments(folder_index).FilteredSignal));
            plot(Experiments(folder_index).ReversalRate/max(Experiments(folder_index).ReversalRate));
            hold off
        end
    end
    
    save(saveFileName, 'Experiments', 'linear_kernel');
    
 end