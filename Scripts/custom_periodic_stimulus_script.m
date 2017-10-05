auto_stimulus_period = true; %stimulus_period is found by autocorrelation if this is true
stimulus_period = 60*14-1; 

relevant_track_fields = {'BehavioralTransition','Frames'};

load('reference_embedding.mat')
load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\AML67\behavior_map_no_subsampling\Embedding_LNPFit\LNPfit.mat')

LNPStats = LNPStats_nondirectional_ret;

%select folders
%folders = getfoldersGUI();

normalized_stimuli = 1; %delta function
fps = 14;

number_of_behaviors = max(L(:)-1);
stimulus_templates = [];
all_behavior_transitions_for_frame = {};
all_behavior_annotations_for_frame = {};
predicted_behavior_transitions_for_stim = {};

%% behavioral rate compare
for folder_index = 1:length(folders)
    %load the tracks for this folder
    [current_tracks, folder_indecies_revstim_ret, track_indecies_revstim_ret] = loadtracks(folders{folder_index},relevant_track_fields);
    current_tracks = BehavioralTransitionToBehavioralAnnotation(current_tracks);
    %generate the Behavior matricies
    current_tracks = get_behavior_triggers(current_tracks);

    current_param = load_parameters(folders{folder_index});
    LEDVoltages = load([folders{folder_index}, filesep, 'LEDVoltages.txt']);
    
    %convert LEDVoltages to power
    LEDPowers = round(LEDVoltages .* current_param.avgPower500 ./ 5);

    experiment_behavior_predictions = zeros(number_of_behaviors,length(LEDPowers));
    %predict the behavioral rates based on the preloaded LNP model
    for behavior_index = 1:number_of_behaviors
        experiment_behavior_predictions(behavior_index,:) = PredictLNP(LEDPowers, LNPStats(behavior_index).linear_kernel, LNPStats(behavior_index).non_linearity_fit);
    end

    %cut the powers into chunks with the characteristic period
    if auto_stimulus_period
        %the stimulus_period is found by autocorrelation
        stim_autocorr = autocorr(LEDPowers,length(LEDPowers)-1);
        [~,stimulus_period] = findpeaks(stim_autocorr,'SortStr','descend','NPeaks',1);
        stimulus_period = stimulus_period-1;
        %do this only once
        auto_stimulus_period = false;
    else
        %the stimulus_period is predefined. use that
    end

    number_of_trials = floor(length(LEDPowers)/stimulus_period);
    LEDPowers_reshaped_by_trial = reshape(LEDPowers(1:stimulus_period*number_of_trials),stimulus_period,number_of_trials);
    
    %loop through the peaks and cut up tracks
    for trial_index = 1:number_of_trials
        %get the current stimulus
        current_stim = LEDPowers_reshaped_by_trial(:,trial_index)';
        %see if this stim_power already exists
        current_stim_index = is_approximate_member(current_stim,stimulus_templates);
        if current_stim_index == 0;
            %no entry yet
            stimulus_templates = [stimulus_templates;current_stim];
            current_stim_index = size(stimulus_templates,1);
            all_behavior_transitions_for_frame{current_stim_index} = cell(1,stimulus_period);
            all_behavior_annotations_for_frame{current_stim_index} = cell(1,stimulus_period);
        end
        
        %for every time a stimulus is delivered, look at a certain range of
        %frames
        for frame_shift = 1:stimulus_period
            current_frame = ((trial_index-1)*stimulus_period) + frame_shift;
            if current_frame <= length(LEDPowers) && current_frame >= 1
                %make sure the current frame is in range
                tracks_on_critical_frame = FilterTracksByTime(current_tracks,current_frame, current_frame);
                if ~isempty(tracks_on_critical_frame)
                    all_behavior_transitions_for_frame{current_stim_index}{frame_shift} = [all_behavior_transitions_for_frame{current_stim_index}{frame_shift}, tracks_on_critical_frame.Behaviors];
                    all_behavior_annotations_for_frame{current_stim_index}{frame_shift} = [all_behavior_annotations_for_frame{current_stim_index}{frame_shift}, tracks_on_critical_frame.BehavioralAnnotation];
                end
            end
        end
        %overwrite the last predicted behavioral response with this one, can replace with some sort of average if we want later
        predicted_behavior_transitions_for_stim{current_stim_index} = experiment_behavior_predictions(:,((trial_index-1)*stimulus_period)+1:trial_index*stimulus_period);
    end
end

%%sort the stimulus intensities
%[stimulus_templates, sort_index] = sort(stimulus_templates);
%all_behavior_transitions_for_frame = all_behavior_transitions_for_frame(sort_index);
%all_behavior_annotations_for_frame= all_behavior_annotations_for_frame(sort_index);

umber_of_stimulus_templates = size(stimulus_templates,1);
% 
% %% 1 plot the transition rates as a function of time
% for stimulus_index = 1:number_of_stimulus_templates
%     % plot the transition rates for each stimulus template
%     transition_rate_for_frame = zeros(number_of_behaviors,stimulus_period);
%     transition_std_for_frame = zeros(number_of_behaviors,stimulus_period);
%     for frame_index = 1:stimulus_period
%         transitions_for_frame = all_behavior_transitions_for_frame{stimulus_index}{frame_index};
%         transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
%         transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
%     end
% 
%     my_colors = lines(number_of_behaviors);
%     figure
%     hold on
%     for behavior_index = 1:number_of_behaviors
%         plot(1/fps:1/fps:stimulus_period/fps, transition_rate_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]);
%     end
%     hold off
%     xlabel('Time (s)') % x-axis label
%     ylabel('Transition Rate (transitions/min)') % y-axis label
%     title(['Stimulus Index = ', num2str(stimulus_index)]);
%     legend('show');
%     ax = gca;
%     ax.FontSize = 10;
% end
% 
% %% 2 plot the behavioral ratios as a function of time
% behavior_counts_for_frame = zeros(number_of_behaviors,number_of_stimulus_templates,stimulus_period);
% behavior_ratios_for_frame = zeros(number_of_behaviors,number_of_stimulus_templates,stimulus_period);
% 
% for stimulus_index = 1:number_of_stimulus_templates
%     % plot the transition rates centered on stim delivery
%     total_counts_for_frame = zeros(1,stimulus_period);
%     for frame_index = 1:stimulus_period
%         for behavior_index = 1:number_of_behaviors
%             behavior_counts_for_frame(behavior_index,stimulus_index,frame_index) = sum(find(all_behavior_annotations_for_frame{stimulus_index}{frame_index}==behavior_index));
%         end
%         behavior_ratios_for_frame(:,stimulus_index,frame_index) = behavior_counts_for_frame(:,stimulus_index,frame_index)./sum(behavior_counts_for_frame(:,stimulus_index,frame_index)); %get ratio
%     end
% end
% 
% for stimulus_index = 1:number_of_stimulus_templates
%     my_colors = lines(number_of_behaviors);
%     figure
%     hold on
%     for behavior_index = 1:number_of_behaviors
%         plot(1/fps:1/fps:stimulus_period/fps, squeeze(behavior_ratios_for_frame(behavior_index,stimulus_index,:)), '-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]);
%     end
%     hold off
%     xlabel('Time (s)') % x-axis label
%     ylabel('Behavioral Ratio') % y-axis label
%     title(['Stimulus Index = ', num2str(stimulus_index)]);
% 
%     legend('show');
%     ax = gca;
%     ax.FontSize = 10;
% end
% 
% %% plot the behavioral ratios for various intensities on the same plot
% for behavior_index = 1:number_of_behaviors
%     my_colors = lines(number_of_stimulus_templates);
%     figure
%     hold on
%     for stimulus_index = 1:number_of_stimulus_templates
%     %     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]});
%         plot(1/fps:1/fps:stimulus_period/fps, squeeze(behavior_ratios_for_frame(behavior_index,stimulus_index,:)), '-', 'color', my_colors(stimulus_index,:),'Linewidth', 1,'DisplayName',['Stimulus Index = ', num2str(stimulus_index)]);
%     end
%     hold off
%     xlabel('Time (s)') % x-axis label
%     ylabel('Behavioral Ratio') % y-axis label
%     title(['Behavior = ', num2str(behavior_index)]);
% 
%     legend('show');
%     ax = gca;
%     ax.FontSize = 10;
% end
% 
% %% plot the predicted transition rates
% for stimulus_index = 1:number_of_stimulus_templates
%     my_colors = lines(number_of_behaviors);
%     figure
%     hold on
%     for behavior_index = 1:number_of_behaviors
%         plot(1/fps:1/fps:stimulus_period/fps, predicted_behavior_transitions_for_stim{stimulus_index}(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 1,'DisplayName',['Behavior ', num2str(behavior_index)]);
%     end
%     hold off
%     xlabel('Time (s)') % x-axis label
%     ylabel('LNP Preidcted Transition Rate (transitions/min)') % y-axis label
%     title(['Stimulus Index = ', num2str(stimulus_index)]);
% 
%     legend('show');
%     ax = gca;
%     ax.FontSize = 10;
% end
% 
%% plot the stimlulus templates
figure
hold on
my_colors = lines(number_of_stimulus_templates);
for stimulus_index = 1:number_of_stimulus_templates
    plot(1/fps:1/fps:stimulus_period/fps, stimulus_templates(stimulus_index,:), '-', 'color', my_colors(stimulus_index,:),'Linewidth', 1,'DisplayName',['Stimulus ', num2str(stimulus_index)]);
end
hold off
xlabel('Time (s)') % x-axis label
ylabel('Stimulus Power (uW/mm2)') % y-axis label

legend('show');
ax = gca;
ax.FontSize = 10;
