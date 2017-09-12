load('reference_embedding.mat')
%load tracks
% relevant_track_fields = {'BehavioralTransition','Path','Frames','LEDPower','LEDVoltages','Embeddings','Velocity', 'LEDVoltage2Power'};
relevant_track_fields = {'BehavioralTransition','Frames'};

%select folders
folders_platetap = getfoldersGUI();

%load stimuli.txt from the first experiment
num_stimuli = 1;
normalized_stimuli = 1; %delta function
time_window_before = 140;
time_window_after = 140;
fps = 14;

number_of_behaviors = max(L(:)-1);


%% behavioral rate compare

allTracks = [];

for folder_index = 1:length(folders_platetap)
    %load the tracks for this folder
    [current_tracks, folder_indecies_revstim_ret, track_indecies_revstim_ret] = loadtracks(folders_platetap{folder_index},relevant_track_fields);
    current_tracks = BehavioralTransitionToBehavioralAnnotation(current_tracks);
    
    %generate the Behavior matricies
    current_tracks = get_behavior_triggers(current_tracks);
    
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
[~, critical_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);

%% 1 plot the transition rates as a function of time
behaviors_for_frame = cell(1,time_window_before+time_window_after+1);

for critical_frame_index = 1:length(critical_frames)
    %for every time a stimulus is delivered, look at a certain range of
    %frames
    for frame_shift = -time_window_before:time_window_after
        current_frame = critical_frames(critical_frame_index) + frame_shift;
        if current_frame <= length(LEDVoltages) && current_frame >= 1
            %make sure the current frame is in range
            tracks_on_critical_frame = FilterTracksByTime(allTracks,current_frame, current_frame);
            behaviors_for_frame{frame_shift+time_window_before+1} = [behaviors_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.Behaviors];
        end
    end
    
end

% plot the transition rates centered on stim delivery
transition_rate_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
transition_std_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
for frame_index = 1:length(behaviors_for_frame)
    transitions_for_frame = behaviors_for_frame{frame_index};%horzcat(behaviors_for_frame{frame_index}.Behaviors);
    transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
    transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
end

my_colors = lines(number_of_behaviors);
figure
hold on
for behavior_index = 1:number_of_behaviors
%     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]});
    plot(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]);
end
hold off
xlabel('Time (s)') % x-axis label
ylabel('Transition Rate (transitions/min)') % y-axis label
legend('show');
ax = gca;
ax.FontSize = 10;

%% 2 plot the behavioral ratios as a function of time
behaviors_for_frame = cell(1,time_window_before+time_window_after+1);

for critical_frame_index = 1:length(critical_frames)
    %for every time a stimulus is delivered, look at a certain range of
    %frames
    for frame_shift = -time_window_before:time_window_after
        current_frame = critical_frames(critical_frame_index) + frame_shift;
        if current_frame <= length(LEDVoltages) && current_frame >= 1
            %make sure the current frame is in range
            tracks_on_critical_frame = FilterTracksByTime(allTracks,current_frame, current_frame);
            behaviors_for_frame{frame_shift+time_window_before+1} = [behaviors_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.BehavioralAnnotation];
        end
    end
    
end

% plot the transition rates centered on stim delivery
behavior_counts_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
behavior_ratios_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));

total_counts_for_frame = zeros(1,length(behaviors_for_frame));
for frame_index = 1:length(behaviors_for_frame)
    for behavior_index = 1:number_of_behaviors
        behavior_counts_for_frame(behavior_index,frame_index) = sum(find(behaviors_for_frame{frame_index}==behavior_index));
    end
    behavior_ratios_for_frame(:,frame_index) = behavior_counts_for_frame(:,frame_index)./sum(behavior_counts_for_frame(:,frame_index)); %get ratio
end



my_colors = lines(number_of_behaviors);
figure
hold on
for behavior_index = 1:number_of_behaviors
%     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]});
    plot(-time_window_before/fps:1/fps:time_window_after/fps, behavior_ratios_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]);
end
hold off
xlabel('Time (s)') % x-axis label
ylabel('Behavioral Ratio') % y-axis label
legend('show');
ax = gca;
ax.FontSize = 10;

% %% 3 plot the transition rates as a function of time given the worm is a particular behavior at time 0
% behaviors_for_frame = cell(1,time_window_before+time_window_after+1);
% behavior_of_interest = 6;
% for critical_frame_index = 1:length(critical_frames)
%     %for every time a stimulus is delivered, look at a certain range of
%     %frames only if the track fits certain criteria
%     current_critical_frame = critical_frames(critical_frame_index);
%     if current_critical_frame + time_window_after <= length(LEDVoltages) && current_critical_frame - time_window_before >= 1
%         %get tracks that last through the entire duration of the window
%         tracks_within_critical_window = FilterTracksByTime(allTracks,current_critical_frame - time_window_before, current_critical_frame + time_window_after, true);
%         
%         tracks_on_current_critical_frame = FilterTracksByTime(tracks_within_critical_window,current_critical_frame, current_critical_frame);
%         BehavioralAnnotations = [tracks_on_current_critical_frame.BehavioralAnnotation];
%         
%         selected_tracks = tracks_within_critical_window(BehavioralAnnotations == behavior_of_interest);
%         
%         for frame_shift = -time_window_before:time_window_after
%             current_frame = current_critical_frame + frame_shift;
%             tracks_on_critical_frame = FilterTracksByTime(selected_tracks,current_frame, current_frame);
%             behaviors_for_frame{frame_shift+time_window_before+1} = [behaviors_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.Behaviors];
%         end
%     end
%     
%     
% end
% 
% % plot the transition rates centered on stim delivery
% transition_rate_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
% transition_std_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
% for frame_index = 1:length(behaviors_for_frame)
%     transitions_for_frame = behaviors_for_frame{frame_index};%horzcat(behaviors_for_frame{frame_index}.Behaviors);
%     transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
%     transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
% end
% 
% my_colors = lines(number_of_behaviors);
% figure
% hold on
% for behavior_index = 1:number_of_behaviors
% %     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]});
%     plot(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]);
% end
% hold off
% xlabel('Time (s)') % x-axis label
% ylabel('Transition Rate (transitions/min)') % y-axis label
% legend('show');
% ax = gca;
% ax.FontSize = 10;
% 
% 
% %% 4 plot the behavioral ratio as a function of time given the worm is a particular behavior at time 0
% behaviors_for_frame = cell(1,time_window_before+time_window_after+1);
% behavior_of_interest = 6;
% for critical_frame_index = 1:length(critical_frames)
%     %for every time a stimulus is delivered, look at a certain range of
%     %frames only if the track fits certain criteria
%     current_critical_frame = critical_frames(critical_frame_index);
%     if current_critical_frame + time_window_after <= length(LEDVoltages) && current_critical_frame - time_window_before >= 1
%         %get tracks that last through the entire duration of the window
%         tracks_within_critical_window = FilterTracksByTime(allTracks,current_critical_frame - time_window_before, current_critical_frame + time_window_after, true);
%         
%         tracks_on_current_critical_frame = FilterTracksByTime(tracks_within_critical_window,current_critical_frame, current_critical_frame);
%         BehavioralAnnotations = [tracks_on_current_critical_frame.BehavioralAnnotation];
%         
%         selected_tracks = tracks_within_critical_window(BehavioralAnnotations == behavior_of_interest);
%         
%         for frame_shift = -time_window_before:time_window_after
%             current_frame = current_critical_frame + frame_shift;
%             tracks_on_critical_frame = FilterTracksByTime(selected_tracks,current_frame, current_frame);
%             behaviors_for_frame{frame_shift+time_window_before+1} = [behaviors_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.BehavioralAnnotation];
%         end
%     end
%     
%     
% end
% 
% % plot the transition rates centered on stim delivery
% behavior_counts_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
% behavior_ratios_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
% 
% total_counts_for_frame = zeros(1,length(behaviors_for_frame));
% for frame_index = 1:length(behaviors_for_frame)
%     for behavior_index = 1:number_of_behaviors
%         behavior_counts_for_frame(behavior_index,frame_index) = sum(find(behaviors_for_frame{frame_index}==behavior_index));
%     end
%     behavior_ratios_for_frame(:,frame_index) = behavior_counts_for_frame(:,frame_index)./sum(behavior_counts_for_frame(:,frame_index)); %get ratio
% end
% 
% my_colors = lines(number_of_behaviors);
% figure
% hold on
% for behavior_index = 1:number_of_behaviors
% %     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]});
%     plot(-time_window_before/fps:1/fps:time_window_after/fps, behavior_ratios_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]);
% end
% hold off
% xlabel('Time (s)') % x-axis label
% ylabel('Behavioral Ratio') % y-axis label
% legend('show');
% ax = gca;
% ax.FontSize = 10;

%% 5 plot the transition rates as a function of time given the worm is a particular behavior immediately after the behavior at time 0
behaviors_for_frame = cell(1,time_window_before+time_window_after+1);
behavior_of_interest = 3;
for critical_frame_index = 1:length(critical_frames)
    %for every time a stimulus is delivered, look at a certain range of
    %frames only if the track fits certain criteria
    current_critical_frame = critical_frames(critical_frame_index);
    if current_critical_frame + time_window_after <= length(LEDVoltages) && current_critical_frame - time_window_before >= 1
        %get tracks that last through the entire duration of the window
        tracks_within_critical_window = FilterTracksByTime(allTracks,current_critical_frame - time_window_before, current_critical_frame + time_window_after, true);
        
        tracks_on_current_critical_frame = FilterTracksByTime(tracks_within_critical_window,current_critical_frame, current_critical_frame);
        
        %select the tracks that have the next behavior being the behavior
        %of interest
        selected_indecies = [];
        for tracks_within_critical_window_index = 1:length(tracks_within_critical_window)
            current_behavioral_transitions = tracks_on_current_critical_frame(tracks_within_critical_window_index).BehavioralTransition;
            current_local_frame_index = [tracks_on_current_critical_frame(tracks_within_critical_window_index).LocalFrameIndex];
            next_behavior = current_behavioral_transitions(find(current_behavioral_transitions(:,2)>current_local_frame_index,1,'first'),1);
            if ~isempty(next_behavior) && next_behavior == behavior_of_interest
                selected_indecies = [selected_indecies, tracks_within_critical_window_index];
            end
        end
        
        selected_tracks = tracks_within_critical_window(selected_indecies);
        
        for frame_shift = -time_window_before:time_window_after
            current_frame = current_critical_frame + frame_shift;
            tracks_on_critical_frame = FilterTracksByTime(selected_tracks,current_frame, current_frame);
            behaviors_for_frame{frame_shift+time_window_before+1} = [behaviors_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.Behaviors];
        end
    end
    
    
end

% plot the transition rates centered on stim delivery
transition_rate_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
transition_std_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
for frame_index = 1:length(behaviors_for_frame)
    transitions_for_frame = behaviors_for_frame{frame_index};%horzcat(behaviors_for_frame{frame_index}.Behaviors);
    transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
    transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
end

my_colors = lines(number_of_behaviors);
figure
hold on
for behavior_index = 1:number_of_behaviors
%     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]});
    plot(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]);
end
hold off
xlabel('Time (s)') % x-axis label
ylabel('Transition Rate (transitions/min)') % y-axis label
legend('show');
ax = gca;
ax.FontSize = 10;

%% 6 plot the behavioral ratio as a function of time given the worm is a particular behavior immediately after the behavior at time 0
behaviors_for_frame = cell(1,time_window_before+time_window_after+1);
behavior_of_interest = 9;
for critical_frame_index = 1:length(critical_frames)
    %for every time a stimulus is delivered, look at a certain range of
    %frames only if the track fits certain criteria
    current_critical_frame = critical_frames(critical_frame_index);
    if current_critical_frame + time_window_after <= length(LEDVoltages) && current_critical_frame - time_window_before >= 1
        %get tracks that last through the entire duration of the window
        tracks_within_critical_window = FilterTracksByTime(allTracks,current_critical_frame - time_window_before, current_critical_frame + time_window_after, true);
        
        tracks_on_current_critical_frame = FilterTracksByTime(tracks_within_critical_window,current_critical_frame, current_critical_frame);
        
        %select the tracks that have the next behavior being the behavior
        %of interest
        selected_indecies = [];
        for tracks_within_critical_window_index = 1:length(tracks_within_critical_window)
            current_behavioral_transitions = tracks_on_current_critical_frame(tracks_within_critical_window_index).BehavioralTransition;
            current_local_frame_index = [tracks_on_current_critical_frame(tracks_within_critical_window_index).LocalFrameIndex];
            next_behavior = current_behavioral_transitions(find(current_behavioral_transitions(:,2)>current_local_frame_index,1,'first'),1);
            if ~isempty(next_behavior) && next_behavior == behavior_of_interest
                selected_indecies = [selected_indecies, tracks_within_critical_window_index];
            end
        end
        
        selected_tracks = tracks_within_critical_window(selected_indecies);
        
        for frame_shift = -time_window_before:time_window_after
            current_frame = current_critical_frame + frame_shift;
            tracks_on_critical_frame = FilterTracksByTime(selected_tracks,current_frame, current_frame);
            behaviors_for_frame{frame_shift+time_window_before+1} = [behaviors_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.BehavioralAnnotation];
        end
    end
    
    
end

% plot the transition rates centered on stim delivery
behavior_counts_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
behavior_ratios_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));

total_counts_for_frame = zeros(1,length(behaviors_for_frame));
for frame_index = 1:length(behaviors_for_frame)
    for behavior_index = 1:number_of_behaviors
        behavior_counts_for_frame(behavior_index,frame_index) = sum(find(behaviors_for_frame{frame_index}==behavior_index));
    end
    behavior_ratios_for_frame(:,frame_index) = behavior_counts_for_frame(:,frame_index)./sum(behavior_counts_for_frame(:,frame_index)); %get ratio
end

my_colors = lines(number_of_behaviors);
figure
hold on
for behavior_index = 1:number_of_behaviors
%     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]});
    plot(-time_window_before/fps:1/fps:time_window_after/fps, behavior_ratios_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]);
end 
hold off
xlabel('Time (s)') % x-axis label
ylabel('Behavioral Ratio') % y-axis label
legend('show');
ax = gca;
ax.FontSize = 10;
