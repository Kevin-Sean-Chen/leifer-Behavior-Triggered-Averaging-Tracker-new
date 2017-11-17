%% compare base rate and the peak predicted transition rate
if BTA_playback
    baseline_start = 1;
    baseline_end = 20*fps;
    peak_window = 2*fps;
    peak_predicted_rate_location = 40 * fps;

    
    transition_rate_changes = zeros(1,number_of_stimulus_templates);
    transition_rate_propagated_errors = zeros(1,number_of_stimulus_templates);
    transition_rate_change_significance = false(1,number_of_stimulus_templates);
    predicted_rate_changes = zeros(1,number_of_stimulus_templates);
    my_colors = behavior_colors;
    
    for stimulus_index = 1:number_of_stimulus_templates
        transition_rate_for_frame = zeros(number_of_behaviors,stimulus_period);
        transition_std_for_frame = zeros(number_of_behaviors,stimulus_period);
        for frame_index = 1:stimulus_period
            transitions_for_frame = all_behavior_transitions_for_frame{stimulus_index}{frame_index};
            transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
            %transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
        end

        track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));

        %find the peak predicted rate in the experimental window
        behavior_index = stimulus_to_behavior_key(stimulus_index);
        predicted_rate = predicted_behavior_transitions_for_stim{stimulus_index}(behavior_index,:);
%         [~, peak_predicted_rate_location] = max(predicted_rate);
        exp_start = peak_predicted_rate_location - (peak_window/2);
        exp_end = peak_predicted_rate_location + (peak_window/2);
        [~, baseline_mean, ~, ~, baseline_std, exp_mean, exp_std, p] = percent_change_above_baseline(transition_rate_for_frame(behavior_index,:),baseline_start,baseline_end,exp_start,exp_end);
        
        %find the change
        predicted_rate_baseline = mean(predicted_behavior_transitions_for_stim{stimulus_index}(behavior_index,baseline_start:baseline_end));
        predicted_rate_exp = mean(predicted_behavior_transitions_for_stim{stimulus_index}(behavior_index,exp_start:exp_end));
        predicted_rate_changes(stimulus_index) = (predicted_rate_exp - predicted_rate_baseline) ./ predicted_rate_baseline;
        
        transition_rate_changes(stimulus_index) = (exp_mean - baseline_mean) ./ baseline_mean;
        transition_rate_propagated_errors(stimulus_index) = abs(transition_rate_changes(stimulus_index)) * sqrt(((exp_std./exp_mean).^2)+((baseline_std./baseline_mean).^2));
        transition_rate_change_significance(stimulus_index) = p < 0.05;
    end
    
    figure('pos',[0,0,600,400])
    hold on
    
%     h = barwitherr(transition_rate_propagated_errors, transition_rate_changes, 'linewidth',1);
    %set(h(1), 'FaceColor',behavior_colors(stimulus_to_behavior_key(stimulus_index),:));
    
    for stimulus_index = 1:number_of_stimulus_templates
        bar(stimulus_index-0.2,transition_rate_changes(stimulus_index),0.4,'FaceColor',behavior_colors(stimulus_to_behavior_key(stimulus_index),:));
        bar(stimulus_index+0.2,predicted_rate_changes(stimulus_index),0.4,'FaceColor',behavior_colors(stimulus_to_behavior_key(stimulus_index),:),'facealpha', 0.5);
    end
    errorbar((1:stimulus_index)-0.2,transition_rate_changes,transition_rate_propagated_errors, 'k', 'linestyle', 'none', 'marker', 'none')

    for stimulus_index = 1:number_of_stimulus_templates
        if transition_rate_change_significance(stimulus_index)
             text(stimulus_index-0.2, 0.3, '*', 'Fontsize', 20, 'HorizontalAlignment','center')
%             sigstar({[stimulus_index-0.2, stimulus_index+0.2]},0.05)
        end
    end
    
    ax = gca;
    ax.FontSize = 8;

    set(gca,'XTick',1:number_of_stimulus_templates)
    set(gca, 'XTickLabels', behavior_names(stimulus_to_behavior_key))
    axis([0, number_of_stimulus_templates+1, -0.1, 0.4])
    limits = get(gca,'YLim');
    set(gca,'YTick',linspace(limits(1),limits(2),3))
    xlabel('') % x-axis label
    ylabel('Fraction Change') % y-axis label
%     title([behavior_names{stimulus_to_behavior_key(stimulus_index)}, ' (n = ', num2str(track_n), ')']);
%     legend(prediction_plot)
end