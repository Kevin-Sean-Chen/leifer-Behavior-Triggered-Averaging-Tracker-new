%not used in paper

load('reference_embedding.mat')

time_window_before = 69;
time_window_after = 69;

%load tracks
relevant_track_fields = {'BehavioralTransition','Path','Frames','LEDPower','LEDVoltages','Embeddings','Velocity', 'LEDVoltage2Power'};

%select folders
folders_revstim_ret = getfoldersGUI();

%load stimuli.txt from the first experiment
%stimuli = load([folders_revstim_ret{1}, filesep, 'stimuli.txt']);
stimuli = load('C:\Users\mochil\Dropbox\LeiferShaevitz\Github\leifer-Behavior-Triggered-Averaging-Tracker\triangle_stimlui_normalized.txt');

normalized_stimuli = stimuli;
num_stimuli = size(normalized_stimuli,1);
%normalize by the max for each stimulus
for stimulus_index = 1:num_stimuli
    normalized_stimuli(stimulus_index,:) = normalized_stimuli(stimulus_index,:) ./ max(normalized_stimuli(stimulus_index,:)) - 0.5;
end

%% behavioral rate compare
number_of_behaviors = max(L(:)-1);

behaviors_for_stim = cell(1,num_stimuli);
%allTracks_revstim_ret = [];
%for each experiment, search for the occurance of each stimulus after
%normalizing to 1
for folder_index = 1:length(folders_revstim_ret)
    %load the tracks for this folder
    [current_tracks, folder_indecies_revstim_ret, track_indecies_revstim_ret] = loadtracks(folders_revstim_ret,relevant_track_fields);
    current_tracks = BehavioralTransitionToBehavioralAnnotation(current_tracks);
    
    %generate the Behavior matricies
    current_tracks(1).Behaviors = [];
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
    end

    experiment_LEDVoltages = load([folders_revstim_ret{folder_index}, filesep, 'LEDVoltages.txt']);
    norm_experiment_LEDVoltages = experiment_LEDVoltages ./ max(experiment_LEDVoltages) - 0.5;
    for stimulus_index = 1:num_stimuli
        %find when each stimuli is played back by convolving the time
        %reversed stimulus (cross-correlation)
        xcorr_ledvoltages_stimulus = padded_conv(norm_experiment_LEDVoltages, fliplr(normalized_stimuli(stimulus_index,:)));
        peak_thresh = 0.99.*max(xcorr_ledvoltages_stimulus); %the peak threshold is 99% of the max (because edge effects)
        [~, critical_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);
        for critical_frame_index = 1:length(critical_frames)
            %cut up the tracks at the beginning and ends of timings
            tracks_on_critical_window = FilterTracksByTime(current_tracks,critical_frames(critical_frame_index)-time_window_before, ...
                critical_frames(critical_frame_index)+time_window_after);
            behaviors_for_stim{stimulus_index} = [behaviors_for_stim{stimulus_index}, tracks_on_critical_window.Behaviors];
        end
    end
%    allTracks_revstim_ret = [allTracks_revstim_ret, current_tracks];
end

% plot the transition rates
fps = 14;
% stim1_transition_binaries = horzcat(behaviors_for_stim{1}.Behaviors);
% stim2_transition_binaries = horzcat(behaviors_for_stim{2}.Behaviors);
% stim3_transition_binaries = horzcat(behaviors_for_stim{3}.Behaviors);
% stim4_transition_binaries = horzcat(behaviors_for_stim{4}.Behaviors);
stim1_transition_binaries = behaviors_for_stim{1};
stim2_transition_binaries = behaviors_for_stim{2};
stim3_transition_binaries = behaviors_for_stim{3};
stim4_transition_binaries = behaviors_for_stim{4};

stim1_behavior_frame_counts = sum(stim1_transition_binaries,2);
stim2_behavior_frame_counts = sum(stim2_transition_binaries,2);
stim3_behavior_frame_counts = sum(stim3_transition_binaries,2);
stim4_behavior_frame_counts = sum(stim4_transition_binaries,2);

stim1_total_frames = size(stim1_transition_binaries,2);
stim2_total_frames = size(stim2_transition_binaries,2);
stim3_total_frames = size(stim3_transition_binaries,2);
stim4_total_frames = size(stim4_transition_binaries,2);

stim1_behavioral_transition_rates = stim1_behavior_frame_counts./stim1_total_frames.*fps.*60; % in transitions/min
stim2_behavioral_transition_rates = stim2_behavior_frame_counts./stim2_total_frames.*fps.*60; % in transitions/min
stim3_behavioral_transition_rates = stim3_behavior_frame_counts./stim3_total_frames.*fps.*60; % in transitions/min
stim4_behavioral_transition_rates = stim4_behavior_frame_counts./stim4_total_frames.*fps.*60; % in transitions/min

stim1_behavioral_transition_rates_std = sqrt(stim1_behavior_frame_counts)./stim1_total_frames.*fps.*60;
stim2_behavioral_transition_rates_std = sqrt(stim2_behavior_frame_counts)./stim2_total_frames.*fps.*60;
stim3_behavioral_transition_rates_std = sqrt(stim3_behavior_frame_counts)./stim3_total_frames.*fps.*60;
stim4_behavioral_transition_rates_std = sqrt(stim4_behavior_frame_counts)./stim4_total_frames.*fps.*60;

stim1_predicted_behavioral_rates = zeros(1,number_of_behaviors);
stim2_predicted_behavioral_rates = zeros(1,number_of_behaviors);
stim3_predicted_behavioral_rates = zeros(1,number_of_behaviors);
stim4_predicted_behavioral_rates = zeros(1,number_of_behaviors);

%find the predicted rates of the 2 different stimuli by our GWN LNP models
for behavior_index = 1:number_of_behaviors
%     stim1_predicted_behavioral_rates(behavior_index) = PredictLNP(stimuli(1,:), LNPStats_nondirectional_ret(behavior_index).linear_kernel, ...
%         LNPStats_nondirectional_ret(behavior_index).non_linearity_fit,size(stimuli,2));
%     stim2_predicted_behavioral_rates(behavior_index) = PredictLNP(stimuli(2,:), LNPStats_nondirectional_ret(behavior_index).linear_kernel, ...
%         LNPStats_nondirectional_ret(behavior_index).non_linearity_fit,size(stimuli,2));
    stim1_predicted_rates = PredictLNP(stimuli(1,:), LNPStats_nondirectional_ret(behavior_index).linear_kernel, ...
        LNPStats_nondirectional_ret(behavior_index).non_linearity_fit,1);
    stim2_predicted_rates = PredictLNP(stimuli(2,:), LNPStats_nondirectional_ret(behavior_index).linear_kernel, ...
        LNPStats_nondirectional_ret(behavior_index).non_linearity_fit,1);
    stim3_predicted_rates = PredictLNP(stimuli(3,:), LNPStats_nondirectional_ret(behavior_index).linear_kernel, ...
        LNPStats_nondirectional_ret(behavior_index).non_linearity_fit,1);
    stim4_predicted_rates = PredictLNP(stimuli(4,:), LNPStats_nondirectional_ret(behavior_index).linear_kernel, ...
        LNPStats_nondirectional_ret(behavior_index).non_linearity_fit,1);
%     stim1_predicted_behavioral_rates(behavior_index) = stim1_predicted_rates(ceil(length(stim1_predicted_rates)./2));
%     stim2_predicted_behavioral_rates(behavior_index) = stim2_predicted_rates(ceil(length(stim1_predicted_rates)./2));
%     stim3_predicted_behavioral_rates(behavior_index) = stim3_predicted_rates(ceil(length(stim3_predicted_rates)./2));
%     stim4_predicted_behavioral_rates(behavior_index) = stim4_predicted_rates(ceil(length(stim4_predicted_rates)./2));
    stim1_predicted_behavioral_rates(behavior_index) = mean(stim1_predicted_rates);
    stim2_predicted_behavioral_rates(behavior_index) = mean(stim2_predicted_rates);
    stim3_predicted_behavioral_rates(behavior_index) = mean(stim3_predicted_rates);
    stim4_predicted_behavioral_rates(behavior_index) = mean(stim4_predicted_rates);
end


figure
hold on
errorbar(1:number_of_behaviors,stim1_behavioral_transition_rates,stim1_behavioral_transition_rates_std,'r.','linewidth',1,'markersize',10)
errorbar(1:number_of_behaviors,stim2_behavioral_transition_rates,stim2_behavioral_transition_rates_std,'b.','linewidth',1,'markersize',10)
errorbar(1:number_of_behaviors,stim3_behavioral_transition_rates,stim3_behavioral_transition_rates_std,'g.','linewidth',1,'markersize',10)
errorbar(1:number_of_behaviors,stim4_behavioral_transition_rates,stim4_behavioral_transition_rates_std,'m.','linewidth',1,'markersize',10)
plot(1:number_of_behaviors,stim1_predicted_behavioral_rates, 'ro');
plot(1:number_of_behaviors,stim2_predicted_behavioral_rates, 'bo');
plot(1:number_of_behaviors,stim3_predicted_behavioral_rates, 'go');
plot(1:number_of_behaviors,stim4_predicted_behavioral_rates, 'mo');

legend({'/\ actual', '\/ actual','/ actual', '\ actual', '/\ predicted', '\/ predicted', '/ predicted', '\ predicted'})
xlabel('Behavior Index')
ylabel('Transition Rate (transitions/min)')


