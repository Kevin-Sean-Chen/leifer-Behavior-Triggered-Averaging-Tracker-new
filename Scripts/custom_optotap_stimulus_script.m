% plot behavior profiles under different LED intensities

load('reference_embedding.mat')
relevant_track_fields = {'BehavioralTransition','Frames','TapVoltages','LEDVoltages'};
%select folders
folders_optotap = getfoldersGUI();

LED_and_Tap=0;
LED_only=0;
Tap_only=1;

%load stimuli.txt from the first experiment
num_stimuli = 1;
normalized_stimuli = 1; %delta function
time_window_before = 140;
time_window_after = 140;
LED_before_tap=28;
total_window_frames = time_window_before+time_window_after+1;
fps = 14;
stim_similarity_thresh = 1.2;  % 1.11

number_of_behaviors = max(L(:)-1);
stimulus_intensities = [];
all_behavior_transitions_for_frame = {};
all_behavior_annotations_for_frame = {};
%% behavioral rate compare
for folder_index = 1:length(folders_optotap)
    %load the tracks for this folder
    [folder_tracks, folder_indecies_revstim_ret, track_indecies_revstim_ret] = loadtracks(folders_optotap{folder_index},relevant_track_fields);
    folder_tracks = BehavioralTransitionToBehavioralAnnotation(folder_tracks);
    %generate the Behavior matricies
    folder_tracks = get_behavior_triggers(folder_tracks);
    
    % separate the tracks based on stimuli conditions
    % [sti_tracks,TAPonly_tracks,LEDonly_tracks]=get_tracks_with_sti(folder_tracks);
    %specify which conditions to analyze
    current_tracks=folder_tracks;

    current_param = load_parameters(folders_optotap{folder_index});
    LEDVoltages = load([folders_optotap{folder_index}, filesep, 'LEDVoltages.txt']);
    TapVoltages = load([folders_optotap{folder_index}, filesep, 'TapVoltages.txt']);
    %convert LEDVoltages to power
    % uses the parameter.csv data
    %LEDPowers = round(LEDVoltages .* current_param.avgPower500 ./ 5);
 
    % Use the parameters.txt (LabView input data)
    folder_paras=readtable([folders_optotap{folder_index}, filesep, 'parameters.txt'],'Delimiter','\t');
    LEDPowers = round(LEDVoltages.*folder_paras.VoltageToPower);
    LEDPowers(end)=0; % correct for the last peak, otherwise undetected
    %find when each stimuli is played back by convolving the time
    %reversed stimulus (cross-correlation)
    xcorr_ledvoltages_stimulus = padded_conv(LEDPowers, normalized_stimuli);
    [~, LED_peaks] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakDistance',14);
    
    Tap_on=TapVoltages>0;
    LED_on=LEDVoltages>0;
    both_on=Tap_on&LED_on;
    both_LED_tap_peaks=find(both_on)-LED_before_tap;
    if LED_and_Tap
        peak_locations=both_LED_tap_peaks;
    elseif LED_only
        peak_locations=LED_peaks(~ismember(LED_peaks,both_LED_tap_peaks));
    elseif Tap_only
        peak_locations=find(Tap_on&(~LED_on))-LED_before_tap;
    end
    
    %loop through the peaks and cut up tracks
    for peak_index = 1:length(peak_locations)
        %get the stimulus intensity for this peak
        current_stim_power = LEDPowers(peak_locations(peak_index));
        %see if this stim_power already exists
        current_stim_index = find(and(stimulus_intensities < current_stim_power*stim_similarity_thresh,stimulus_intensities > current_stim_power/stim_similarity_thresh));
        if isempty(current_stim_index)
            %no entry yet
            stimulus_intensities = [stimulus_intensities,current_stim_power];
            current_stim_index = length(stimulus_intensities);
            all_behavior_transitions_for_frame{current_stim_index} = cell(1,total_window_frames);
            all_behavior_annotations_for_frame{current_stim_index} = cell(1,total_window_frames);
        end
        
        
        % delete the tracks with no taps, based on the fact that the peaks
        % are when the LED is triggered, and the tap is delivered 2 seconds
        % after
        
        %for every time a stimulus is delivered, look at a certain range of
        %frames
        for frame_shift = -time_window_before:time_window_after
            current_frame = peak_locations(peak_index) +LED_before_tap +frame_shift;
            if current_frame <= length(LEDPowers) && current_frame >= 1
                %make sure the current frame is in range
                tracks_on_critical_frame = FilterTracksByTime(current_tracks,current_frame, current_frame);
                if ~isempty(tracks_on_critical_frame)
                    all_behavior_transitions_for_frame{current_stim_index}{frame_shift+time_window_before+1} = [all_behavior_transitions_for_frame{current_stim_index}{frame_shift+time_window_before+1}, tracks_on_critical_frame.Behaviors];
                    all_behavior_annotations_for_frame{current_stim_index}{frame_shift+time_window_before+1} = [all_behavior_annotations_for_frame{current_stim_index}{frame_shift+time_window_before+1}, tracks_on_critical_frame.BehavioralAnnotation];
                end
            end
        end
    end
end

%sort the stimulus intensities
[stimulus_intensities, sort_index] = sort(stimulus_intensities);
all_behavior_transitions_for_frame = all_behavior_transitions_for_frame(sort_index);
all_behavior_annotations_for_frame= all_behavior_annotations_for_frame(sort_index);

% %% 1 plot the transition rates as a function of time
% for stimulus_index = 1:length(stimulus_intensities)
%     % plot the transition rates centered on stim delivery
%     transition_counts_for_frame = zeros(number_of_behaviors,total_window_frames);
%     transition_rate_for_frame = zeros(number_of_behaviors,total_window_frames);
%     transition_std_for_frame = zeros(number_of_behaviors,total_window_frames);
%     for frame_index = 1:total_window_frames
%         transitions_for_frame = all_behavior_transitions_for_frame{stimulus_index}{frame_index};
%         transition_counts_for_frame(:,frame_index) = sum(transitions_for_frame,2);
%         transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
%         transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
%     end
% 
%     track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));
%     my_colors = behavior_colors;
%    
%     figure
%     hold on
%     for behavior_index = 1:number_of_behaviors
%         transition_n = sum(transition_counts_for_frame(behavior_index,:));
%         plot(-time_window_before/fps:1/fps:time_window_after/fps, transition_rate_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',[behavior_names{behavior_index}, ' (', num2str(transition_n),' transitions)']);
%     end
%     hold off
%     xlabel('Time (s)') % x-axis label
%     ylabel('Transition Rate (transitions/min)') % y-axis label
%     title(['Stimulus Intensity = ', num2str(stimulus_intensities(stimulus_index)), ' (n = ', num2str(track_n), ' tracks)']);
%     legend('show');
%     ax = gca;
%     ax.FontSize = 10;
%     axis([-10 10 0 35])
% end
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
axis([-time_window_before/fps time_window_after/fps 0 0.7])
% 
% %% plot the behavioral ratios for various intensities on the same plot
% for behavior_index = 1:number_of_behaviors
%     my_colors = lines(length(stimulus_intensities));
%     figure
%     hold on
%     for stimulus_index = 1:length(stimulus_intensities)
%         track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));
%         plot(-time_window_before/fps:1/fps:time_window_after/fps, squeeze(behavior_ratios_for_frame(behavior_index,stimulus_index,:)), '-', 'color', my_colors(stimulus_index,:),'Linewidth', 3,'DisplayName',[num2str(stimulus_intensities(stimulus_index)), 'uW/mm2 (n = ', num2str(track_n),' tracks)']);
%     end
%     hold off
%     xlabel('Time (s)') % x-axis label
%     ylabel('Behavioral Ratio') % y-axis label
%     title(behavior_names{behavior_index});
% 
%     legend('show');
%     ax = gca;
%     ax.FontSize = 10;
% end
% 
%% plot how we picked the GWN range
%optotap_behavioral_ratio_percent_changes = percent_change_above_baseline(squeeze(behavior_ratios_for_frame(:,4,:)));
behavior_index = 8;
% [behavior_percent_change, behavior_baselines, behavior_max, behavior_min] = percent_change_above_baseline(squeeze(behavior_ratios_for_frame(behavior_index,:,:)));
% y = behavior_max';
x = stimulus_intensities;
err_boot=zeros(1,length(x));
[y2,mi]= max(behavior_ratios_for_frame(behavior_index,:,:),[],3);

for stimulus_index = 1:length(stimulus_intensities)
    % create binary data at the frame when the ratio of behavior is max
binary_data=(all_behavior_annotations_for_frame{stimulus_index}{mi(stimulus_index)}==behavior_index);
bootratio=bootstrp(200,@mean,binary_data); % get standard error from bootstraped data
err_boot(stimulus_index)=std(bootratio);
end
figure('Position',[100,100,800,600])
% hold on
% rectangle('Position',[0,0,50,0.6],'FaceColor',[1 0.5 0.5])
% plot(x, y, 'ro-', 'LineWidth',2,'Markersize',10)
% hold on
errorbar(x, y2,err_boot, 'bo-', 'LineWidth',2,'Markersize',10)


for stimulus_index = 1:length(stimulus_intensities)
    track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));
    text(x(stimulus_index), y2(stimulus_index), ['   n=', num2str(track_n)]);
end

ax = gca;
ax.XTick = stimulus_intensities;
% ax.YTick = [0 0.3 0.6];
ax.FontSize = 20;

xlabel('Stimulus Intensity (uW/mm2)') % x-axis label
ylabel('Fast Reverse Behavioral Ratio') % y-axis label
ylim([0,0.7]);