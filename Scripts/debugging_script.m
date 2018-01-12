all_edge_pairs = get_edge_pairs(number_of_behaviors);

mean_optotap_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_optotap_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
optotap_observed_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
mean_shuffled_optotap_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_shuffled_optotap_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
shuffled_optotap_observed_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
optotap_difference_significant = false(number_of_behaviors, number_of_behaviors);

for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            [optotap_transition_rates,control_optotap_transition_rates,h,~,~,~,optotap_observed_transitions_count,optocontrol_observed_transitions_count] = average_transition_rate_after_tap(folders_optotap, behavior_from, behavior_to);
            mean_optotap_transition_rates(behavior_from,behavior_to) = mean(optotap_transition_rates);
            std_optotap_transition_rates(behavior_from,behavior_to) = std(optotap_transition_rates);
            mean_shuffled_optotap_transition_rates(behavior_from,behavior_to) = mean(control_optotap_transition_rates);
            std_shuffled_optotap_transition_rates(behavior_from,behavior_to) = std(control_optotap_transition_rates);
            optotap_difference_significant(behavior_from,behavior_to) = h;
            optotap_observed_transitions_counts(behavior_from,behavior_to) = optotap_observed_transitions_count;
            shuffled_optotap_observed_transitions_counts(behavior_from,behavior_to) = optocontrol_observed_transitions_count;
        end
    end
end

%plot it
figure
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            barwitherr([std_shuffled_optotap_transition_rates(behavior_from,behavior_to); std_optotap_transition_rates(behavior_from,behavior_to)], [mean_shuffled_optotap_transition_rates(behavior_from,behavior_to); mean_optotap_transition_rates(behavior_from,behavior_to)],'FaceColor',behavior_colors(behavior_to,:))
            if optotap_difference_significant(behavior_from,behavior_to)
                sigstar({[1,2]},0.05);
            else
                sigstar({[1,2]},nan);           
            end
            axis([0 3 0 40])
            set(gca,'XTickLabel',{['n=',num2str(shuffled_optotap_observed_transitions_counts(behavior_from,behavior_to))],['n=',num2str(optotap_observed_transitions_counts(behavior_from,behavior_to))]})
            if behavior_to == 1
                ylabel('Tap Transition Rate (transitions/min)')
            else
                set(gca,'YTick','')
            end
        end
    end
end

