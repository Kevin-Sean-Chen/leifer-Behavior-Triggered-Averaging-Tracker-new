function [tap_transition_rates,shuffled_tap_transition_rates,h,p,ci,stats] = average_transition_rate_after_tap(folders_platetap, behavior_from, behavior_to)
%This function takes in 

    load('reference_embedding.mat')
    %load tracks
    relevant_track_fields = {'BehavioralTransition','Path','Frames','LEDPower','LEDVoltages','Embeddings','Velocity', 'LEDVoltage2Power'};

    %load stimuli.txt from the first experiment
    normalized_stimuli = 1; %delta function
    time_window_before = 0;
    time_window_after = 14; %transition rate average for 5 seconds after tap
    fps = 14;

    number_of_behaviors = max(L(:)-1);

    tap_transition_rates = [];
    shuffled_tap_transition_rates = [];

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
        [~, critical_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);

        %load the tracks for this folder
        [current_tracks, ~, ~] = loadtracks(folders_platetap(folder_index),relevant_track_fields);
        current_tracks = BehavioralTransitionToBehavioralAnnotation(current_tracks);

        %generate the Behavior matricies
        current_tracks(1).Behaviors = [];
        current_tracks(1).LocalFrameIndex = [];
        for track_index = 1:length(current_tracks)
            triggers = false(number_of_behaviors, length(current_tracks(track_index).Frames)); %a binary array of when behaviors occur
            for behavior_index = 1:number_of_behaviors
                transition_indecies = current_tracks(track_index).BehavioralTransition(:,1) == behavior_index;
                %transition into of
                transition_start_frames = current_tracks(track_index).BehavioralTransition(transition_indecies,2);
                triggers(behavior_index,transition_start_frames) = true;
        %                 %transition out of
        %                 transition_end_frames = Tracks(track_index).BehavioralTransition(transition_indecies,3);
        %                 triggers(behavior_index,transition_end_frames) = true;
            end
            current_tracks(track_index).Behaviors = triggers(:,1:length(current_tracks(track_index).LEDVoltages));
            current_tracks(track_index).LocalFrameIndex = 1:length(current_tracks(track_index).LEDVoltages);

        end

        behaviors_for_frame = cell(1,time_window_before+time_window_after+1);
        for critical_frame_index = 1:length(critical_frames)
            %for every time a stimulus is delivered, look at a certain range of
            %frames only if the track fits certain criteria
            current_critical_frame = critical_frames(critical_frame_index);
            if current_critical_frame + time_window_after <= length(LEDVoltages) && current_critical_frame - time_window_before >= 1
                %get tracks that last through the entire duration of the window
                tracks_within_critical_window = FilterTracksByTime(current_tracks,current_critical_frame - time_window_before, current_critical_frame + time_window_after, true);

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
                selected_tracks = tracks_within_critical_window(and(selected_indecies,BehavioralAnnotations == behavior_from));
                if ~isempty(selected_tracks)
                    for frame_shift = -time_window_before:time_window_after
                        current_frame = current_critical_frame + frame_shift;
                        tracks_on_critical_frame = FilterTracksByTime(selected_tracks,current_frame, current_frame);
                        behaviors_for_frame{frame_shift+time_window_before+1} = [behaviors_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.Behaviors];
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
    end


    %% behavioral rate compare for shuffled tap
    current_tracks = [];
    for folder_index = 1:length(folders_platetap)
        %for each experiment, search for the occurance of each stimulus after
        %normalizing to 1
        LEDVoltages = load([folders_platetap{folder_index}, filesep, 'LEDVoltages.txt']);
        LEDVoltages = LEDVoltages(randperm(length(LEDVoltages))); %optional, randomly permuate the taps
        %LEDVoltages(LEDVoltages>0) = 1; %optional, make the stimulus on/off binary

        %find when each stimuli is played back by convolving the time
        %reversed stimulus (cross-correlation)
        xcorr_ledvoltages_stimulus = padded_conv(LEDVoltages, normalized_stimuli);
        peak_thresh = 0.99.*max(xcorr_ledvoltages_stimulus); %the peak threshold is 99% of the max (because edge effects)
        [~, critical_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);

        %load the tracks for this folder
        [current_tracks, ~, ~] = loadtracks(folders_platetap(folder_index),relevant_track_fields);
        current_tracks = BehavioralTransitionToBehavioralAnnotation(current_tracks);

        %generate the Behavior matricies
        current_tracks(1).Behaviors = [];
        current_tracks(1).LocalFrameIndex = [];
        for track_index = 1:length(current_tracks)
            triggers = false(number_of_behaviors, length(current_tracks(track_index).Frames)); %a binary array of when behaviors occur
            for behavior_index = 1:number_of_behaviors
                transition_indecies = current_tracks(track_index).BehavioralTransition(:,1) == behavior_index;
                %transition into of
                transition_start_frames = current_tracks(track_index).BehavioralTransition(transition_indecies,2);
                triggers(behavior_index,transition_start_frames) = true;
        %                 %transition out of
        %                 transition_end_frames = Tracks(track_index).BehavioralTransition(transition_indecies,3);
        %                 triggers(behavior_index,transition_end_frames) = true;
            end
            current_tracks(track_index).Behaviors = triggers(:,1:length(current_tracks(track_index).LEDVoltages));
            current_tracks(track_index).LocalFrameIndex = 1:length(current_tracks(track_index).LEDVoltages);

        end
        current_tracks = current_tracks;

        behaviors_for_frame = cell(1,time_window_before+time_window_after+1);
        for critical_frame_index = 1:length(critical_frames)
            %for every time a stimulus is delivered, look at a certain range of
            %frames only if the track fits certain criteria
            current_critical_frame = critical_frames(critical_frame_index);
            if current_critical_frame + time_window_after <= length(LEDVoltages) && current_critical_frame - time_window_before >= 1
                %get tracks that last through the entire duration of the window
                tracks_within_critical_window = FilterTracksByTime(current_tracks,current_critical_frame - time_window_before, current_critical_frame + time_window_after, true);

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
                selected_tracks = tracks_within_critical_window(and(selected_indecies,BehavioralAnnotations == behavior_from));
                if ~isempty(selected_tracks)
                    for frame_shift = -time_window_before:time_window_after
                        current_frame = current_critical_frame + frame_shift;
                        tracks_on_critical_frame = FilterTracksByTime(selected_tracks,current_frame, current_frame);
                        behaviors_for_frame{frame_shift+time_window_before+1} = [behaviors_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.Behaviors];
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
            shuffled_tap_transition_rates = [shuffled_tap_transition_rates,mean_transition_rate_of_interest];
        else
            shuffled_tap_transition_rates = [shuffled_tap_transition_rates,0];
        end
    end

    [h,p,ci,stats] = ttest2(tap_transition_rates, shuffled_tap_transition_rates);
    if isnan(h)
        h = false;
        p = 0;
    end
    %% plot the differences
    %calculate the mean and std of the measured transition rates
    mean_tap_transition_rates = mean(tap_transition_rates);
    std_tap_transition_rates = std(tap_transition_rates);
    mean_shuffled_tap_transition_rates = mean(shuffled_tap_transition_rates);
    std_shuffled_tap_transition_rates = std(shuffled_tap_transition_rates);

    figure('Position', [0, 0, 200, 200]);
    hold on
    barwitherr([std_shuffled_tap_transition_rates; std_tap_transition_rates], [mean_shuffled_tap_transition_rates; mean_tap_transition_rates])
    if h
        sigstar({[1,2]},[p]);
    end
    
    axis([0 3 0 40])
    set(gca,'XTickLabel',{'','Control','Tap',''})
    ylabel('Transition Rate (transitions/worm/min)')

end

