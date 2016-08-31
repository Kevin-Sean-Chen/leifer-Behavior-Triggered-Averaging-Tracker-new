function [] = PlotExperimentGroupAdapted (Experiments)
%Takes in structure Experiments and plots them depending on  the settings
%   Detailed explanation goes here
    fps = 14;
    BTA_seconds_before = 10;
    BTA_seconds_after = 1;
    rows_per_page = 3;
    NumTicks = 3;

    figure
    plot_BTA = 1;
    plot_linear_filter = 0;
    plot_speed = 0;
    plot_LED_voltage = 0;
    plot_filtered_signal = 0;
    plot_filtered_signal_histogram = 0;
    plot_filtered_signal_given_reversal_histogram = 0;
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
    plots_per_experiment = reversal_rate_plot_number;
    
    for experiment_index = 1:length(Experiments)
        %plot BTA
        if plot_BTA
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(experiment_index-1) + BTA_plot_number);
            hold on
            shadedErrorBar(-BTA_seconds_before:1/fps:BTA_seconds_after, Experiments(experiment_index).BTA, 2/sqrt(Experiments(experiment_index).pirouetteCount)*ones(1,length(Experiments(experiment_index).BTA)), {'-k', 'Linewidth', 3});
            meanLEDVoltageY = zeros(1,length(Experiments(experiment_index).BTA));
            meanLEDVoltageY(:) = Experiments(experiment_index).meanLEDVoltage;
            plot(-BTA_seconds_before:1/fps:BTA_seconds_after, meanLEDVoltageY, 'r', 'Linewidth', 3)
            hold off
            xlabel(strcat('Time (s) (', num2str(Experiments(experiment_index).pirouetteCount), ' behaviors analyzed)')) % x-axis label
            ylabel('Stimulus Intensity (V)') % y-axis label
            axis([-10 10 0.64 0.84])
            %axis([-10 2 0 5])
            ax = gca;
            %ax.XTick = ;
            ax.YTick = linspace(0.64,0.84,5);
            ax.FontSize = 10;
            limits = get(gca,'XLim');
            set(gca,'XTick',linspace(limits(1),limits(2),NumTicks))
            limits = get(gca,'YLim');
            set(gca,'YTick',linspace(limits(1),limits(2),NumTicks))

        end
        
        %plot speed
        if plot_speed
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(experiment_index-1) + speed_plot_number);
            plot(Experiments(experiment_index).Speed)
            xlabel(['minutes (average speed = ', num2str(sum(Experiments(experiment_index).speed_sum)/sum(Experiments(experiment_index).frame_count)),')']) % x-axis label
            ylabel('speed (mm/s)') % y-axis label
            axis([1 30 0 0.3])
        end
        
        %plot linear kernel
        if plot_linear_filter
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(experiment_index-1) + linear_filter_plot_number);
            hold on
            shadedErrorBar(0:1/fps:kernel_seconds_before, Experiments(experiment_index).linear_kernel, 2/sqrt(Experiments(experiment_index).pirouetteCount)*ones(1,length(Experiments(experiment_index).linear_kernel)));
            plot(0:1/fps:kernel_seconds_before, 0, 'r')
            hold off
            xlabel(strcat('second (', num2str(Experiments(experiment_index).pirouetteCount), ' behaviors analyzed)')) % x-axis label
            ylabel('voltage') % y-axis label
        end
        
        %plot LEDVoltages
        if plot_LED_voltage
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(experiment_index-1) + LED_voltage_plot_number);
            plot(1/fps:1/fps:length(Experiments(experiment_index).LEDVoltages)/fps, Experiments(experiment_index).LEDVoltages)
            xlabel(['minutes (average speed = ', num2str(sum(speed_sum)/sum(frame_count)),')']) % x-axis label
            ylabel('voltage (V)') % y-axis label
        end
        
        %plot the filtered signal
        if plot_filtered_signal
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(experiment_index-1) + filtered_signal_plot_number);
            plot(1/fps:1/fps:length(Experiments(experiment_index).FilteredSignal)/fps, Experiments(experiment_index).FilteredSignal)
        end

        %plot the filtered signal histogram
        if plot_filtered_signal_histogram
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(experiment_index-1) + filtered_signal_histogram_plot_number);
            bar(Experiments(experiment_index).bin_edges(1:end-1), Experiments(experiment_index).filtered_signal_histogram);
            set(gca,'XTick',round(Experiments(experiment_index).bin_edges*100)/100)
        end
        
        %plot the filtered signal given reversal histogram
        if plot_filtered_signal_given_reversal_histogram
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(experiment_index-1) + filtered_signal_given_reversal_histogram_plot_number);
            bar(Experiments(experiment_index).bin_edges(1:end-1), Experiments(experiment_index).filtered_signal_given_reversal_histogram');
            set(gca,'XTick',round(Experiments(experiment_index).bin_edges*100)/100)
        end
        
        bin_centers = Experiments(experiment_index).bin_edges(1:end-1)+(diff(Experiments(experiment_index).bin_edges(1:2)/2));
%        non_linearity_fit = fit(bin_centers',non_linearity','exp1');   %refit of necessary
        non_linearity_fit = Experiments(experiment_index).non_linearity_fit;
        Experiments(experiment_index).exp_fit_a = non_linearity_fit.a;
        Experiments(experiment_index).exp_fit_b = non_linearity_fit.b;
        
        %plot non linearity
        if plot_non_linearity
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(experiment_index-1) + non_linearity_plot_number);
            non_linearity = Experiments(experiment_index).filtered_signal_given_reversal_histogram ./ Experiments(experiment_index).filtered_signal_histogram*60*fps;
            fig = gcf;
            prev_line_marker_size = get(fig,'DefaultLineMarkerSize');
            prev_line_width = get(fig,'DefaultLineLineWidth');
            set(fig,'DefaultLineMarkerSize',30);
            set(fig,'DefaultLineLineWidth',5)
            hold on
            plot(non_linearity_fit,bin_centers,non_linearity)
            [~,~,errors] = fit_nonlinearity(Experiments(experiment_index).filtered_signal_given_reversal_histogram, ...
                Experiments(experiment_index).filtered_signal_histogram, Experiments(experiment_index).bin_edges);
            try
%                 errorbar(bin_centers,non_linearity,errors, 'b.')
            catch
            end
            ax = gca;
            %ax.XTick = ;
            %ax.YTick = linspace(0.64,0.84,5);
            ax.FontSize = 10;
            old_ylim = ylim;
%             ylim([0 old_ylim(2)]);
            ylim([0 4]);

            xlabel('Filtered Signal (a.u.)') % x-axis label
            ylabel('Reversal Rate (Reversals/Min)') % y-axis label
            legend('off')
            set(fig,'DefaultLineMarkerSize',prev_line_marker_size);
            set(fig,'DefaultLineLineWidth',prev_line_width)
            limits = get(gca,'XLim');
            set(gca,'XTick',linspace(limits(1),limits(2),NumTicks))
            limits = get(gca,'YLim');
            set(gca,'YTick',linspace(limits(1),limits(2),NumTicks))

        end
        
        %plot it along along with the rate of behaviors
        if plot_reversal_rate
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(experiment_index-1) + reversal_rate_plot_number);
            hold on
            %plot(Experiments(experiment_index).FilteredSignal/max(Experiments(experiment_index).FilteredSignal));
            %plot(Experiments(experiment_index).ReversalRate/max(Experiments(experiment_index).ReversalRate));
            plot(Experiments(experiment_index).ReversalRate, 'bo-')
            xlabel(['minutes (', num2str(sum(Experiments(experiment_index).ReversalCounts)), ' reversals analyzed) average reversal rate = ', num2str(sum(Experiments(experiment_index).ReversalCounts)/sum(Experiments(experiment_index).FrameCounts)*fps*60)]) % x-axis label
            ylabel('reversals per worm per min') % y-axis label
            axis([1 length(Experiments(experiment_index).ReversalRate) 0 3])
        end
    end

end

