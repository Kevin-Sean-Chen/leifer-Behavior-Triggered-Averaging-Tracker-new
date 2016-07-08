function [] = PlotBehavioralMappingExperimentGroup (LNPStats, meanLEDVoltage, stdLEDPower, L, density, xx)
%Takes in structure LNPStats and plots them depending on the settings
%   Detailed explanation goes here
    fps = 14;
    BTA_seconds_before = 10;
    BTA_seconds_after = 10;
    kernel_seconds_before = BTA_seconds_before;
    rows_per_page = 3;
    
    figure
    plot_watershed = 1;
    plot_BTA = 1;
    plot_linear_filter = 0;
    plot_filtered_signal_histogram = 0;
    plot_filtered_signal_given_reversal_histogram = 0;
    plot_non_linearity = 1;
    
    watershed_plot_number = plot_watershed;
    BTA_plot_number = watershed_plot_number+plot_BTA;
    linear_filter_plot_number = BTA_plot_number+plot_linear_filter;
    filtered_signal_histogram_plot_number = linear_filter_plot_number+plot_filtered_signal_histogram;
    filtered_signal_given_reversal_histogram_plot_number = filtered_signal_histogram_plot_number+plot_filtered_signal_given_reversal_histogram;
    non_linearity_plot_number = filtered_signal_given_reversal_histogram_plot_number+plot_non_linearity;
    plots_per_experiment = non_linearity_plot_number;
    
    watershed_borders_binary = L==0;
%     [ii,jj] = find(watershed_borders_binary);
    maxDensity = max(density(:));
    watershed_centroids = regionprops(L, 'centroid');
    watershed_centroids = vertcat(watershed_centroids.Centroid);
    watershed_centroids = round(watershed_centroids);

    for behavior_index = 1:length(LNPStats)
        %plot watershed
        if plot_watershed
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(behavior_index-1) + watershed_plot_number);
            hold on
            imagesc(xx,xx,density)
            watershed_region_binary = L==behavior_index;
            enlarged_watershed_region_binary = imdilate(watershed_region_binary, true(3));
            watershed_region_border = and(watershed_borders_binary, enlarged_watershed_region_binary);
            [ii,jj] = find(watershed_region_border);
            plot(xx(jj),xx(ii),'m.')
            axis equal tight off xy
            caxis([0 maxDensity * .8])
            colormap(jet)
            text(xx(watershed_centroids(behavior_index,1)), ...
                xx(watershed_centroids(behavior_index,2)), ...
                num2str(behavior_index), 'color', 'm', ...
                'fontsize', 12, 'horizontalalignment', 'center', ...
                'verticalalignment', 'middle');
            hold off
        end
        
        %plot BTA
        if plot_BTA
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(behavior_index-1) + BTA_plot_number);
            hold on
            %shaded error bar represents the mean of the angular error
            shadedErrorBar(-BTA_seconds_before:1/fps:BTA_seconds_after, LNPStats(behavior_index).BTA, 2*stdLEDPower*sqrt(2/LNPStats(behavior_index).trigger_count)*ones(1,length(LNPStats(behavior_index).BTA)), {'-k', 'Linewidth', 3});
            meanLEDVoltageY = zeros(1,length(LNPStats(behavior_index).BTA));
            meanLEDVoltageY(:) = meanLEDVoltage;
            plot(-BTA_seconds_before:1/fps:BTA_seconds_after, meanLEDVoltageY, 'r', 'Linewidth', 3)
            hold off
            xlabel(strcat('Time (s) (', num2str(LNPStats(behavior_index).trigger_count), ' behaviors analyzed)')) % x-axis label
            ylabel('Stimulus Intensity (V)') % y-axis label
%             axis([-10 10 0.64 0.84])
            %axis([-10 2 0 5])
            ax = gca;
            %ax.XTick = ;
%             ax.YTick = linspace(0.64,0.84,5);
            ax.FontSize = 10;
        end
        
        %plot linear kernel
        if plot_linear_filter
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(behavior_index-1) + linear_filter_plot_number);
            hold on
            shadedErrorBar(0:1/fps:(length(LNPStats(behavior_index).linear_kernel)-1)/fps, LNPStats(behavior_index).linear_kernel, 2/sqrt(LNPStats(behavior_index).trigger_count)*ones(1,length(LNPStats(behavior_index).linear_kernel)));
            plot(0:1/fps:(length(LNPStats(behavior_index).linear_kernel)-1)/fps, 0, 'r')
            hold off
            xlabel(strcat('second (', num2str(LNPStats(behavior_index).trigger_count), ' behaviors analyzed)')) % x-axis label
            ylabel('voltage') % y-axis label
        end

        %plot the filtered signal histogram
        if plot_filtered_signal_histogram
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(behavior_index-1) + filtered_signal_histogram_plot_number);
            bar(LNPStats(behavior_index).bin_edges(1:end-1), LNPStats(behavior_index).filtered_signal_histogram);
            set(gca,'XTick',round(LNPStats(behavior_index).bin_edges*100)/100)
        end
        
        %plot the filtered signal given reversal histogram
        if plot_filtered_signal_given_reversal_histogram
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(behavior_index-1) + filtered_signal_given_reversal_histogram_plot_number);
            bar(LNPStats(behavior_index).bin_edges(1:end-1), LNPStats(behavior_index).filtered_signal_given_reversal_histogram');
            set(gca,'XTick',round(LNPStats(behavior_index).bin_edges*100)/100)
        end
        
        bin_centers = LNPStats(behavior_index).bin_edges(1:end-1)+(diff(LNPStats(behavior_index).bin_edges(1:2)/2));
%        non_linearity_fit = fit(bin_centers',non_linearity','exp1');   %refit of necessary
        non_linearity_fit = LNPStats(behavior_index).non_linearity_fit;
        LNPStats(behavior_index).exp_fit_a = non_linearity_fit.a;
        LNPStats(behavior_index).exp_fit_b = non_linearity_fit.b;
        
        %plot non linearity
        if plot_non_linearity
            scrollsubplot(rows_per_page, plots_per_experiment, plots_per_experiment*(behavior_index-1) + non_linearity_plot_number);
            non_linearity = LNPStats(behavior_index).filtered_signal_given_reversal_histogram ./ LNPStats(behavior_index).filtered_signal_histogram*60*fps;
            fig = gcf;
            prev_line_marker_size = get(fig,'DefaultLineMarkerSize');
            prev_line_width = get(fig,'DefaultLineLineWidth');
            set(fig,'DefaultLineMarkerSize',30);
            set(fig,'DefaultLineLineWidth',5)
            plot(non_linearity_fit,bin_centers,non_linearity)
            %axis([-3 4 0 3])
            ax = gca;
            %ax.XTick = ;
            %ax.YTick = linspace(0.64,0.84,5);
            ax.FontSize = 10;

            xlabel('Filtered Signal (a.u.)') % x-axis label
            ylabel('Behavioral Rate (Behaviors/Min)') % y-axis label
            legend('off')
            set(fig,'DefaultLineMarkerSize',prev_line_marker_size);
            set(fig,'DefaultLineLineWidth',prev_line_width)
        end
    end

end

