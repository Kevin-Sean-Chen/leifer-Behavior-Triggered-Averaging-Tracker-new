function [behavior_ratios_for_frame,transition_rate_for_frame]=get_behavior_window(tracks)

number_of_behaviors=9;
fps=14;
behavior_counts_for_frame = zeros(number_of_behaviors,280);
behavior_transition_counts_for_frame = zeros(number_of_behaviors,280);
behavior_ratios_for_frame = zeros(number_of_behaviors,280);
total_counts_for_frame = zeros(1,280);

for frame_index = -139:140
    tracks_on_critical_frame = FilterTracksByTime(tracks, frame_index, frame_index);
    if ~isempty( tracks_on_critical_frame)
    behavior_annotations_for_frame = [tracks_on_critical_frame.BehavioralAnnotation];
    behavior_transitions_for_frame = [tracks_on_critical_frame.Behaviors];
    table_inx=frame_index+140;
    for behavior_index = 1:number_of_behaviors
        behavior_counts_for_frame(behavior_index, table_inx) = sum(behavior_annotations_for_frame == behavior_index);
    end
    behavior_transition_counts_for_frame(:, table_inx) = sum(behavior_transitions_for_frame,2);
    total_counts_for_frame(table_inx) = length(tracks_on_critical_frame);
    behavior_ratios_for_frame(:,table_inx) = behavior_counts_for_frame(:,table_inx)./total_counts_for_frame(table_inx);
    behavior_ratios_for_frame(:,table_inx)=behavior_ratios_for_frame(:,table_inx)/sum(behavior_ratios_for_frame(:,table_inx));
    end
end
transition_rate_for_frame = behavior_transition_counts_for_frame ./ repmat(total_counts_for_frame,number_of_behaviors,1) .*fps.*60;
end