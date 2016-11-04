%calculate the triggers for LNP fitting based on velocity ranges

number_of_behaviors = 5;


allTracks(1).Behaviors = [];
for track_index = 1:length(allTracks)
    triggers = false(number_of_behaviors, length(allTracks(track_index).LEDVoltages)); %a binary array of when behaviors occur
    for behavior_index = 1:number_of_behaviors
        transition_indecies = allTracks(track_index).BehavioralTransition(:,1) == behavior_index;
        %transition into of
        transition_start_frames = allTracks(track_index).BehavioralTransition(transition_indecies,2);
        triggers(behavior_index,transition_start_frames) = true;
%                 %transition out of
%                 transition_end_frames = Tracks(track_index).BehavioralTransition(transition_indecies,3);
%                 triggers(behavior_index,transition_end_frames) = true;
    end
    allTracks(track_index).Behaviors = triggers(:,1:length(allTracks(track_index).LEDVoltages));
end