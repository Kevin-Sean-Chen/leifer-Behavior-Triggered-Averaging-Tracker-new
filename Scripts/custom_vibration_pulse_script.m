load('reference_embedding.mat')
%load tracks
% relevant_track_fields = {'BehavioralTransition','Path','Frames','LEDPower','LEDVoltages','Embeddings','Velocity', 'LEDVoltage2Power'};
relevant_track_fields = {'BehavioralTransition','Frames'};

%select foldersta
folders_optotap = getfoldersGUI();

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
for folder_index = 1:length(folders_optotap)
    %load the tracks for this folder
    [current_tracks, folder_indecies_revstim_ret, track_indecies_revstim_ret] = loadtracks(folders_optotap{folder_index},relevant_track_fields);
    current_tracks = BehavioralTransitionToBehavioralAnnotation(current_tracks);
    %generate the Behavior matricies
    current_tracks = get_behavior_triggers(current_tracks);

    current_param = load_parameters(folders_optotap{folder_index});
    PWM_dutycycles = load([folders_optotap{folder_index}, filesep, 'PWM.txt']);
    PWM_frequencies = load([folders_optotap{folder_index}, filesep, 'frequencies.txt']);
   
    %find when each stimuli is played back by convolving the time
    %reversed stimulus (cross-correlation)
    xcorr_ledvoltages_stimulus = padded_conv(PWM_dutycycles, normalized_stimuli);
    [peak_magnitudes, peak_locations] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakDistance',14);
    
    %loop through the peaks and cut up tracks
    for peak_index = 1:length(peak_locations)
        %get the stimulus intensity for this peak
        current_stim_power = PWM_dutycycles(peak_locations(peak_index));
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
            if current_frame <= length(PWM_dutycycles) && current_frame >= 1
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
    transition_counts_for_frame = zeros(number_of_behaviors,total_window_frames);
    transition_rate_for_frame = zeros(number_of_behaviors,total_window_frames);
    transition_std_for_frame = zeros(number_of_behaviors,total_window_frames);
    for frame_index = 1:total_window_frames
        transitions_for_frame = all_behavior_transitions_for_frame{stimulus_index}{frame_index};
        transition_counts_for_frame(:,frame_index) = sum(transitions_for_frame,2);
        transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
        transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
    end

    track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));
    my_colors = behavior_colors;
    figure
    hold on
    for behavior_index = 1:number_of_behaviors
        transition_n = sum(transition_counts_for_frame(behavior_index,:));
        plot(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',[behavior_names{behavior_index}, ' (', num2str(transition_n),' transitions)']);
    end
    hold off
    xlabel('Time (s)') % x-axis label
    ylabel('Transition Rate (transitions/min)') % y-axis label
    title(['Stimulus Intensity = ', num2str(stimulus_intensities(stimulus_index)), ' (n = ', num2str(track_n), ' tracks)']);
    legend('show');
    ax = gca;
    ax.FontSize = 10;
    axis([-10 10 0 35])
end
%% 2 plot the behavioral ratios as a function of time
behavior_counts_for_frame = zeros(number_of_behaviors,length(stimulus_intensities),total_window_frames);
behavior_ratios_for_frame = zeros(number_of_behaviors,length(stimulus_intensities),total_window_frames);

for stimulus_index = 1:length(stimulus_intensities)
    % plot the transition rates centered on stim delivery
    total_counts_for_frame = zeros(1,total_window_frames);
    for frame_index = 1:total_window_frames
        for behavior_index = 1:number_of_behaviors
            behavior_counts_for_frame(behavior_index,stimulus_index,frame_index) = sum(all_behavior_annotations_for_frame{stimulus_index}{frame_index}==behavior_index);
        end
        behavior_ratios_for_frame(:,stimulus_index,frame_index) = behavior_counts_for_frame(:,stimulus_index,frame_index)./sum(behavior_counts_for_frame(:,stimulus_index,frame_index)); %get ratio
    end
end

for stimulus_index = 1:length(stimulus_intensities)
    track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));
    my_colors = behavior_colors;
    figure
    hold on
    for behavior_index = 1:number_of_behaviors
        plot(-time_window_before/fps:1/fps:time_window_after/fps, squeeze(behavior_ratios_for_frame(behavior_index,stimulus_index,:)), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',behavior_names{behavior_index});
    end
    hold off
    xlabel('Time (s)') % x-axis label
    ylabel('Behavioral Ratio') % y-axis label
    title(['Stimulus Intensity = ', num2str(stimulus_intensities(stimulus_index)), ' (n = ', num2str(track_n), ' tracks)']);

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
        track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));
        plot(-time_window_before/fps:1/fps:time_window_after/fps, squeeze(behavior_ratios_for_frame(behavior_index,stimulus_index,:)), '-', 'color', my_colors(stimulus_index,:),'Linewidth', 3,'DisplayName',[num2str(stimulus_intensities(stimulus_index)), ' percent duty cycle (n = ', num2str(track_n),' tracks)']);
    end
    hold off
    xlabel('Time (s)') % x-axis label
    ylabel('Behavioral Ratio') % y-axis label
    title(behavior_names{behavior_index});

    legend('show');
    ax = gca;
    ax.FontSize = 10;
end

%% plot how we picked the GWN range
%optotap_behavioral_ratio_percent_changes = percent_change_above_baseline(squeeze(behavior_ratios_for_frame(:,4,:)));
behavior_index = 8;
[behavior_percent_change, behavior_baselines, behavior_max, behavior_min] = percent_change_above_baseline(squeeze(behavior_ratios_for_frame(behavior_index,:,:)));

x = stimulus_intensities;
y = behavior_max';

figure('Position',[100,100,800,600])
% hold on
% rectangle('Position',[0,0,50,0.6],'FaceColor',[1 0.5 0.5])
plot(x, y, 'bo-', 'LineWidth',2,'Markersize',10)

for stimulus_index = 1:length(stimulus_intensities)
    track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));
    text(x(stimulus_index), y(stimulus_index), ['   n=', num2str(track_n)]);
end

ax = gca;
ax.XTick = stimulus_intensities;
% ax.YTick = [0 0.3 0.6];
ax.FontSize = 20;

xlabel('Stimulus Intensity (percent duty cycle)') % x-axis label
ylabel('Fast Reverse Behavioral Ratio') % y-axis label

%% all 72 context dependent transitions differences for vibrations experiments in a grid
all_edge_pairs = get_edge_pairs(number_of_behaviors);
rows_per_page = 3;

mean_vibration_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_vibration_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
vibration_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
vibration_observation_counts = zeros(number_of_behaviors, number_of_behaviors);

mean_control_vibration_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_control_vibration_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
control_vibration_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
control_vibration_observation_counts = zeros(number_of_behaviors, number_of_behaviors);
bootstrap_fractional_increases = cell(number_of_behaviors, number_of_behaviors);

vibration_difference_significant = false(number_of_behaviors, number_of_behaviors);
vibration_pvalue = eye(number_of_behaviors);
control_hypothesis_counts = 0;
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            [mean_vibration_transition_rates(behavior_from,behavior_to),mean_control_vibration_transition_rates(behavior_from,behavior_to), ...
                std_vibration_transition_rates(behavior_from,behavior_to),std_control_vibration_transition_rates(behavior_from,behavior_to), ...
                vibration_difference_significant(behavior_from,behavior_to),vibration_pvalue(behavior_from,behavior_to), ...
                vibration_transitions_counts(behavior_from,behavior_to),control_vibration_transitions_counts(behavior_from,behavior_to),...
                vibration_observation_counts(behavior_from,behavior_to),control_vibration_observation_counts(behavior_from,behavior_to)] = ...
                average_transition_rate_after_vibration(folders_optotap, behavior_from, behavior_to);
            
            %bootstrap values for fractional increase from baseline after stim
            stim_sample_count = vibration_observation_counts(behavior_from,behavior_to)/29; % 29 is 2 seconds
            control_sample_count = control_vibration_observation_counts(behavior_from,behavior_to)/29;
            stim_samples = false(1,stim_sample_count);
            stim_samples(1:vibration_transitions_counts(behavior_from,behavior_to)) = true;            
            control_samples = false(1,control_sample_count);
            control_samples(1:control_vibration_transitions_counts(behavior_from,behavior_to)) = true;
            bootstrap_frac_inc = zeros(1,bootstrap_n);
            for bootstrap_index = 1:bootstrap_n
                bootstrap_stim_sample = datasample(stim_samples,stim_sample_count);
                bootstrap_control_sample = datasample(control_samples,stim_sample_count);
                if any(bootstrap_control_sample)
                    bootstrap_frac_inc(bootstrap_index) = (sum(bootstrap_stim_sample)/stim_sample_count) / (sum(bootstrap_control_sample)/control_sample_count);
                end
            end
            bootstrap_fractional_increases{behavior_from,behavior_to} = bootstrap_frac_inc;
            
            control_hypothesis_counts = control_hypothesis_counts + 1;
        end
    end
end
%multiple hypothesis testing correction of significance
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            vibration_difference_significant(behavior_from,behavior_to) = 0.05./control_hypothesis_counts > vibration_pvalue(behavior_from,behavior_to);
        end
    end
end

%plot it
figure
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            if control_vibration_transitions_counts(behavior_from,behavior_to) == 0 && vibration_transitions_counts(behavior_from,behavior_to) == 0
            else
                scrollsubplot(rows_per_page,double(number_of_behaviors),double((behavior_from-1)*number_of_behaviors+behavior_to))
                barwitherr([std_control_vibration_transition_rates(behavior_from,behavior_to); std_vibration_transition_rates(behavior_from,behavior_to)], [mean_control_vibration_transition_rates(behavior_from,behavior_to); mean_vibration_transition_rates(behavior_from,behavior_to)],'FaceColor',behavior_colors(behavior_to,:))
                ax = gca;
                if vibration_difference_significant(behavior_from,behavior_to)
                    sigstar({[1,2]},0.05);
    %                 ax.XColor = 'red';
    %                 ax.YColor = 'red';
    %                 title({['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(optotap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'r')
    %             else
    %                 title({['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(optotap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'k')
    %                 sigstar({[1,2]},nan,0,30);           
                end
    %             set(gca,'XTickLabel',{['n=',num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=', num2str(optotap_pvalue(behavior_from,behavior_to))]})
    %             if behavior_from == 2 && behavior_to == 1
    %                 ylabel('Platetap Transition Rate (transitions/min)')
    % %             else
    % %                 set(gca,'YTick','')
    %             end
                title(['n=', num2str(control_vibration_transitions_counts(behavior_from,behavior_to)),', ',num2str(vibration_transitions_counts(behavior_from,behavior_to))],'Color', 'k', 'FontWeight', 'normal', 'Fontsize', 14)
                box('off')
                set(gca,'XTick','')
                set(gca,'fontsize',14)
                y_limits = ylim;             %get y lim
                new_ylim = y_limits(2);
%                new_ylim = 2;
                if new_ylim > 1
                    new_ylim = ceil(y_limits(2));
                else
                    new_ylim = 1;
                end
                axis([0 3 0 new_ylim]);
                if (behavior_from == 9 && behavior_to == 1) || new_ylim > 1
                    ax.YTick = linspace(0,new_ylim,2);
                else
                    set(gca,'YTick','')
                end
            end
        end
    end
end
