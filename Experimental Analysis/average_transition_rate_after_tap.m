function [tap_transition_rates,control_tap_transition_rates,h,p,ci,stats] = average_transition_rate_after_tap(folders_platetap, behavior_from, behavior_to)
% this function looks at the transition rates after a platetap and compares
% it to the control of the time point in between platetaps. If the
% behavior_from is 0, it is ignored
    load('reference_embedding.mat')
    %load tracks
    relevant_track_fields = {'BehavioralTransition','Frames'};

    %load stimuli.txt from the first experiment
    normalized_stimuli = 1; %delta function
    time_window_before = 0;
    time_window_after = 14; %transition rate average for 1 seconds after tap
    fps = 14;

    number_of_behaviors = max(L(:)-1);

    tap_transition_rates = [];
    control_tap_transition_rates = [];

    %% behavioral rate compare
    for folder_index = 1:length(folders_platetap)
        %for each experiment, search for the occurance of each stimulus after
        %normalizing to 1
        LEDVoltages = load([folders_platetap{folder_index}, filesep, 'LEDVoltages.txt']);
        % LEDVoltages = LEDVoltages(randperm(length(LEDVoltages))); %optional, randomly permuate the taps
        %LEDVoltages(LEDVoltages>0) = 1; %optional, make the stimulus on/off binary

        %find when each stimuli is played back by convolving the time
        %reversed stimulus (cross-correlation)
        xcorr_ledvoltages_stimulus = padded_conv(LEDVoltages, normalized_stimuli);
        peak_thresh = 0.99.*max(xcorr_ledvoltages_stimulus); %the peak threshold is 99% of the max (because edge effects)
        [~, tap_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);
        
        %generate a series of control taps
        control_frame_shift = round((tap_frames(2)-tap_frames(1))/2); %the control taps are exactly in between taps
        control_LEDVoltages = circshift(LEDVoltages,[0,control_frame_shift]);
        xcorr_ledvoltages_stimulus = padded_conv(control_LEDVoltages, normalized_stimuli);
        [~, control_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);
        
        %load the tracks for this folder
        [current_tracks, ~, ~] = loadtracks(folders_platetap(folder_index),relevant_track_fields);
        current_tracks = BehavioralTransitionToBehavioralAnnotation(current_tracks);

        %generate the Behavior matricies
        current_tracks = get_behavior_triggers(current_tracks);
        current_tracks(1).LocalFrameIndex = [];
        for track_index = 1:length(current_tracks)
            current_tracks(track_index).LocalFrameIndex = 1:length(current_tracks(track_index).Frames);
        end

        %get the transitions rates for tap condition
        behaviors_for_frame = cell(1,time_window_before+time_window_after+1);
        for critical_frame_index = 1:length(tap_frames)
            %for every time a stimulus is delivered, look at a certain range of
            %frames only if the track fits certain criteria
            current_critical_frame = tap_frames(critical_frame_index);
            if current_critical_frame + time_window_after <= length(LEDVoltages) && current_critical_frame - time_window_before >= 1
                %get tracks that last through the entire duration of the window
                tracks_within_critical_window = FilterTracksByTime(current_tracks,current_critical_frame - time_window_before, current_critical_frame + time_window_after, true);
                if ~isempty(tracks_within_critical_window)
                    tracks_on_current_critical_frame = FilterTracksByTime(tracks_within_critical_window,current_critical_frame, current_critical_frame);

                    %select the tracks that have the next behavior being behavior to
                    selected_indecies = false(1,length(tracks_within_critical_window));
                    for tracks_within_critical_window_index = 1:length(tracks_within_critical_window)
                        current_behavioral_transitions = tracks_on_current_critical_frame(tracks_within_critical_window_index).BehavioralTransition;
                        current_local_frame_index = [tracks_on_current_critical_frame(tracks_within_critical_window_index).LocalFrameIndex];
                        next_behavior = current_behavioral_transitions(find(current_behavioral_transitions(:,2)>current_local_frame_index,1,'first'),1);
                        if ~isempty(next_behavior) && next_behavior == behavior_to
                            selected_indecies(tracks_within_critical_window_index) = true;
                        end
                    end
                    BehavioralAnnotations = [tracks_on_current_critical_frame.BehavioralAnnotation];
                    if behavior_from > 0
                        selected_tracks = tracks_within_critical_window(and(selected_indecies,BehavioralAnnotations == behavior_from));
                    else
                        selected_tracks = tracks_within_critical_window(selected_indecies);
                    end
                    if ~isempty(selected_tracks)
                        for frame_shift = -time_window_before:time_window_after
                            current_frame = current_critical_frame + frame_shift;
                            tracks_on_critical_frame = FilterTracksByTime(selected_tracks,current_frame, current_frame);
                            behaviors_for_frame{frame_shift+time_window_before+1} = [behaviors_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.Behaviors];
                        end
                    end
                end
            end
        end
        if ~isempty(behaviors_for_frame{1})
            transition_rate_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
            transition_std_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
            for frame_index = 1:length(behaviors_for_frame)
                transitions_for_frame = behaviors_for_frame{frame_index};%horzcat(behaviors_for_frame{frame_index}.Behaviors);
                transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
                transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
            end
            % this is the average rate of transition for this particular pair
            mean_transition_rate_of_interest = mean(transition_rate_for_frame(behavior_to,:),2);
            tap_transition_rates = [tap_transition_rates,mean_transition_rate_of_interest];
        else
            tap_transition_rates = [tap_transition_rates,0];
        end
        
        %get the transitions rates for control condition
        behaviors_for_frame = cell(1,time_window_before+time_window_after+1);
        for critical_frame_index = 1:length(control_frames)
            %for every time a stimulus is delivered, look at a certain range of
            %frames only if the track fits certain criteria
            current_critical_frame = control_frames(critical_frame_index);
            if current_critical_frame + time_window_after <= length(LEDVoltages) && current_critical_frame - time_window_before >= 1
                %get tracks that last through the entire duration of the window
                tracks_within_critical_window = FilterTracksByTime(current_tracks,current_critical_frame - time_window_before, current_critical_frame + time_window_after, true);
                if ~isempty(tracks_within_critical_window)
                    tracks_on_current_critical_frame = FilterTracksByTime(tracks_within_critical_window,current_critical_frame, current_critical_frame);

                    %select the tracks that have the next behavior being behavior to
                    selected_indecies = false(1,length(tracks_within_critical_window));
                    for tracks_within_critical_window_index = 1:length(tracks_within_critical_window)
                        current_behavioral_transitions = tracks_on_current_critical_frame(tracks_within_critical_window_index).BehavioralTransition;
                        current_local_frame_index = [tracks_on_current_critical_frame(tracks_within_critical_window_index).LocalFrameIndex];
                        next_behavior = current_behavioral_transitions(find(current_behavioral_transitions(:,2)>current_local_frame_index,1,'first'),1);
                        if ~isempty(next_behavior) && next_behavior == behavior_to
                            selected_indecies(tracks_within_critical_window_index) = true;
                        end
                    end
                    BehavioralAnnotations = [tracks_on_current_critical_frame.BehavioralAnnotation];
                    if behavior_from > 0
                        selected_tracks = tracks_within_critical_window(and(selected_indecies,BehavioralAnnotations == behavior_from));
                    else
                        selected_tracks = tracks_within_critical_window(selected_indecies);
                    end
                    if ~isempty(selected_tracks)
                        for frame_shift = -time_window_before:time_window_after
                            current_frame = current_critical_frame + frame_shift;
                            tracks_on_critical_frame = FilterTracksByTime(selected_tracks,current_frame, current_frame);
                            behaviors_for_frame{frame_shift+time_window_before+1} = [behaviors_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.Behaviors];
                        end
                    end
                end
            end
        end
        if ~isempty(behaviors_for_frame{1})
            transition_rate_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
            transition_std_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
            for frame_index = 1:length(behaviors_for_frame)
                transitions_for_frame = behaviors_for_frame{frame_index};%horzcat(behaviors_for_frame{frame_index}.Behaviors);
                transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
                transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
            end
            % this is the average rate of transition for this particular pair
            mean_transition_rate_of_interest = mean(transition_rate_for_frame(behavior_to,:),2);
            control_tap_transition_rates = [control_tap_transition_rates,mean_transition_rate_of_interest];
        else
            control_tap_transition_rates = [control_tap_transition_rates,0];
        end
    end

    [h,p,ci,stats] = ttest2(tap_transition_rates, control_tap_transition_rates);
    if isnan(h)
        h = false;
        p = 0;
    end
%     %% plot the differences
%     %calculate the mean and std of the measured transition rates
%     mean_tap_transition_rates = mean(tap_transition_rates);
%     std_tap_transition_rates = std(tap_transition_rates);
%     mean_shuffled_tap_transition_rates = mean(control_tap_transition_rates);
%     std_shuffled_tap_transition_rates = std(control_tap_transition_rates);
% 
%     figure('Position', [0, 0, 200, 200]);
%     hold on
%     barwitherr([std_shuffled_tap_transition_rates; std_tap_transition_rates], [mean_shuffled_tap_transition_rates; mean_tap_transition_rates])
%     if h
%         sigstar({[1,2]},[p]);
%     end
%     
%     axis([0 3 0 40])
%     set(gca,'XTickLabel',{'','Control','Tap',''})
%     ylabel('Transition Rate (transitions/worm/min)')
% 
end

