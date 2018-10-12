%not used in paper

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
rows_per_page = 9;
bootstrap_n = 100;
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
behavior_transitions_for_frame = cell(1,time_window_before+time_window_after+1);
behaviors_for_frame = cell(1,time_window_before+time_window_after+1);

for critical_frame_index = 1:length(critical_frames)
    %for every time a stimulus is delivered, look at a certain range of
    %frames
    for frame_shift = -time_window_before:time_window_after
        current_frame = critical_frames(critical_frame_index) + frame_shift;
        if current_frame <= length(LEDVoltages) && current_frame >= 1
            %make sure the current frame is in range
            tracks_on_critical_frame = FilterTracksByTime(allTracks,current_frame, current_frame);
            if ~isempty(tracks_on_critical_frame)
                behavior_transitions_for_frame{frame_shift+time_window_before+1} = [behavior_transitions_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.Behaviors];
                behaviors_for_frame{frame_shift+time_window_before+1} = [behaviors_for_frame{frame_shift+time_window_before+1}, tracks_on_critical_frame.BehavioralAnnotation];
            end
        end
    end
    
end

% plot the transition rates centered on stim delivery
transition_counts_for_frame = zeros(number_of_behaviors,length(behavior_transitions_for_frame));
transition_rate_for_frame = zeros(number_of_behaviors,length(behavior_transitions_for_frame));
transition_std_for_frame = zeros(number_of_behaviors,length(behavior_transitions_for_frame));
for frame_index = 1:length(behavior_transitions_for_frame)
    transitions_for_frame = behavior_transitions_for_frame{frame_index};%horzcat(behaviors_for_frame{frame_index}.Behaviors);
    transition_counts_for_frame(:,frame_index) = sum(transitions_for_frame,2);
    transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
    transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
end

track_n = round(mean(arrayfun(@(x) size(x{1},2), behavior_transitions_for_frame)));
my_colors = behavior_colors;
figure
hold on
for behavior_index = 1:number_of_behaviors
    transition_n = sum(transition_counts_for_frame(behavior_index,:));
    plot(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',[behavior_names{behavior_index}, ' (', num2str(transition_n),' transitions)']);
end
hold off
title(['(n = ', num2str(track_n), ' tracks)']);
xlabel('Time (s)') % x-axis label
ylabel('Transition Rate (transitions/min)') % y-axis label
legend('show');
ax = gca;
ax.FontSize = 10;

%% 2 plot the behavioral ratios as a function of time
% plot the transition rates centered on stim delivery
behavior_counts_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));
behavior_ratios_for_frame = zeros(number_of_behaviors,length(behaviors_for_frame));

total_counts_for_frame = zeros(1,length(behaviors_for_frame));
for frame_index = 1:length(behaviors_for_frame)
    for behavior_index = 1:number_of_behaviors
        behavior_counts_for_frame(behavior_index,frame_index) = sum(behaviors_for_frame{frame_index}==behavior_index);
    end
    behavior_ratios_for_frame(:,frame_index) = behavior_counts_for_frame(:,frame_index)./sum(behavior_counts_for_frame(:,frame_index)); %get ratio
end


track_n = round(mean(arrayfun(@(x) size(x{1},2), behaviors_for_frame)));
my_colors = behavior_colors;
figure
hold on
for behavior_index = 1:number_of_behaviors
    plot(-time_window_before/fps:1/fps:time_window_after/fps, behavior_ratios_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',behavior_names{behavior_index});
end
hold off
title(['(n = ', num2str(track_n), ' tracks)']);
xlabel('Time (s)') % x-axis label
ylabel('Behavioral Ratio') % y-axis label
legend('show');
ax = gca;
ax.FontSize = 10;

%% all 72 context dependent transitions differences for plate tap experiments in a grid
all_edge_pairs = get_edge_pairs(number_of_behaviors);

mean_tap_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_tap_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
tap_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
tap_observation_counts = zeros(number_of_behaviors, number_of_behaviors);

mean_control_tap_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_control_tap_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
control_tap_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
control_tap_observation_counts = zeros(number_of_behaviors, number_of_behaviors);
bootstrap_fractional_increases = cell(number_of_behaviors, number_of_behaviors);

tap_difference_significant = false(number_of_behaviors, number_of_behaviors);
tap_pvalue = eye(number_of_behaviors);
tap_hypothesis_counts = 0;
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            [mean_tap_transition_rates(behavior_from,behavior_to),mean_control_tap_transition_rates(behavior_from,behavior_to), ...
                std_tap_transition_rates(behavior_from,behavior_to),std_control_tap_transition_rates(behavior_from,behavior_to), ...
                tap_difference_significant(behavior_from,behavior_to),tap_pvalue(behavior_from,behavior_to), ...
                tap_transitions_counts(behavior_from,behavior_to),control_tap_transitions_counts(behavior_from,behavior_to),...
                tap_observation_counts(behavior_from,behavior_to),control_tap_observation_counts(behavior_from,behavior_to)] = ...
                average_transition_rate_after_tap(folders_platetap, behavior_from, behavior_to);
            
            %bootstrap values for fractional increase from baseline after stim
            stim_sample_count = tap_observation_counts(behavior_from,behavior_to)/29; % 29 is 2 seconds
            control_sample_count = control_tap_observation_counts(behavior_from,behavior_to)/29;
            stim_samples = false(1,stim_sample_count);
            stim_samples(1:tap_transitions_counts(behavior_from,behavior_to)) = true;            
            control_samples = false(1,control_sample_count);
            control_samples(1:control_tap_transitions_counts(behavior_from,behavior_to)) = true;
            bootstrap_frac_inc = zeros(1,bootstrap_n);
            for bootstrap_index = 1:bootstrap_n
                bootstrap_stim_sample = datasample(stim_samples,stim_sample_count);
                bootstrap_control_sample = datasample(control_samples,stim_sample_count);
                if any(bootstrap_control_sample)
                    bootstrap_frac_inc(bootstrap_index) = (sum(bootstrap_stim_sample)/stim_sample_count) / (sum(bootstrap_control_sample)/control_sample_count);
                end
            end
            bootstrap_fractional_increases{behavior_from,behavior_to} = bootstrap_frac_inc;
            
            tap_hypothesis_counts = tap_hypothesis_counts + 1;
        end
    end
end
%multiple hypothesis testing correction of significance
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            tap_difference_significant(behavior_from,behavior_to) = 0.05./tap_hypothesis_counts > tap_pvalue(behavior_from,behavior_to);
        end
    end
end


%plot reversal fractioal increase from bootstrapping
behavior_to = 3;
turn_bootstrap_frac_inc_mean = mean(bootstrap_fractional_increases{2,behavior_to});
turn_bootstrap_frac_inc_std = std(bootstrap_fractional_increases{2,behavior_to});

fwd_bootstrap_frac_inc_mean = mean(bootstrap_fractional_increases{1,behavior_to});
fwd_bootstrap_frac_inc_std = std(bootstrap_fractional_increases{1,behavior_to});

%get p value using 2 tails
bootstrap_frac_inc_diff = bootstrap_fractional_increases{1,behavior_to} - bootstrap_fractional_increases{2,behavior_to};
bootstrap_frac_inc_diff_mean_offset_abs = abs(bootstrap_frac_inc_diff - mean(bootstrap_frac_inc_diff));
mean_distance = abs(turn_bootstrap_frac_inc_mean - fwd_bootstrap_frac_inc_mean);
p = sum(bootstrap_frac_inc_diff_mean_offset_abs > mean_distance) ./ length(bootstrap_frac_inc_diff_mean_offset_abs); %find the fraction of points with larger difference when the null is true
% 
% figure('pos',[10 10 200 300])
% barwitherr([fwd_bootstrap_frac_inc_std; turn_bootstrap_frac_inc_std], [fwd_bootstrap_frac_inc_mean; turn_bootstrap_frac_inc_mean],'FaceColor',behavior_colors(behavior_to,:))
% ax = gca;
% if p < 0.05
%     sigstar({[1,2]},p);
% end
% box('off')
% set(gca,'YTick',[0 10])
% set(gca,'XTickLabel',{'Fwd','Turn'})
% set(gca,'fontsize',14)
% ylabel('Times More Likely to Reverse with Stim')
% title(['p=', num2str(p)])
% axis([0 3 0 10]);

%plot it
figure
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            if control_tap_transitions_counts(behavior_from,behavior_to) == 0 && tap_transitions_counts(behavior_from,behavior_to) == 0
            else
                scrollsubplot(rows_per_page,double(number_of_behaviors),double((behavior_from-1)*number_of_behaviors+behavior_to))
                barwitherr([std_control_tap_transition_rates(behavior_from,behavior_to); std_tap_transition_rates(behavior_from,behavior_to)], [mean_control_tap_transition_rates(behavior_from,behavior_to); mean_tap_transition_rates(behavior_from,behavior_to)],'FaceColor',behavior_colors(behavior_to,:))
                ax = gca;
                if tap_difference_significant(behavior_from,behavior_to)
                    sigstar({[1,2]},0.05);
    %                 ax.XColor = 'red';
    %                 ax.YColor = 'red';
    %                 title({['n=', num2str(control_tap_transitions_counts(behavior_from,behavior_to)),', ',num2str(tap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(tap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'r')
    %             else
    %                 title({['n=', num2str(control_tap_transitions_counts(behavior_from,behavior_to)),', ',num2str(tap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(tap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'k')
    %                 sigstar({[1,2]},nan,0,30);           
                end
    %             if behavior_from == 2 && behavior_to == 1
    %                 ylabel('Platetap Transition Rate (transitions/min)')
    % %                 set(gca,'XTickLabel',{'-','+'})
    % %             else
    % %                 set(gca,'YTick','')
    %             end

                title(['n=', num2str(control_tap_transitions_counts(behavior_from,behavior_to)),', ',num2str(tap_transitions_counts(behavior_from,behavior_to))],'Color', 'k', 'FontWeight', 'normal', 'Fontsize', 14)
                %title({['n=', num2str(control_tap_transitions_counts(behavior_from,behavior_to)),', ',num2str(tap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(tap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'k')
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

% %% get the percent change above baseline for behavioral ratios
% tap_behavioral_ratio_percent_changes = percent_change_above_baseline(behavior_ratios_for_frame);
% 
% %optotap_behavioral_ratio_percent_changes = [-54.7906394353574 83.1340905929878 15.2321768129009 -18.4336895345706 -47.1191535144282 -41.8393080973100 74.3198149368540 1178.71667868585 296.327653243460]
% hold on
% tap_vs_optotap_percent_change = [tap_behavioral_ratio_percent_changes, optotap_behavioral_ratio_percent_changes];
% bar(tap_vs_optotap_percent_change);
% 
% for i = 1:length(tap_vs_optotap_percent_change);
%     text(1:length(tap_vs_optotap_percent_change), max(tap_vs_optotap_percent_change,[],2)', num2str(round(tap_vs_optotap_percent_change)), 'VerticalAlignment', 'top','HorizontalAlignment','center')
% end
% legend({'Tap','Optotap'});
% set(gca, 'XTickLabel', [{[]}, behavior_names])
% ylabel('Maximum Percent Change from Baseline') % y-axis label
% 

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
% %     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',['Behavior ', num2str(behavior_index)]});
%     plot(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',['Behavior ', num2str(behavior_index)]);
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
% %     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',['Behavior ', num2str(behavior_index)]});
%     plot(-time_window_before/fps:1/fps:time_window_after/fps, behavior_ratios_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',['Behavior ', num2str(behavior_index)]);
% end
% hold off
% xlabel('Time (s)') % x-axis label
% ylabel('Behavioral Ratio') % y-axis label
% legend('show');
% ax = gca;
% ax.FontSize = 10;

% %% 5 plot the transition rates as a function of time given the worm is a particular behavior immediately after the behavior at time 0
% behaviors_for_frame = cell(1,time_window_before+time_window_after+1);
% behavior_of_interest = 3;
% for critical_frame_index = 1:length(critical_frames)
%     %for every time a stimulus is delivered, look at a certain range of
%     %frames only if the track fits certain criteria
%     current_critical_frame = critical_frames(critical_frame_index);
%     if current_critical_frame + time_window_after <= length(LEDVoltages) && current_critical_frame - time_window_before >= 1
%         %get tracks that last through the entire duration of the window
%         tracks_within_critical_window = FilterTracksByTime(allTracks,current_critical_frame - time_window_before, current_critical_frame + time_window_after, true);
%         
%         tracks_on_current_critical_frame = FilterTracksByTime(tracks_within_critical_window,current_critical_frame, current_critical_frame);
%         
%         %select the tracks that have the next behavior being the behavior
%         %of interest
%         selected_indecies = [];
%         for tracks_within_critical_window_index = 1:length(tracks_within_critical_window)
%             current_behavioral_transitions = tracks_on_current_critical_frame(tracks_within_critical_window_index).BehavioralTransition;
%             current_local_frame_index = [tracks_on_current_critical_frame(tracks_within_critical_window_index).LocalFrameIndex];
%             next_behavior = current_behavioral_transitions(find(current_behavioral_transitions(:,2)>current_local_frame_index,1,'first'),1);
%             if ~isempty(next_behavior) && next_behavior == behavior_of_interest
%                 selected_indecies = [selected_indecies, tracks_within_critical_window_index];
%             end
%         end
%         
%         selected_tracks = tracks_within_critical_window(selected_indecies);
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
% %     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',['Behavior ', num2str(behavior_index)]});
%     plot(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',['Behavior ', num2str(behavior_index)]);
% end
% hold off
% xlabel('Time (s)') % x-axis label
% ylabel('Transition Rate (transitions/min)') % y-axis label
% legend('show');
% ax = gca;
% ax.FontSize = 10;
% 
% %% 6 plot the behavioral ratio as a function of time given the worm is a particular behavior immediately after the behavior at time 0
% behaviors_for_frame = cell(1,time_window_before+time_window_after+1);
% behavior_of_interest = 9;
% for critical_frame_index = 1:length(critical_frames)
%     %for every time a stimulus is delivered, look at a certain range of
%     %frames only if the track fits certain criteria
%     current_critical_frame = critical_frames(critical_frame_index);
%     if current_critical_frame + time_window_after <= length(LEDVoltages) && current_critical_frame - time_window_before >= 1
%         %get tracks that last through the entire duration of the window
%         tracks_within_critical_window = FilterTracksByTime(allTracks,current_critical_frame - time_window_before, current_critical_frame + time_window_after, true);
%         
%         tracks_on_current_critical_frame = FilterTracksByTime(tracks_within_critical_window,current_critical_frame, current_critical_frame);
%         
%         %select the tracks that have the next behavior being the behavior
%         %of interest
%         selected_indecies = [];
%         for tracks_within_critical_window_index = 1:length(tracks_within_critical_window)
%             current_behavioral_transitions = tracks_on_current_critical_frame(tracks_within_critical_window_index).BehavioralTransition;
%             current_local_frame_index = [tracks_on_current_critical_frame(tracks_within_critical_window_index).LocalFrameIndex];
%             next_behavior = current_behavioral_transitions(find(current_behavioral_transitions(:,2)>current_local_frame_index,1,'first'),1);
%             if ~isempty(next_behavior) && next_behavior == behavior_of_interest
%                 selected_indecies = [selected_indecies, tracks_within_critical_window_index];
%             end
%         end
%         
%         selected_tracks = tracks_within_critical_window(selected_indecies);
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
% %     shadedErrorBar(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), transition_std_for_frame(behavior_index,:), {'-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',['Behavior ', num2str(behavior_index)]});
%     plot(-time_window_before/fps:1/fps:time_window_after/fps, behavior_ratios_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',['Behavior ', num2str(behavior_index)]);
% end 
% hold off
% xlabel('Time (s)') % x-axis label
% ylabel('Behavioral Ratio') % y-axis label
% legend('show');
% ax = gca;
% ax.FontSize = 10;
