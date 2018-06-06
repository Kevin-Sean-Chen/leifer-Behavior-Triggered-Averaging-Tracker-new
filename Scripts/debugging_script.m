figure
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            [~,edge_index] = ismember(all_edge_pairs, [behavior_from, behavior_to], 'rows');
            edge_index = find(edge_index);
            if control_transition_prob_for_window(edge_index) == 0 && tap_transition_prob_for_window(edge_index) == 0
            else
                scrollsubplot(rows_per_page,double(number_of_behaviors),double((behavior_from-1)*number_of_behaviors+behavior_to))
                barwitherr([control_transition_std_for_window(edge_index); tap_transition_std_for_window(edge_index)], [control_transition_prob_for_window(edge_index); tap_transition_prob_for_window(edge_index)],'FaceColor',behavior_colors(behavior_to,:))
                ax = gca;

                title(['n=', num2str(control_track_n),', ',num2str(tap_track_n)],'Color', 'k', 'FontWeight', 'normal', 'Fontsize', 14)
                box('off')
                set(gca,'XTick','')
                set(gca,'fontsize',14)
                axis([0 3 0 1]);
            end
        end
    end
end
