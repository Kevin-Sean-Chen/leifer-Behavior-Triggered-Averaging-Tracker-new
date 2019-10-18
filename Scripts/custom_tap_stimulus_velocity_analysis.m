
%load tracks
relevant_track_fields = {'Frames', 'Velocity'};

%select folders
folders_platetap = getfoldersGUI();
save_folder_name = uigetdir([],'Table Output Folder');

%load stimuli.txt from the first experiment
num_stimuli = 1;
fps = 14;
normalized_stimuli = 1; %delta function
window_size = 2*fps;
time_window_before = window_size;
time_window_after = window_size;

n_bins = 20;
edges = linspace(-0.3,0.3,n_bins);

conditions = {'Tap', 'Control'};
top_percentile_cutoff = 95;
boxcar_window = ones(1,time_window_before+time_window_after+1) ./ (time_window_before+time_window_after+1);

%% plot 2d velocity histogram and pi charts
for condition_index = 1:length(conditions)
    allTracks = [];
    last_frames = [];
    velocities_before = [];
    velocities_after = [];

    for folder_index = 1:length(folders_platetap)
        %load the tracks for this folder
        [current_tracks, folder_indecies_revstim_ret, track_indecies_revstim_ret] = loadtracks(folders_platetap{folder_index},relevant_track_fields);
        current_last_frames = zeros(1, length(current_tracks));
        for track_index = 1:length(current_tracks)
            current_last_frames(track_index) = current_tracks(track_index).Frames(end);
        end
        last_frames = [last_frames, current_last_frames];
        allTracks = [allTracks, current_tracks];

        %for each experiment, search for the occurance of each stimulus after
        %normalizing to 1
        if exist([folders_platetap{folder_index}, filesep, 'TapVoltages.txt'],'file')==2
            LEDVoltages = load([folders_platetap{folder_index}, filesep, 'TapVoltages.txt']);
        else
            LEDVoltages = load([folders_platetap{folder_index}, filesep, 'LEDVoltages.txt']);
        end
        
        %LEDVoltages = LEDVoltages(randperm(length(LEDVoltages))); %optional, randomly permuate the taps
        LEDVoltages(LEDVoltages>0) = 1; %optional, make the stimulus on/off binary
        % LEDVoltages(LEDVoltages == max(LEDVoltages(:))) = 1; %optional, make the most intense stimulus on/off binary

        %find when each stimuli is played back by convolving the time
        %reversed stimulus (cross-correlation)
        xcorr_ledvoltages_stimulus = padded_conv(LEDVoltages, normalized_stimuli);
        peak_thresh = 0.99.*max(xcorr_ledvoltages_stimulus); %the peak threshold is 99% of the max (because edge effects)
        [~, tap_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);

        %generate a series of control taps
        control_frame_shift = round((tap_frames(2)-tap_frames(1))/2); %the control taps are exactly in between taps
        control_LEDVoltages = circshift(LEDVoltages,[0,control_frame_shift]);
        xcorr_ledvoltages_stimulus = padded_conv(control_LEDVoltages, normalized_stimuli);
        [~, control_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);

        %(rails experimentls only) keep only the tap frames with the top intensity
%         LEDVoltages = load([folders_platetap{folder_index}, filesep, 'LEDVoltages.txt']);
%         tap_frames = tap_frames(LEDVoltages(tap_frames) == max(LEDVoltages(tap_frames)));

        if strcmp(conditions{condition_index},'Tap')
            critical_frames = tap_frames;
        elseif strcmp(conditions{condition_index},'Control')
            critical_frames = control_frames;
        end    
        
        for critical_frame_index = 1:length(critical_frames)
            %for every time a stimulus is delivered, look through tracks with the
            %relevant window
            Tracks = FilterTracksByTime(current_tracks, critical_frames(critical_frame_index)-time_window_before-1, critical_frames(critical_frame_index)+time_window_after, true);
            for track_index = 1:length(Tracks)
                mean_velocity_before = mean(Tracks(track_index).Velocity(1:time_window_before));
                mean_velocity_after = mean(Tracks(track_index).Velocity(time_window_before+2:end));
                velocities_before = [velocities_before, mean_velocity_before];
                velocities_after = [velocities_after, mean_velocity_after];
            end
        end
        
    end
    
    all_delta_velocities = [];
    for track_index = 1:length(allTracks)
        boxcar_velocity = padded_conv(allTracks(track_index).Velocity,boxcar_window);
        delta_veolocities = boxcar_velocity((time_window_before+time_window_after+1):end) - boxcar_velocity(1:end-(time_window_before+time_window_after));
        all_delta_velocities = [all_delta_velocities, delta_veolocities];
    end
    thresh_velocity = prctile(all_delta_velocities, top_percentile_cutoff);

    %2D velocity histogram
    figure
    hold on
    histogram2(velocities_after,velocities_before,edges,edges,'DisplayStyle','tile','ShowEmptyBins','off', 'Normalization', 'probability')
    yL = get(gca,'YLim');
    xL = get(gca,'XLim');
    line(xL,[0 0],'Color','r','linewidth',2);
    line([0, 0],yL,'Color','r','linewidth',2);
    line(xL,yL,'Color','r','linewidth',2);
    line([0, xL(2)-thresh_velocity],[thresh_velocity, yL(2)],'Color','r','linewidth',1);
    line([thresh_velocity, xL(2)],[0, yL(2)-thresh_velocity],'Color','r','linewidth',1);
    line([xL(1), -thresh_velocity],[yL(1)+thresh_velocity, 0],'Color','r','linewidth',1);
    line([xL(1)+thresh_velocity, 0],[yL(1), -thresh_velocity],'Color','r','linewidth',1);
    
    
    axis square;
    colorbar
    xlabel('Velocity After Tap (mm/s)')
    ylabel('Velocity Before Tap (mm/s)')
    title(conditions{condition_index})
    
    %classify each track
    transition_classification = cell(1, length(velocities_before));
    for track_index = 1:length(velocities_before)
       delta_velocity = velocities_after(track_index) - velocities_before(track_index);
       if velocities_before(track_index) < 0
           if velocities_after(track_index) > 0
               transition_classification{track_index} = 'Rev to Fwd';
           elseif delta_velocity < -thresh_velocity
               transition_classification{track_index} = 'Rev to Faster Rev';
           elseif delta_velocity > thresh_velocity
               transition_classification{track_index} = 'Rev to Slowed Rev';
           else
               transition_classification{track_index} = 'Rev - Same';
           end
       else
           if velocities_after(track_index) < 0
               transition_classification{track_index} = 'Fwd to Rev';
           elseif delta_velocity < -thresh_velocity
               transition_classification{track_index} = 'Fwd to Slowed Fwd';
           elseif delta_velocity > thresh_velocity
               transition_classification{track_index} = 'Fwd to Faster Fwd';
           else
               transition_classification{track_index} = 'Fwd - Same';
           end
       end
    end
    
    
    %let's count this
    behavior_types = {'Rev to Fwd', 'Rev to Faster Rev', 'Rev to Slowed Rev', 'Rev - Same', 'Fwd to Rev', 'Fwd to Slowed Fwd', 'Fwd to Faster Fwd', 'Fwd - Same'};
    behavior_counts = zeros(1, length(behavior_types));
    for track_index = 1:length(transition_classification)
        [~,behavior_index] = ismember(transition_classification{track_index}, behavior_types);
        if behavior_index < 1
            %not found
            behavior_types = [behavior_types, transition_classification{track_index}];
            behavior_counts = [behavior_counts, 1];
        else
            behavior_counts(behavior_index) = behavior_counts(behavior_index) + 1;
        end
    end
    
    total_count = length(transition_classification);
    
    pie_labels = behavior_types;
    for behavior_index = 1:length(pie_labels)
        pie_labels{behavior_index} = [pie_labels{behavior_index}, ' ', num2str(round(behavior_counts(behavior_index)/total_count*100)),'% (n=', num2str(behavior_counts(behavior_index)),')'];
    end
    
    explode = ones(1,length(behavior_types));
    figure
    pie(behavior_counts, explode, pie_labels);
    title(conditions{condition_index})

    %export tables
    
    T = table(behavior_types',behavior_counts',round(behavior_counts/total_count*100)','VariableNames',{'Transition', 'RawCount', 'Percentage'});
    writetable(T,[save_folder_name, filesep, conditions{condition_index}, '_behavioral_table.csv'])

end
   

%     %exclude when velocity is < 0 before
%     excluded_indecies_because_animal_was_reversing = velocities_before < 0;
%     velocities_before(excluded_indecies_because_animal_was_reversing) = [];
%     velocities_after(excluded_indecies_because_animal_was_reversing) = [];
%     reverse_before_tap_count = sum(excluded_indecies_because_animal_was_reversing);
%     
%     excluded_indecies_because_animal_reversed_after_tap = velocities_after < 0;
%     velocities_before(excluded_indecies_because_animal_reversed_after_tap) = [];
%     velocities_after(excluded_indecies_because_animal_reversed_after_tap) = [];
%     reverse_after_tap_count = sum(excluded_indecies_because_animal_reversed_after_tap);
%     
%     delta_velocity = velocities_after - velocities_before;
%     slowdown_count = sum(delta_velocity < -thresh_velocity);
%     speedup_count = sum(delta_velocity > thresh_velocity);
%     same_count = length(delta_velocity) - slowdown_count - speedup_count;
%     total_count = reverse_after_tap_count + slowdown_count + speedup_count + same_count;    
% pie_labels = {['Reverse ', num2str(round(reverse_after_tap_count/total_count*100)),'% (n=', num2str(reverse_after_tap_count),')'], ...
%         ['Same ', num2str(round(same_count/total_count*100)),'% (n=', num2str(same_count),')'], ...
%         ['Speed Up ', num2str(round(speedup_count/total_count*100)),'% (n=', num2str(speedup_count),')'], ...
%         ['Slow Down ', num2str(round(slowdown_count/total_count*100)),'% (n=', num2str(slowdown_count),')']};
