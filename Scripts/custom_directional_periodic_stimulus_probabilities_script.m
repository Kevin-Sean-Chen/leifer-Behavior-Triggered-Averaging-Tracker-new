auto_stimulus_period = true; %stimulus_period is found by autocorrelation if this is true
BTA_playback = true;
stimulus_period = 60*14-1; 
starting_shift = 0;
relevant_track_fields = {'BehavioralTransition','Frames'};

load('reference_embedding.mat')
load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\AML67\behavior_map_no_subsampling\Embedding_LNPFit\LNPfit_behaviors_reordered_20171030.mat')

LNPStats = LNPStats_directional_ret;

%select folders
folders = getfoldersGUI();

fps = 14;

number_of_edges = length(LNPStats);
stimulus_templates = [];
all_behavior_transitions_for_frame = {};
predicted_behavior_transitions_for_stim = {};

%% behavioral rate compare
for folder_index = 1:length(folders)
    %load the tracks for this folder
    [current_tracks, folder_indecies_revstim_ret, track_indecies_revstim_ret] = loadtracks(folders{folder_index},relevant_track_fields);
    current_tracks = BehavioralTransitionToBehavioralAnnotation(current_tracks);
    %generate the Behavior matricies
    current_tracks = get_directional_behavior_triggers(current_tracks);

    current_param = load_parameters(folders{folder_index});
    LEDVoltages = load([folders{folder_index}, filesep, 'LEDVoltages.txt']);
    
    %convert LEDVoltages to power
    LEDPowers = LEDVoltages .* current_param.avgPower500 ./ 5;

    if BTA_playback
        % anything different from the baseline we will treat as a stimulus
        % delivery
        baseline_indecies = LEDPowers == mode(LEDPowers);
        LEDPowers_for_finding_stimulus = ones(1,length(LEDPowers));
        LEDPowers_for_finding_stimulus(baseline_indecies) = 0;
    else
        %round it
        LEDPowers_for_finding_stimulus = LEDPowers;
    end
    
    experiment_behavior_predictions = zeros(number_of_edges,length(LEDPowers));
    %predict the behavioral rates based on the preloaded LNP model
    for transition_index = 1:number_of_edges
        experiment_behavior_predictions(transition_index,:) = PredictLNP(LEDPowers, LNPStats(transition_index).linear_kernel, LNPStats(transition_index).non_linearity_fit);
    end

    %cut the powers into chunks with the characteristic period
    if auto_stimulus_period
        %get the stimulus_period
        [stimulus_peak_intensities,stimulus_peaks] = findpeaks(LEDPowers_for_finding_stimulus, 'minpeakdistance', 10*fps);
        stimulus_period = mode(diff(stimulus_peaks));
        
        %we also need to find the shift needed because we want to center
        %the stimulus in the middle of our time frame
        peak_index = 1;
        while peak_index>0
            starting_shift = stimulus_peaks(peak_index) - floor(stimulus_period/2);
            if starting_shift > 0
                peak_index = 0;
            end
        end
        %do this only once assuming all our experiments are alike
        auto_stimulus_period = false;
    else
        %the stimulus_period is predefined. use that
    end

    number_of_trials = floor((length(LEDPowers)-starting_shift)/stimulus_period);
    LEDPowers_reshaped_by_trial = reshape(LEDPowers(starting_shift+1:stimulus_period*number_of_trials+starting_shift),stimulus_period,number_of_trials);
    
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
        end
        
        %for every time a stimulus is delivered, look at a certain range of
        %frames
        for frame_shift = 1:stimulus_period
            current_frame = ((trial_index-1)*stimulus_period) + frame_shift + starting_shift;
            if current_frame <= length(LEDPowers) && current_frame >= 1
                %make sure the current frame is in range
                tracks_on_critical_frame = FilterTracksByTime(current_tracks,current_frame, current_frame);
                if ~isempty(tracks_on_critical_frame)
                    all_behavior_transitions_for_frame{current_stim_index}{frame_shift} = [all_behavior_transitions_for_frame{current_stim_index}{frame_shift}, tracks_on_critical_frame.Behaviors];
                end
            end
        end
        %overwrite the last predicted behavioral response with this one, can replace with some sort of average if we want later
        predicted_behavior_transitions_for_stim{current_stim_index} = experiment_behavior_predictions(:,((trial_index-1)*stimulus_period)+starting_shift+1:trial_index*stimulus_period+starting_shift);
    end
end
number_of_stimulus_templates = size(stimulus_templates,1);

%% sort the stimulus intensities if we are in playback mode
% [stimulus_templates, sort_index] = sort(stimulus_templates);
if BTA_playback
    %find the stimulus amoung the kernels we have
    avg_power = 25;
    stimulus_to_behavior_key = [];
    significant_behaviors = [];
    for stimulus_index = 1:number_of_stimulus_templates
        for transition_index = 1:length(LNPStats_nondirectional_ret)
            %scale the linear kernel appropriately
            if ~all(LNPStats_nondirectional_ret(transition_index).linear_kernel == 0)
                stimulus_max = max(abs(LNPStats_nondirectional_ret(transition_index).linear_kernel));
                scale = avg_power ./ stimulus_max;
                kernel_stimulus = scale .* LNPStats_nondirectional_ret(transition_index).linear_kernel;
                kernel_stimulus = fliplr(kernel_stimulus + avg_power);
                stim_mode = mode(stimulus_templates(stimulus_index,:));
                stim_start = find(stimulus_templates(stimulus_index,:) ~= stim_mode, 1);
                kernel_stimulus = [repmat(stim_mode,1,stim_start-1), kernel_stimulus]; %pad it left
                kernel_stimulus = [kernel_stimulus, repmat(stim_mode,1,length(stimulus_templates(stimulus_index,:))-length(kernel_stimulus))]; %pad it right
                if is_approximate_member(stimulus_templates(stimulus_index,:), kernel_stimulus, 0.04)
                    break
                end
            end
        end
        stimulus_to_behavior_key = [stimulus_to_behavior_key, transition_index];
    end
    
    [stimulus_to_behavior_key, sort_index] = sort(stimulus_to_behavior_key);
    stimulus_templates = stimulus_templates(sort_index,:);
    all_behavior_transitions_for_frame = all_behavior_transitions_for_frame(sort_index);
    predicted_behavior_transitions_for_stim = predicted_behavior_transitions_for_stim(sort_index);
else
    stimulus_to_behavior_key = 1:number_of_stimulus_templates;
end


%% directional playback or triangle wave to plot predicted vs actual transition probabilities timeseries and bars for time 0
% selected_transitions = {[3,4], [4,5], [5,6], [4,3], [5,4], [6,5]};
selected_transitions = {[4,5], [6,5]};
if BTA_playback
    plotting_start = 30*fps+1;
    plotting_end = 50*fps;
    baseline_start = 5*fps+1;
    baseline_end = 25*fps;
    peak_window = 2*fps;
    peak_predicted_rate_location = 40 * fps;
else
    plotting_start = 1;
    plotting_end = stimulus_period;
    baseline_start = 1;
    baseline_end = stimulus_period;
    peak_window = 10*fps;
    peak_predicted_rate_location = 5 * fps + 1;
end
plotting_period = plotting_end - plotting_start;
exp_start = peak_predicted_rate_location - (peak_window/2);
exp_end = peak_predicted_rate_location + (peak_window/2);
spacing = 1.5;
number_of_behaviors = double(max(L(:))-1);
all_edge_pairs = get_edge_pairs(number_of_behaviors);
from_edges = all_edge_pairs(:,1);

for stimulus_index = 1:number_of_stimulus_templates
    figure('position', [0,0, 250 1000])
   
   %plot the stimulus
    subplot(length(selected_transitions)+4,1,1:2)
    hold on
    rectangle('Position', [(exp_start-plotting_start+1)/fps 0 peak_window/fps 50.1], 'FaceColor',[0.75 .75 .75]);
    if BTA_playback
        my_colors = behavior_colors(stimulus_to_behavior_key,:);
        plot(0:1/fps:plotting_period/fps, stimulus_templates(stimulus_index,plotting_start:plotting_end), '-', 'color', my_colors(stimulus_index,:),'Linewidth', 3);
    else
        plot(0:1/fps:plotting_period/fps, stimulus_templates(stimulus_index,plotting_start:plotting_end), '-', 'color', 'b','Linewidth', 3);
    end
    hold off
    axis([0 20 0 50.1]);
    set(gca, 'XTickLabels', {})
    limits = get(gca,'YLim');
    set(gca,'YTick',linspace(floor(limits(1)),floor(limits(2)),3))
    xlabel('') % x-axis label
    
    %plot the predicted and actual behavior rates timeseries
    subplot(length(selected_transitions)+4,1,3:length(selected_transitions)+1)
    my_colors = behavior_colors;
    transition_prob_for_frame = zeros(number_of_edges,stimulus_period);
    transition_counts_for_frame = zeros(number_of_edges,stimulus_period);
    transition_counts_for_condition_for_frame = zeros(number_of_edges,stimulus_period);
    transition_std_for_frame = zeros(number_of_edges,stimulus_period);
    for frame_index = 1:stimulus_period
        for edge_index = 1:number_of_edges
            transitions_for_frame = all_behavior_transitions_for_frame{stimulus_index}{frame_index};
    %         transition_counts_for_frame(:,frame_index) = sum(transitions_for_frame,2);
            conditional_edges = find(from_edges == all_edge_pairs(edge_index,1));
            
            transition_counts_for_frame(edge_index,frame_index) = sum(transitions_for_frame(edge_index,:),2); %transitions count conditioned on from and to
            transition_counts_for_condition_for_frame(edge_index,frame_index) = sum(sum(transitions_for_frame(conditional_edges,:),1),2); %all transitions conditioned on from
            
            transition_prob_for_frame(edge_index,frame_index) = transition_counts_for_frame(edge_index,frame_index)./ transition_counts_for_condition_for_frame(edge_index,frame_index);
            transition_std_for_frame(edge_index,frame_index) = sqrt(transition_counts_for_frame(edge_index,frame_index))./transition_counts_for_condition_for_frame(edge_index,frame_index).*fps.*60;
        end
    end
    
    track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));

    %compute observed baseline rate
    observed_baseline_transition_rate = mean(transition_prob_for_frame(:,baseline_start:baseline_end),2);
    %compute predicted baseline rate
    predicted_baseline_transition_rate = mean(predicted_behavior_transitions_for_stim{stimulus_index}(:,baseline_start:baseline_end),2);
    %compute moving average observed rate
    observed_moving_average_transition_rate = movingmean(transition_prob_for_frame, peak_window, 2);
    %compute the baseline subtracted transition rate within the peak window
    observed_baseline_substrated_mean_peak_rate = observed_moving_average_transition_rate(:,peak_predicted_rate_location) - observed_baseline_transition_rate;
    %compute std within the window of peak
    observed_peak_transition_rate_sem = std(transition_prob_for_frame(:,exp_start:exp_end),[],2) ./ sqrt(peak_window);
    %compute the significance
    transition_rate_change_significance = false(1,number_of_edges);
    transition_rate_change_significance_all_behaviors_pvalue = ones(1, number_of_edges);

    for edge_index = 1:number_of_edges
        h = ttest(transition_prob_for_frame(edge_index,exp_start:exp_end)-observed_baseline_transition_rate(edge_index));
        if ~isnan(h)
            %if there is even data to test
            [transition_rate_change_significance(edge_index),transition_rate_change_significance_all_behaviors_pvalue(edge_index)] = ttest(transition_prob_for_frame(edge_index,exp_start:exp_end)-observed_baseline_transition_rate(edge_index));
        end
    end
    %compute moving average prediction rate (not used)
    predicted_moving_average_transition_rate = movingmean(predicted_behavior_transitions_for_stim{stimulus_index}, peak_window, 2);
    
    hold on
    for selected_transition_index = 1:length(selected_transitions)
        behavior_from = selected_transitions{selected_transition_index}(1);
        behavior_to = selected_transitions{selected_transition_index}(2);
        [~, transition_index] = ismember([behavior_from, behavior_to],all_edge_pairs,'rows');

        %get the offset
        offset = -double(spacing*selected_transition_index);
        
        %plot the raw transition rate in grey
        plot(0:1/fps:plotting_period/fps, transition_prob_for_frame(transition_index,plotting_start:plotting_end) - observed_baseline_transition_rate(transition_index) + offset, '-', 'color', [my_colors(behavior_to,:) 0.25],'Linewidth', 2,'DisplayName',[num2str(LNPStats(transition_index).Edges(1)), 'to', num2str(LNPStats(transition_index).Edges(2)), ' actual']);
        %plot the moving average transition rate in behavior color solid line
        plot(0:1/fps:plotting_period/fps, observed_moving_average_transition_rate(transition_index,plotting_start:plotting_end) - observed_baseline_transition_rate(transition_index) + offset, '-', 'color', my_colors(behavior_to,:) ,'Linewidth', 4,'DisplayName',[num2str(LNPStats(transition_index).Edges(1)), 'to', num2str(LNPStats(transition_index).Edges(2)), ' moving average']);
        %plot the predicted transition rate in dashed black line
        plot(0:1/fps:plotting_period/fps, predicted_behavior_transitions_for_stim{stimulus_index}(transition_index,plotting_start:plotting_end) - predicted_baseline_transition_rate(transition_index) + offset, ':', 'color', 'k', 'Linewidth', 2,'DisplayName',[num2str(LNPStats(transition_index).Edges(1)), 'to', num2str(LNPStats(transition_index).Edges(2)), ' predicted']);
        %plot the zero line in dashed grey line
        plot(0:1/fps:plotting_period/fps, repmat(offset,1,plotting_period+1), '--', 'color', [0.4 0.4 0.4], 'Linewidth', 2,'DisplayName','zero');
       
    end
    hold off
    xlabel('Time (s)') % x-axis label
    ylabel('Transition Rate (transitions/min)') % y-axis label
    if BTA_playback
        title([behavior_names{stimulus_to_behavior_key(stimulus_index)}, ' Kernel']);       
    else
        title(['Stimulus Index = ', num2str(stimulus_index), ' (n = ', num2str(track_n), ')']);
    end
    axis([0, 20, -(spacing*length(selected_transitions)+1), floor(spacing-1)]);
    %legend('show');
    ax = gca;
    ax.FontSize = 10;
    
    %plot the predicted and actual behavior rates bar plot 
    subplot(length(selected_transitions)+4,1,length(selected_transitions)+2:length(selected_transitions)+4)
    hold on
    for selected_transition_index = 1:length(selected_transitions)
        behavior_from = selected_transitions{selected_transition_index}(1);
        behavior_to = selected_transitions{selected_transition_index}(2);
        [~, transition_index] = ismember([behavior_from, behavior_to],all_edge_pairs,'rows');

        bar(selected_transition_index-0.2,observed_baseline_substrated_mean_peak_rate(transition_index),0.4,'FaceColor',behavior_colors(behavior_to,:));
        if BTA_playback        
            bar(selected_transition_index+0.2, predicted_behavior_transitions_for_stim{stimulus_index}(transition_index,peak_predicted_rate_location) - predicted_baseline_transition_rate(transition_index),0.4,'FaceColor',[0 0 0]);
        else
            bar(selected_transition_index+0.2, predicted_moving_average_transition_rate(transition_index,peak_predicted_rate_location) - predicted_baseline_transition_rate(transition_index),0.4,'FaceColor',[0 0 0]);
        end
        errorbar(selected_transition_index-0.2,observed_baseline_substrated_mean_peak_rate(transition_index),observed_peak_transition_rate_sem(transition_index), 'k', 'linestyle', 'none', 'marker', 'none')
        if transition_rate_change_significance(transition_index)
            if observed_baseline_substrated_mean_peak_rate(transition_index) > 0
                text(selected_transition_index-0.2, observed_baseline_substrated_mean_peak_rate(transition_index) + observed_peak_transition_rate_sem(transition_index) + 0.03, '*', 'Fontsize', 20, 'HorizontalAlignment','center', 'VerticalAlignment','middle')
            else
                text(selected_transition_index-0.2, observed_baseline_substrated_mean_peak_rate(transition_index) - observed_peak_transition_rate_sem(transition_index) - 0.06, '*', 'Fontsize', 20, 'HorizontalAlignment','center', 'VerticalAlignment','middle')
            end   
        end
        text(selected_transition_index-0.2, observed_baseline_substrated_mean_peak_rate(transition_index) - observed_peak_transition_rate_sem(transition_index) - 0.3, ['p=', num2str(round(transition_rate_change_significance_all_behaviors_pvalue(transition_index),2,'significant'))], 'Fontsize', 20, 'HorizontalAlignment','center', 'VerticalAlignment','middle')
    end
    
    ax = gca;
    ax.FontSize = 8;

    set(gca,'XTick',1:length(selected_transitions))
    X_tick_labels = {};
    for selected_transition_index = 1:length(selected_transitions)
        behavior_from = selected_transitions{selected_transition_index}(1);
        behavior_to = selected_transitions{selected_transition_index}(2);
        %get the counts for each bar
        X_tick_labels = [X_tick_labels, {[behavior_names{behavior_from}, ' to ', behavior_names{behavior_to}, ' (n=', num2str(sum(transition_counts_for_frame(selected_transition_index,exp_start:exp_end))),')']}];
    end
    set(gca, 'XTickLabels', X_tick_labels)
    axis([0, length(selected_transitions)+1, -0.5, 0.5])
    limits = get(gca,'YLim');
    set(gca,'YTick',linspace(limits(1),limits(2),3))
    xlabel('') % x-axis label
    ylabel('Transition Rate Change (transitions/min)') % y-axis label
    
end
