%% all 72 context dependent transitions differences for optotap experiments in a grid
all_edge_pairs = get_edge_pairs(number_of_behaviors);

mean_optotap_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_optotap_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
optotap_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
optotap_observation_counts = zeros(number_of_behaviors, number_of_behaviors);

mean_control_optotap_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_control_optotap_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
control_optotap_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
control_optotap_observation_counts = zeros(number_of_behaviors, number_of_behaviors);
bootstrap_fractional_increases = cell(number_of_behaviors, number_of_behaviors);

optotap_difference_significant = false(number_of_behaviors, number_of_behaviors);
optotap_pvalue = eye(number_of_behaviors);
control_hypothesis_counts = 0;
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            [mean_optotap_transition_rates(behavior_from,behavior_to),mean_control_optotap_transition_rates(behavior_from,behavior_to), ...
                std_optotap_transition_rates(behavior_from,behavior_to),std_control_optotap_transition_rates(behavior_from,behavior_to), ...
                optotap_difference_significant(behavior_from,behavior_to),optotap_pvalue(behavior_from,behavior_to), ...
                optotap_transitions_counts(behavior_from,behavior_to),control_optotap_transitions_counts(behavior_from,behavior_to),...
                optotap_observation_counts(behavior_from,behavior_to),control_optotap_observation_counts(behavior_from,behavior_to)] = ...
                average_transition_rate_after_tap(folders_optotap, behavior_from, behavior_to);
            
            %bootstrap values for fractional increase from baseline after stim
            stim_sample_count = optotap_observation_counts(behavior_from,behavior_to)/29; % 29 is 2 seconds
            control_sample_count = control_optotap_observation_counts(behavior_from,behavior_to)/29;
            stim_samples = false(1,stim_sample_count);
            stim_samples(1:optotap_transitions_counts(behavior_from,behavior_to)) = true;            
            control_samples = false(1,control_sample_count);
            control_samples(1:control_optotap_transitions_counts(behavior_from,behavior_to)) = true;
            bootstrap_frac_inc = zeros(1,boostrap_n);
            for bootstrap_index = 1:boostrap_n
                bootstrap_stim_sample = datasample(stim_samples,stim_sample_count);
                bootstrap_control_sample = datasample(control_samples,stim_sample_count);
                if any(bootstrap_control_sample)
                    bootstrap_frac_inc(bootstrap_index) = (sum(bootstrap_stim_sample)/stim_sample_count) / (sum(bootstrap_control_sample)/control_sample_count);
                end
            end
            bootstrap_fractional_increases{behavior_from,behavior_to} = bootstrap_frac_inc;
            
            control_hypothesis_counts = control_hypothesis_counts + 1;
        end
    end
end
%multiple hypothesis testing correction of significance
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            optotap_difference_significant(behavior_from,behavior_to) = 0.05./control_hypothesis_counts > optotap_pvalue(behavior_from,behavior_to);
        end
    end
end

%plot reversal fractioal increase from bootstrapping
behavior_to = 3;
turn_bootstrap_frac_inc_mean = mean(bootstrap_fractional_increases{2,behavior_to});
turn_bootstrap_frac_inc_std = std(bootstrap_fractional_increases{2,behavior_to});

fwd_bootstrap_frac_inc_mean = mean(bootstrap_fractional_increases{1,behavior_to});
fwd_bootstrap_frac_inc_std = std(bootstrap_fractional_increases{1,behavior_to});

%get p value using 2 tails
bootstrap_frac_inc_diff = bootstrap_fractional_increases{1,behavior_to} - bootstrap_fractional_increases{2,behavior_to};
bootstrap_frac_inc_diff_mean_offset_abs = abs(bootstrap_frac_inc_diff - mean(bootstrap_frac_inc_diff));
mean_distance = abs(turn_bootstrap_frac_inc_mean - fwd_bootstrap_frac_inc_mean);
p = sum(bootstrap_frac_inc_diff_mean_offset_abs > mean_distance) ./ length(bootstrap_frac_inc_diff_mean_offset_abs); %find the fraction of points with larger difference when the null is true

figure
barwitherr([fwd_bootstrap_frac_inc_std; turn_bootstrap_frac_inc_std], [fwd_bootstrap_frac_inc_mean; turn_bootstrap_frac_inc_mean],'FaceColor',behavior_colors(behavior_to,:))
ax = gca;
if p < 0.05
    sigstar({[1,2]},p);
end
box('off')
set(gca,'YTick',[0 10])
set(gca,'XTickLabel',{'Fwd','Turn'})
set(gca,'fontsize',14)
ylabel('Times More Likely to Reverse with Stim')
title(['p=', num2str(p)])
axis([0 3 0 10]);



% %plot it
% figure
% for behavior_from = 1:number_of_behaviors
%     for behavior_to = 1:number_of_behaviors
%         if behavior_from ~= behavior_to
%             if control_optotap_transitions_counts(behavior_from,behavior_to) == 0 && optotap_transitions_counts(behavior_from,behavior_to) == 0
%             else
%                 scrollsubplot(rows_per_page,double(number_of_behaviors),double((behavior_from-1)*number_of_behaviors+behavior_to))
%                 barwitherr([std_control_optotap_transition_rates(behavior_from,behavior_to); std_optotap_transition_rates(behavior_from,behavior_to)], [mean_control_optotap_transition_rates(behavior_from,behavior_to); mean_optotap_transition_rates(behavior_from,behavior_to)],'FaceColor',behavior_colors(behavior_to,:))
%                 ax = gca;
%                 if optotap_difference_significant(behavior_from,behavior_to)
%                     sigstar({[1,2]},0.05);
%     %                 ax.XColor = 'red';
%     %                 ax.YColor = 'red';
%     %                 title({['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(optotap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'r')
%     %             else
%     %                 title({['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(optotap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'k')
%     %                 sigstar({[1,2]},nan,0,30);           
%                 end
%     %             set(gca,'XTickLabel',{['n=',num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=', num2str(optotap_pvalue(behavior_from,behavior_to))]})
%     %             if behavior_from == 2 && behavior_to == 1
%     %                 ylabel('Platetap Transition Rate (transitions/min)')
%     % %             else
%     % %                 set(gca,'YTick','')
%     %             end
%                 title(['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],'Color', 'k', 'FontWeight', 'normal', 'Fontsize', 14)
%     %             title({['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(optotap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'k')
%                 box('off')
%                 set(gca,'XTick','')
%                 set(gca,'fontsize',14)
%                 y_limits = ylim;             %get y lim
%                 new_ylim = y_limits(2);
% %                new_ylim = 2;
%                 if new_ylim > 1
%                     new_ylim = ceil(y_limits(2));
%                 else
%                     new_ylim = 1;
%                 end
%                 axis([0 3 0 new_ylim]);
%                 if (behavior_from == 9 && behavior_to == 1) || new_ylim > 1
%                     ax.YTick = linspace(0,new_ylim,2);
%                 else
%                     set(gca,'YTick','')
%                 end
%             end
%         end
%     end
% end
