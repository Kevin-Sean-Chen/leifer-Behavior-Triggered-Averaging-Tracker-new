all_edge_pairs = get_edge_pairs(number_of_behaviors);

mean_optotap_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_optotap_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
optotap_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
optotap_observation_counts = zeros(number_of_behaviors, number_of_behaviors);

mean_control_optotap_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_control_optotap_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
control_optotap_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
control_optotap_observation_counts = zeros(number_of_behaviors, number_of_behaviors);

optotap_difference_significant = false(number_of_behaviors, number_of_behaviors);
optotap_pvalue = zeros(number_of_behaviors, number_of_behaviors);

for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            [mean_optotap_transition_rates(behavior_from,behavior_to),mean_control_optotap_transition_rates(behavior_from,behavior_to), ...
                std_optotap_transition_rates(behavior_from,behavior_to),std_control_optotap_transition_rates(behavior_from,behavior_to), ...
                optotap_difference_significant(behavior_from,behavior_to),optotap_pvalue(behavior_from,behavior_to), ...
                optotap_transitions_counts(behavior_from,behavior_to),control_optotap_transitions_counts(behavior_from,behavior_to),...
                optotap_observation_counts(behavior_from,behavior_to),control_optotap_observation_counts(behavior_from,behavior_to)] = ...
                average_transition_rate_after_tap(folders_optotap, behavior_from, behavior_to);
        end
    end
end

%plot it
figure
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            subplot(double(number_of_behaviors),double(number_of_behaviors),double((behavior_from-1)*number_of_behaviors+behavior_to))
            barwitherr([std_control_optotap_transition_rates(behavior_from,behavior_to); std_optotap_transition_rates(behavior_from,behavior_to)], [mean_control_optotap_transition_rates(behavior_from,behavior_to); mean_optotap_transition_rates(behavior_from,behavior_to)],'FaceColor',behavior_colors(behavior_to,:))
            %axis([0 3 0 40])
            if optotap_difference_significant(behavior_from,behavior_to)
                sigstar({[1,2]},0.05);
            else
%                 sigstar({[1,2]},nan,0,30);           
            end
            set(gca,'XTickLabel',{['n=',num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=', num2str(optotap_pvalue(behavior_from,behavior_to))]})
            if behavior_from == 2 && behavior_to == 1
                ylabel('Platetap Transition Rate (transitions/min)')
%             else
%                 set(gca,'YTick','')
            end
        end
    end
end
