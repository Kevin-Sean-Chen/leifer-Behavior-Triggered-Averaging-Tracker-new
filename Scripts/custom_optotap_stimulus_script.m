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
total_window_frames = time_window_before+time_window_after+1;
fps = 14;

number_of_behaviors = max(L(:)-1);
stimulus_intensities = [];
all_behavior_transitions_for_frame = {};
all_behavior_annotations_for_frame = {};

%% behavioral rate compare
for folder_index = 1:length(folders_platetap)
    %load the tracks for this folder
    [current_tracks, folder_indecies_revstim_ret, track_indecies_revstim_ret] = loadtracks(folders_platetap{folder_index},relevant_track_fields);
    current_tracks = BehavioralTransitionToBehavioralAnnotation(current_tracks);
    %generate the Behavior matricies
    current_tracks = get_behavior_triggers(current_tracks);

    current_param = load_parameters(folders_platetap{folder_index});
    LEDVoltages = load([folders_platetap{folder_index}, filesep, 'LEDVoltages.txt']);
    
    %convert LEDVoltages to power
    LEDPowers = round(LEDVoltages .* current_param.avgPower500 ./ 5);
    
    %find when each stimuli is played back by convolving the time
    %reversed stimulus (cross-correlation)
    xcorr_ledvoltages_stimulus = padded_conv(LEDPowers, normalized_stimuli);
    [peak_magnitudes, peak_locations] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakDistance',14);
    
    %loop through the peaks and cut up tracks
    for peak_index = 1:length(peak_locations)
        %get the stimulus intensity for this peak
        current_stim_power = LEDPowers(peak_locations(peak_index));
        %see if this stim_power already exists
        current_stim_index = find(stimulus_intensities == current_stim_power);
        if isempty(current_stim_index)
            %no entry yet
            stimulus_intensities = [stimulus_intensities,current_stim_power];
            current_stim_index = length(stimulus_intensities);
            all_behavior_transitions_for_frame{current_stim_index} = cell(1,total_window_frames);
            all_behavior_annotations_for_frame{current_stim_index} = cell(1,total_window_frames);
        end
        
        %for every time a stimulus is delivered, look at a certain range of
        %frames
        for frame_shift = -time_window_before:time_window_after
            current_frame = peak_locations(peak_index) + frame_shift;
            if current_frame <= length(LEDPowers) && current_frame >= 1
                %make sure the current frame is in range
                tracks_on_critical_frame = FilterTracksByTime(current_tracks,current_frame, current_frame);
                all_behavior_transitions_for_frame{current_stim_index}{frame_shift+time_window_before+1} = [all_behavior_transitions_for_frame{current_stim_index}{frame_shift+time_window_before+1}, tracks_on_critical_frame.Behaviors];
                all_behavior_annotations_for_frame{current_stim_index}{frame_shift+time_window_before+1} = [all_behavior_annotations_for_frame{current_stim_index}{frame_shift+time_window_before+1}, tracks_on_critical_frame.BehavioralAnnotation];
            end
        end
    end
end

%sort the stimulus intensities
[stimulus_intensities, sort_index] = sort(stimulus_intensities);
all_behavior_transitions_for_frame = all_behavior_transitions_for_frame(sort_index);
all_behavior_annotations_for_frame= all_behavior_annotations_for_frame(sort_index);

%% 1 plot the transition rates as a function of time
for stimulus_index = 1:length(stimulus_intensities)
    % plot the transition rates centered on stim delivery
    transition_rate_for_frame = zeros(number_of_behaviors,total_window_frames);
    transition_std_for_frame = zeros(number_of_behaviors,total_window_frames);
    for frame_index = 1:total_window_frames
        transitions_for_frame = all_behavior_transitions_for_frame{stimulus_index}{frame_index};
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
    title(['Stimulus Intensity = ', num2str(stimulus_intensities(stimulus_index))]);
    legend('show');
    ax = gca;
    ax.FontSize = 10;
end
%% 2 plot the behavioral ratios as a function of time
behavior_counts_for_frame = zeros(number_of_behaviors,length(stimulus_intensities),total_window_frames);
behavior_ratios_for_frame = zeros(number_of_behaviors,length(stimulus_intensities),total_window_frames);

for stimulus_index = 1:length(stimulus_intensities)
    % plot the transition rates centered on stim delivery
    total_counts_for_frame = zeros(1,total_window_frames);
    for frame_index = 1:total_window_frames
        for behavior_index = 1:number_of_behaviors
            behavior_counts_for_frame(behavior_index,stimulus_index,frame_index) = sum(find(all_behavior_annotations_for_frame{stimulus_index}{frame_index}==behavior_index));
        end
        behavior_ratios_for_frame(:,stimulus_index,frame_index) = behavior_counts_for_frame(:,stimulus_index,frame_index)./sum(behavior_counts_for_frame(:,stimulus_index,frame_index)); %get ratio
    end
end

for stimulus_index = 1:length(stimulus_intensities)
    my_colors = lines(number_of_behaviors);
    figure
    hold on
    for behavior_index = 1:number_of_behaviors
    %     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]});
        plot(-time_window_before/fps:1/fps:time_window_after/fps, squeeze(behavior_ratios_for_frame(behavior_index,stimulus_index,:)), '-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]);
    end
    hold off
    xlabel('Time (s)') % x-axis label
    ylabel('Behavioral Ratio') % y-axis label
    title(['Stimulus Intensity = ', num2str(stimulus_intensities(stimulus_index))]);

    legend('show');
    ax = gca;
    ax.FontSize = 10;
end

%% plot the behavioral ratios for various intensities on the same plot
for behavior_index = 1:number_of_behaviors
    my_colors = lines(length(stimulus_intensities));
    figure
    hold on
    for stimulus_index = 1:length(stimulus_intensities)
    %     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]});
        plot(-time_window_before/fps:1/fps:time_window_after/fps, squeeze(behavior_ratios_for_frame(behavior_index,stimulus_index,:)), '-', 'color', my_colors(stimulus_index,:),'Linewidth', 1,'DisplayName',[num2str(stimulus_intensities(stimulus_index)), 'uW/mm2']);
    end
    hold off
    xlabel('Time (s)') % x-axis label
    ylabel('Behavioral Ratio') % y-axis label
    title(['Behavior = ', num2str(behavior_index)]);

    legend('show');
    ax = gca;
    ax.FontSize = 10;
end
