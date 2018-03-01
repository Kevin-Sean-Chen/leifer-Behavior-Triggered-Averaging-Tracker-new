figure
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            if control_optotap_transitions_counts(behavior_from,behavior_to) == 0 && optotap_transitions_counts(behavior_from,behavior_to) == 0
            else
                scrollsubplot(rows_per_page,double(number_of_behaviors),double((behavior_from-1)*number_of_behaviors+behavior_to))
                barwitherr([std_control_optotap_transition_rates(behavior_from,behavior_to); std_optotap_transition_rates(behavior_from,behavior_to)], [mean_control_optotap_transition_rates(behavior_from,behavior_to); mean_optotap_transition_rates(behavior_from,behavior_to)],'FaceColor',behavior_colors(behavior_to,:))
                ax = gca;
                if optotap_difference_significant(behavior_from,behavior_to)
                    sigstar({[1,2]},0.05);
    %                 ax.XColor = 'red';
    %                 ax.YColor = 'red';
    %                 title({['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(optotap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'r')
    %             else
    %                 title({['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(optotap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'k')
    %                 sigstar({[1,2]},nan,0,30);           
                end
    %             set(gca,'XTickLabel',{['n=',num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=', num2str(optotap_pvalue(behavior_from,behavior_to))]})
    %             if behavior_from == 2 && behavior_to == 1
    %                 ylabel('Platetap Transition Rate (transitions/min)')
    % %             else
    % %                 set(gca,'YTick','')
    %             end
                title(['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],'Color', 'k', 'FontWeight', 'normal', 'Fontsize', 14)
    %             title({['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(optotap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'k')
                box('off')
                set(gca,'XTick','')
                set(gca,'fontsize',14)
                y_limits = ylim;             %get y lim
                axis([0 3 0 ceil(y_limits(2))]);
                ax.YTick = linspace(0,ceil(y_limits(2)),2);
            end
        end
    end
end