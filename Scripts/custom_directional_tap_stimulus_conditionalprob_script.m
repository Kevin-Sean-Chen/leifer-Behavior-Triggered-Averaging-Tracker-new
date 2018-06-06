%not used in paper

load('reference_embedding.mat')
%load tracks
% relevant_track_fields = {'BehavioralTransition','Path','Frames','LEDPower','LEDVoltages','Embeddings','Velocity', 'LEDVoltage2Power'};
relevant_track_fields = {'BehavioralTransition','Frames'};

%select folders
%folders_platetap = getfoldersGUI();

%load stimuli.txt from the first experiment
num_stimuli = 1;
normalized_stimuli = 1; %delta function
time_window_before = 0;
time_window_after = 14;
fps = 14;

number_of_behaviors = max(L(:)-1);
all_edge_pairs = get_edge_pairs(number_of_behaviors);
number_of_edges = length(all_edge_pairs);
from_edges = all_edge_pairs(:,1);
rows_per_page = 9;

%% behavioral rate compare

allTracks = [];

for folder_index = 1:length(folders_platetap)
    %load the tracks for this folder
    [current_tracks, folder_indecies_revstim_ret, track_indecies_revstim_ret] = loadtracks(folders_platetap{folder_index},relevant_track_fields);
    current_tracks = BehavioralTransitionToBehavioralAnnotation(current_tracks);
    
    %generate the Behavior matricies
    current_tracks = get_directional_behavior_triggers(current_tracks);
    
    allTracks = [allTracks, current_tracks];
end

%for each experiment, search for the occurance of each stimulus after
%normalizing to 1
LEDVoltages = load([folders_platetap{folder_index}, filesep, 'LEDVoltages.txt']);
%LEDVoltages = LEDVoltages(randperm(length(LEDVoltages))); %optional, randomly permuate the taps
%LEDVoltages(LEDVoltages>0) = 1; %optional, make the stimulus on/off binary

%find when each stimuli is played back by convolving the time
%reversed stimulus (cross-correlation)
xcorr_ledvoltages_stimulus = padded_conv(LEDVoltages, normalized_stimuli);
peak_thresh = 0.99.*max(xcorr_ledvoltages_stimulus); %the peak threshold is 99% of the max (because edge effects)
[~, tap_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);

control_frame_shift = round((tap_frames(2)-tap_frames(1))/2); %the control taps are exactly in between taps
control_LEDVoltages = circshift(LEDVoltages,[0,control_frame_shift]);
xcorr_ledvoltages_stimulus = padded_conv(control_LEDVoltages, normalized_stimuli);
[~, control_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);


%% 1 plot the transition rates as a function of time
tap_behavior_transitions_for_frame = cell(1,time_window_before+time_window_after+1);
control_behavior_transitions_for_frame = cell(1,time_window_before+time_window_after+1);

for critical_frame_index = 1:length(tap_frames)
    %for every time a stimulus is delivered, look at a certain range of
    %frames
    
    %get tracks that last through the entire duration of the window
    tracks_within_critical_window = FilterTracksByTime(allTracks,tap_frames(critical_frame_index) - time_window_before, tap_frames(critical_frame_index) + time_window_after, true);
    for frame_shift = -time_window_before:time_window_after
        current_frame = tap_frames(critical_frame_index) + frame_shift;
        if current_frame <= length(LEDVoltages) && current_frame >= 1
            %make sure the current frame is in range
            tracks_on_critical_frame = FilterTracksByTime(tracks_within_critical_window,current_frame, current_frame);
            tap_behavior_transitions_for_frame{frame_shift+time_window_before+1} = [tap_behavior_transitions_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.Behaviors];
        end
    end
end

tap_transition_prob_for_frame = zeros(number_of_edges,length(tap_behavior_transitions_for_frame));
tap_transition_counts_for_frame = zeros(number_of_edges,length(tap_behavior_transitions_for_frame));
tap_transition_counts_for_condition_for_frame = zeros(number_of_edges,length(tap_behavior_transitions_for_frame));
tap_transition_std_for_frame = zeros(number_of_edges,length(tap_behavior_transitions_for_frame));
for frame_index = 1:length(tap_behavior_transitions_for_frame)
    for edge_index = 1:number_of_edges
        transitions_for_frame = tap_behavior_transitions_for_frame{frame_index};
        conditional_edges = find(from_edges == all_edge_pairs(edge_index,1));

        tap_transition_counts_for_frame(edge_index,frame_index) = sum(transitions_for_frame(edge_index,:),2); %transitions count conditioned on from and to
        tap_transition_counts_for_condition_for_frame(edge_index,frame_index) = sum(sum(transitions_for_frame(conditional_edges,:),1),2); %all transitions conditioned on from
        tap_transition_prob_for_frame(edge_index,frame_index) = tap_transition_counts_for_frame(edge_index,frame_index)./ tap_transition_counts_for_condition_for_frame(edge_index,frame_index);
        tap_transition_std_for_frame(edge_index,frame_index) = sqrt(tap_transition_counts_for_frame(edge_index,frame_index))./tap_transition_counts_for_condition_for_frame(edge_index,frame_index);
    end
end
tap_transition_counts_for_window = sum(tap_transition_counts_for_frame,2);
tap_transition_counts_for_condidition_for_window = sum(tap_transition_counts_for_condition_for_frame,2);
tap_transition_prob_for_window = tap_transition_counts_for_window ./ tap_transition_counts_for_condidition_for_window;
tap_transition_std_for_window = sqrt(tap_transition_counts_for_window) ./ tap_transition_counts_for_condidition_for_window;

for critical_frame_index = 1:length(control_frames)
    %for mock stimulus, look at a certain range of frames
    for frame_shift = -time_window_before:time_window_after
        current_frame = control_frames(critical_frame_index) + frame_shift;
        if current_frame <= length(LEDVoltages) && current_frame >= 1
            %make sure the current frame is in range
            tracks_on_critical_frame = FilterTracksByTime(allTracks,current_frame, current_frame);
            control_behavior_transitions_for_frame{frame_shift+time_window_before+1} = [control_behavior_transitions_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.Behaviors];
        end
    end
end


control_transition_prob_for_frame = zeros(number_of_edges,length(control_behavior_transitions_for_frame));
control_transition_counts_for_frame = zeros(number_of_edges,length(control_behavior_transitions_for_frame));
control_transition_counts_for_condition_for_frame = zeros(number_of_edges,length(control_behavior_transitions_for_frame));
control_transition_std_for_frame = zeros(number_of_edges,length(control_behavior_transitions_for_frame));
for frame_index = 1:length(control_behavior_transitions_for_frame)
    for edge_index = 1:number_of_edges
        transitions_for_frame = control_behavior_transitions_for_frame{frame_index};
        conditional_edges = find(from_edges == all_edge_pairs(edge_index,1));

        control_transition_counts_for_frame(edge_index,frame_index) = sum(transitions_for_frame(edge_index,:),2); %transitions count conditioned on from and to
        control_transition_counts_for_condition_for_frame(edge_index,frame_index) = sum(sum(transitions_for_frame(conditional_edges,:),1),2); %all transitions conditioned on from
        control_transition_prob_for_frame(edge_index,frame_index) = control_transition_counts_for_frame(edge_index,frame_index)./ control_transition_counts_for_condition_for_frame(edge_index,frame_index);
        control_transition_std_for_frame(edge_index,frame_index) = sqrt(control_transition_counts_for_frame(edge_index,frame_index))./control_transition_counts_for_condition_for_frame(edge_index,frame_index);
    end
end
control_transition_counts_for_window = sum(control_transition_counts_for_frame,2);
control_transition_counts_for_condition_for_window = sum(control_transition_counts_for_condition_for_frame,2);
control_transition_prob_for_window = control_transition_counts_for_window ./ control_transition_counts_for_condition_for_window;
control_transition_std_for_window = sqrt(control_transition_counts_for_window) ./ control_transition_counts_for_condition_for_window;

tap_track_n = round(mean(arrayfun(@(x) size(x{1},2), tap_behavior_transitions_for_frame)));
control_track_n = round(mean(arrayfun(@(x) size(x{1},2), control_behavior_transitions_for_frame)));


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

                title(['n=', num2str(control_transition_counts_for_window(edge_index)),', ',num2str(tap_transition_counts_for_window(edge_index))],'Color', 'k', 'FontWeight', 'normal', 'Fontsize', 14)
                box('off')
                set(gca,'XTick','')
                set(gca,'fontsize',14)
                axis([0 3 0 1]);
            end
        end
    end
end
