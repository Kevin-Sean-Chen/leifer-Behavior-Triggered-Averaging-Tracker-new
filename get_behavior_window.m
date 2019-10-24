function [behavior_ratios_for_frame,transition_rate_for_frame]=get_behavior_window(tracks,time_before,time_after)
% apply this only after aligning the tracks with sti (with frames like -140:140)
if nargin<2
    time_before=10;
    time_after=10;
end
number_of_behaviors=9;
fps=14;
window_length=fps*(time_before+time_after)+1; %281
behavior_counts_for_frame = zeros(number_of_behaviors,window_length);
behavior_transition_counts_for_frame = zeros(number_of_behaviors,window_length);
behavior_ratios_for_frame = zeros(number_of_behaviors,window_length);
total_counts_for_frame = zeros(1,window_length);

for table_inx = 1:window_length
    frame_inx=table_inx-fps*time_before-1; % should start with -140
    tracks_on_critical_frame = FilterTracksByTime(tracks, frame_inx, frame_inx);
    if ~isempty( tracks_on_critical_frame)
        behavior_annotations_for_frame = [tracks_on_critical_frame.BehavioralAnnotation];
        behavior_transitions_for_frame = [tracks_on_critical_frame.Behaviors];       
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