auto_stimulus_period = true; %stimulus_period is found by autocorrelation if this is true
BTA_playback = false;
stimulus_period = 60*14-1; 
starting_shift = 0;
relevant_track_fields = {'BehavioralTransition','Frames'};

load('reference_embedding.mat')
%load('C:\Users\mochil\Dropbox\LeiferShaevitz\prelim data\Vibrations\GWN_10dutycycle_434Hz\GWN_10dutycycle_434Hz_nondirectional_LNPfit.mat')

LNPStats = LNPStats_nondirectional_ret;

%select folders
folders = getfoldersGUI();

fps = 14;

number_of_behaviors = max(L(:))-1;
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
    PWM_dutycycles = load([folders{folder_index}, filesep, 'PWM.txt']);

    dutycycles_for_finding_stimulus = PWM_dutycycles;
    
    experiment_behavior_predictions = zeros(number_of_behaviors,length(PWM_dutycycles));
    %predict the behavioral rates based on the preloaded LNP model
    for behavior_index = 1:number_of_behaviors
        experiment_behavior_predictions(behavior_index,:) = PredictLNP(PWM_dutycycles, LNPStats(behavior_index).linear_kernel, LNPStats(behavior_index).non_linearity_fit);
    end
    
    %cut the powers into chunks with the characteristic period
    if auto_stimulus_period
        %get the stimulus_period
        [stimulus_peak_intensities,stimulus_peaks] = findpeaks(dutycycles_for_finding_stimulus, 'minpeakdistance', 10*fps);
        stimulus_period = mode(diff(stimulus_peaks));
        
        %we also need to find the shift needed because we want to center
        %the stimulus in the middle of our time frame
        peak_index = 1;
        while peak_index>0
            starting_shift = stimulus_peaks(peak_index) - floor(stimulus_period/2);
            if starting_shift >= 0
                peak_index = 0;
            else
                peak_index = peak_index + 1;
            end
        end
        %do this only once assuming all our experiments are alike
        auto_stimulus_period = false;
    else
        %the stimulus_period is predefined. use that
    end

    number_of_trials = floor((length(PWM_dutycycles)-starting_shift)/stimulus_period);
    dutycycle_reshaped_by_trial = reshape(PWM_dutycycles(starting_shift+1:stimulus_period*number_of_trials+starting_shift),stimulus_period,number_of_trials);
    
    %loop through the peaks and cut up tracks
    for trial_index = 1:number_of_trials
        %get the current stimulus
        current_stim = dutycycle_reshaped_by_trial(:,trial_index)';
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
            current_frame = ((trial_index-1)*stimulus_period) + frame_shift + starting_shift;
            if current_frame <= length(PWM_dutycycles) && current_frame >= 1
                %make sure the current frame is in range
                tracks_on_critical_frame = FilterTracksByTime(current_tracks,current_frame, current_frame);
                if ~isempty(tracks_on_critical_frame)
                    all_behavior_transitions_for_frame{current_stim_index}{frame_shift} = [all_behavior_transitions_for_frame{current_stim_index}{frame_shift}, tracks_on_critical_frame.Behaviors];
                    all_behavior_annotations_for_frame{current_stim_index}{frame_shift} = [all_behavior_annotations_for_frame{current_stim_index}{frame_shift}, tracks_on_critical_frame.BehavioralAnnotation];
                end
            end
        %overwrite the last predicted behavioral response with this one, can replace with some sort of average if we want later
        predicted_behavior_transitions_for_stim{current_stim_index} = experiment_behavior_predictions(:,((trial_index-1)*stimulus_period)+starting_shift+1:trial_index*stimulus_period+starting_shift);
        end
    end
end
number_of_stimulus_templates = size(stimulus_templates,1);


%% 1 plot the transition rates as a function of time
for stimulus_index = 1:number_of_stimulus_templates
    % plot the transition rates for each stimulus template
    transition_rate_for_frame = zeros(number_of_behaviors,stimulus_period);
    transition_std_for_frame = zeros(number_of_behaviors,stimulus_period);
    for frame_index = 1:stimulus_period
        transitions_for_frame = all_behavior_transitions_for_frame{stimulus_index}{frame_index};
        transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
        transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
    end
    
    track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));
    my_colors = behavior_colors;
    figure
    hold on
    for behavior_index = 1:number_of_behaviors
        plot(1/fps:1/fps:stimulus_period/fps, transition_rate_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',behavior_names{behavior_index});
    end
    hold off
    xlabel('Time (s)') % x-axis label
    ylabel('Transition Rate (transitions/min)') % y-axis label
    title(['Stimulus Index = ', num2str(stimulus_index), ' (n = ', num2str(track_n), ')']);
    legend('show');
    ax = gca;
    ax.FontSize = 10;
end

%% 2 plot the behavioral ratios as a function of time
behavior_counts_for_frame = zeros(number_of_behaviors,number_of_stimulus_templates,stimulus_period);
behavior_ratios_for_frame = zeros(number_of_behaviors,number_of_stimulus_templates,stimulus_period);

for stimulus_index = 1:number_of_stimulus_templates
    % plot the transition rates centered on stim delivery
    total_counts_for_frame = zeros(1,stimulus_period);
    for frame_index = 1:stimulus_period
        for behavior_index = 1:number_of_behaviors
            behavior_counts_for_frame(behavior_index,stimulus_index,frame_index) = sum(all_behavior_annotations_for_frame{stimulus_index}{frame_index}==behavior_index);
        end
        behavior_ratios_for_frame(:,stimulus_index,frame_index) = behavior_counts_for_frame(:,stimulus_index,frame_index)./sum(behavior_counts_for_frame(:,stimulus_index,frame_index)); %get ratio
    end
end

for stimulus_index = 1:number_of_stimulus_templates
    my_colors = behavior_colors;
    figure
    hold on
    for behavior_index = 1:number_of_behaviors
        plot(1/fps:1/fps:stimulus_period/fps, squeeze(behavior_ratios_for_frame(behavior_index,stimulus_index,:)), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',behavior_names{behavior_index});
    end
    hold off
    xlabel('Time (s)') % x-axis label
    ylabel('Behavioral Ratio') % y-axis label
    if BTA_playback
        title([behavior_names{stimulus_to_behavior_key(stimulus_index)}, ' Kernel']);
    else
        title(['Stimulus Index = ', num2str(stimulus_index)]);
    end

    legend('show');
    ax = gca;
    ax.FontSize = 10;
end
% 
% %% plot the behavioral ratios for various intensities on the same plot
% for behavior_index = 1:number_of_behaviors
%     my_colors = lines(number_of_stimulus_templates);
%     figure
%     hold on
%     for stimulus_index = 1:number_of_stimulus_templates
%     %     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',['Behavior ', num2str(behavior_index)]});
%         plot(1/fps:1/fps:stimulus_period/fps, squeeze(behavior_ratios_for_frame(behavior_index,stimulus_index,:)), '-', 'color', my_colors(stimulus_index,:),'Linewidth', 3,'DisplayName',['Stimulus Index = ', num2str(stimulus_index)]);
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
%     my_colors = behavior_colors;
%     figure
%     hold on
%     for behavior_index = 1:number_of_behaviors
%         plot(1/fps:1/fps:stimulus_period/fps, predicted_behavior_transitions_for_stim{stimulus_index}(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',behavior_names{behavior_index});
%     end
%     hold off
%     xlabel('Time (s)') % x-axis label
%     ylabel('LNP Preidcted Transition Rate (transitions/min)') % y-axis label
%     if BTA_playback
%         title([behavior_names{stimulus_to_behavior_key(stimulus_index)}, ' Kernel']);
%     else
%         title(['Stimulus Index = ', num2str(stimulus_index)]);
%     end
%     legend('show');
%     ax = gca;
%     ax.FontSize = 10;
% end
% 
% %% plot the stimlulus templates
% figure
% hold on
% if BTA_playback
%     my_colors = behavior_colors(stimulus_to_behavior_key,:);
%     for stimulus_index = 1:number_of_stimulus_templates
%         plot(1/fps:1/fps:stimulus_period/fps, stimulus_templates(stimulus_index,:), '-', 'color', my_colors(stimulus_index,:),'Linewidth', 3,'DisplayName',[behavior_names{stimulus_to_behavior_key(stimulus_index)}, ' Kernel']);
%     end
% else
%     my_colors = lines(number_of_stimulus_templates);
%     for stimulus_index = 1:number_of_stimulus_templates
%         plot(1/fps:1/fps:stimulus_period/fps, stimulus_templates(stimulus_index,:), '-', 'color', my_colors(stimulus_index,:),'Linewidth', 3,'DisplayName',['Stimulus ', num2str(stimulus_index)]);
%     end
% end
% hold off
% xlabel('Time (s)') % x-axis label
% ylabel('Stimulus Power (uW/mm2)') % y-axis label
% 
% legend('show');
% ax = gca;
% ax.FontSize = 10;
% %% plot the predicted and actual behavior rates in the same graph
% if BTA_playback
%     %set plotting boundaries if we are doing the playback experiments
%     plotting_start = 30*fps+1;
%     plotting_end = 50*fps;
% else
%     plotting_start = 1;
%     plotting_end = stimulus_period;
% end
% plotting_period = plotting_end - plotting_start;
% 
% for stimulus_index = 1:number_of_stimulus_templates
%     figure
%    
%    %plot the stimulus
%     subplot(number_of_behaviors+3,1,1:3)
%     my_colors = behavior_colors(stimulus_to_behavior_key,:);
%     plot(0:1/fps:plotting_period/fps, stimulus_templates(stimulus_index,plotting_start:plotting_end), '-', 'color', my_colors(stimulus_index,:),'Linewidth', 3);
%     axis([0 20 0 50]);
%     set(gca, 'XTickLabels', {})
%     limits = get(gca,'YLim');
%     set(gca,'YTick',linspace(floor(limits(1)),ceil(limits(2)),3))
%     xlabel('') % x-axis label
%     
%     %plot the predicted and actual behavior rates in the same graph
%     subplot(number_of_behaviors+3,1,4:number_of_behaviors+1)
%     transition_rate_for_frame = zeros(number_of_behaviors,stimulus_period);
%     transition_std_for_frame = zeros(number_of_behaviors,stimulus_period);
%     for frame_index = 1:stimulus_period
%         transitions_for_frame = all_behavior_transitions_for_frame{stimulus_index}{frame_index};
%         transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
%         transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
%     end
%     
%     track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));
%     my_colors = behavior_colors;
%     hold on
%     for behavior_index = 1:number_of_behaviors
%         plot(0:1/fps:plotting_period/fps, transition_rate_for_frame(behavior_index,plotting_start:plotting_end) - mean(transition_rate_for_frame(behavior_index,plotting_start:plotting_end)) + double(behavior_index), '-', 'color', [my_colors(behavior_index,:), 0.5],'Linewidth', 2,'DisplayName',[behavior_names{behavior_index}, ' actual']);
%         plot(0:1/fps:plotting_period/fps, predicted_behavior_transitions_for_stim{stimulus_index}(behavior_index,plotting_start:plotting_end) - mean(predicted_behavior_transitions_for_stim{stimulus_index}(behavior_index,plotting_start:plotting_end)) + double(behavior_index), '-', 'color', my_colors(behavior_index,:),'Linewidth', 2,'DisplayName',[behavior_names{behavior_index}, ' predicted']);
%     end
%     hold off
%     xlabel('Time (s)') % x-axis label
%     ylabel('Transition Rate (transitions/min)') % y-axis label
%     if BTA_playback
%         title([behavior_names{stimulus_to_behavior_key(stimulus_index)}, ' Kernel']);       
%     else
%         title(['Stimulus Index = ', num2str(stimulus_index), ' (n = ', num2str(track_n), ')']);
%     end
%     axis([0 20 0 10]);
%     %legend('show');
%     ax = gca;
%     ax.FontSize = 10;
% end
% 


% %% compare base ratio and exp ratio
% if BTA_playback
%     baseline_start = 1;
%     baseline_end = 20*fps;
%     exp_start = 30*fps+1;
%     exp_end = 50*fps;
%     
%     for stimulus_index = 1:number_of_stimulus_templates
%         behavior_index = stimulus_to_behavior_key(stimulus_index);
%         transition_ratio_for_stim = squeeze(behavior_ratios_for_frame(behavior_index,stimulus_index,:))';
% 
%         track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));
%         my_colors = behavior_colors;
% 
%         %find the peak predicted rate in the experimental window
%         [~, baseline_mean, ~, ~, baseline_std, exp_mean, exp_std, p] = percent_change_above_baseline(transition_ratio_for_stim,baseline_start,baseline_end,exp_start,exp_end);
%         
%         %find the predicted baseline and experimental rates
%         
%         figure('pos',[0,0,300,200])
%         hold on
%         h = barwitherr([baseline_std; exp_std], [baseline_mean; exp_mean], 'linewidth',1);
%         set(h(1), 'FaceColor',behavior_colors(stimulus_to_behavior_key(stimulus_index),:));
%         
%         if p < 0.05
%             sigstar({[1,2]},0.05);
%         end
%         ax = gca;
%         ax.FontSize = 10;
% 
%         set(gca,'XTick',[1 2])
%         set(gca, 'XTickLabels', {'Baseline', 'LNP Peak'})
%         limits = get(gca,'YLim');
%         set(gca,'YTick',linspace(floor(limits(1)),ceil(limits(2)),3))
%         axis([0, 3, limits])
%         xlabel('') % x-axis label
%         ylabel('Behavioral Ratio') % y-axis label
%         title([behavior_names{stimulus_to_behavior_key(stimulus_index)}, ' (n = ', num2str(track_n), ')']);
%     end
% end
% 

%% non-directional playback or triangle wave to plot predicted vs actual transition rates timeseries and bars for time 0
spacing = 2; %in transitions/min

plotting_start = 1;
plotting_end = stimulus_period;
baseline_start = 1;
baseline_end = stimulus_period;
peak_window = 2*fps;
peak_predicted_rate_location = 15 * fps + 1;
plotting_period = plotting_end - plotting_start;
exp_start = peak_predicted_rate_location - (peak_window/2);
exp_end = peak_predicted_rate_location + (peak_window/2);

number_of_behaviors = double(max(L(:))-1);

for stimulus_index = 1:number_of_stimulus_templates
    figure('position', [0,0, 300 1000])
    
    transition_rate_for_frame = zeros(number_of_behaviors,stimulus_period);
    transition_counts_for_frame = zeros(number_of_behaviors,stimulus_period);
    transition_std_for_frame = zeros(number_of_behaviors,stimulus_period);
    for frame_index = 1:stimulus_period
        transitions_for_frame = all_behavior_transitions_for_frame{stimulus_index}{frame_index};
        transition_counts_for_frame(:,frame_index) = sum(transitions_for_frame,2);
        transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
        transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
    end
    track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));
   
   %plot the stimulus
    subplot(number_of_behaviors+4,1,1:2)
    my_colors = [0 0 0];
    hold on
    plot(0:1/fps:plotting_period/fps, stimulus_templates(stimulus_index,plotting_start:plotting_end), '-', 'color', my_colors(stimulus_index,:),'Linewidth', 3);
    hold off
    axis([0 20 0 10.1]);
    set(gca, 'XTickLabels', {})
    limits = get(gca,'YLim');
    set(gca,'YTick',linspace(floor(limits(1)),floor(limits(2)),3))
    xlabel(['trackn=', num2str(track_n)]) % x-axis label
    
    %plot the predicted and actual behavior rates timeseries
    subplot(number_of_behaviors+4,1,3:number_of_behaviors+1)
    my_colors = behavior_colors;

    %compute observed baseline rate
    observed_baseline_transition_rate = mean(transition_rate_for_frame(:,baseline_start:baseline_end),2);
    %compute predicted baseline rate
    predicted_baseline_transition_rate = mean(predicted_behavior_transitions_for_stim{stimulus_index}(:,baseline_start:baseline_end),2);
    %compute moving average observed rate
    observed_moving_average_transition_rate = movingmean(transition_rate_for_frame, peak_window, 2);
    %compute the baseline subtracted transition rate within the peak window
    observed_baseline_substrated_mean_peak_rate = observed_moving_average_transition_rate(:,peak_predicted_rate_location) - observed_baseline_transition_rate;
    %compute std within the window of peak
    observed_peak_transition_rate_sem = std(transition_rate_for_frame(:,exp_start:exp_end),[],2) ./ sqrt(peak_window);
    %compute the significance
    transition_rate_change_significance = false(1,number_of_behaviors);
    for behavior_index = 1:number_of_behaviors
        transition_rate_change_significance(behavior_index) = ttest(transition_rate_for_frame(behavior_index,exp_start:exp_end)-observed_baseline_transition_rate(behavior_index));
    end
    
    hold on
    for behavior_index = 1:number_of_behaviors
        %get the offset
        offset = -double(spacing*behavior_index);
        
        %plot the raw transition rate in grey
        plot(0:1/fps:plotting_period/fps, transition_rate_for_frame(behavior_index,plotting_start:plotting_end) - observed_baseline_transition_rate(behavior_index) + offset, '-', 'color', [my_colors(behavior_index,:) 0.25],'Linewidth', 2,'DisplayName',[behavior_names{behavior_index}, ' actual']);
        %plot the moving average transition rate in behavior color solid line
        plot(0:1/fps:plotting_period/fps, observed_moving_average_transition_rate(behavior_index,plotting_start:plotting_end) - observed_baseline_transition_rate(behavior_index) + offset, '-', 'color', my_colors(behavior_index,:) ,'Linewidth', 4,'DisplayName',[behavior_names{behavior_index}, ' moving average']);
        %plot the predicted transition rate in dashed black line
        plot(0:1/fps:plotting_period/fps, (predicted_behavior_transitions_for_stim{stimulus_index}(behavior_index,plotting_start:plotting_end) - predicted_baseline_transition_rate(behavior_index)).*1 + offset, '-', 'color', 'k', 'Linewidth', 2,'DisplayName',[behavior_names{behavior_index}, ' predicted']);
        %plot the zero line in dashed grey line
        plot(0:1/fps:plotting_period/fps, repmat(offset,1,plotting_period+1), '--', 'color', [0.4 0.4 0.4], 'Linewidth', 2,'DisplayName',[behavior_names{behavior_index}, ' zero']);
        %add the n
        text(0,offset-(spacing*0.5),['n=',num2str(sum(transition_counts_for_frame(behavior_index,plotting_start:plotting_end)))]);
    end
    hold off
    xlabel('Time (s)') % x-axis label
    ylabel('Transition Rate Change (transitions/min)') % y-axis label
    title(['Stimulus Index = ', num2str(stimulus_index), ' (n = ', num2str(track_n), ')']);
    axis([0, 20, -(spacing*number_of_behaviors+1), floor(spacing-1)]);
    %legend('show');
    ax = gca;
    ax.FontSize = 10;
    
end

