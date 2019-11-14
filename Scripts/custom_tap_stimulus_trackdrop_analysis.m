
%load tracks
relevant_track_fields = {'Frames'};

%select folders
folders_platetap = getfoldersGUI();

%load stimuli.txt from the first experiment
num_stimuli = 1;
normalized_stimuli = 1; %delta function
time_window_before = 140;
time_window_after = 140;
fps = 14;
rows_per_page = 9;
%% behavioral rate compare

allTracks = [];
last_frames = [];
for folder_index = 1:length(folders_platetap)
    %load the tracks for this folder
    [current_tracks, folder_indecies_revstim_ret, track_indecies_revstim_ret] = loadtracks(folders_platetap{folder_index},relevant_track_fields);
    current_last_frames = zeros(1, length(current_tracks));
    for track_index = 1:length(current_tracks)
        current_last_frames(track_index) = current_tracks(track_index).Frames(end);
    end
    last_frames = [last_frames, current_last_frames];
    
end

%for each experiment, search for the occurance of each stimulus after
%normalizing to 1
LEDVoltages = load([folders_platetap{folder_index}, filesep, 'TapVoltages.txt']);
%LEDVoltages = LEDVoltages(randperm(length(LEDVoltages))); %optional, randomly permuate the taps
%LEDVoltages(LEDVoltages>0) = 1; %optional, make the stimulus on/off binary

%find when each stimuli is played back by convolving the time
%reversed stimulus (cross-correlation)
xcorr_ledvoltages_stimulus = padded_conv(LEDVoltages, normalized_stimuli);
peak_thresh = 0.99.*max(xcorr_ledvoltages_stimulus); %the peak threshold is 99% of the max (because edge effects)
[~, critical_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);


%% 1 plot the transition rates as a function of time
track_count_that_end_on_frame = zeros(1,time_window_before+time_window_after+1);

for critical_frame_index = 1:length(critical_frames)
    %for every time a stimulus is delivered, look at a certain range of
    %frames
    for frame_shift = -time_window_before:time_window_after
        current_frame = critical_frames(critical_frame_index) + frame_shift;
        if current_frame <= length(LEDVoltages) && current_frame >= 1
            %make sure the current frame is in range
            track_count_that_end_on_frame(frame_shift+time_window_before+1) = track_count_that_end_on_frame(frame_shift+time_window_before+1) + sum(last_frames == current_frame);
        end
    end
end

track_prob_that_end_on_frame = track_count_that_end_on_frame ./ length(last_frames);

figure

plot(-time_window_before/fps:1/fps:time_window_after/fps, track_prob_that_end_on_frame, '-', 'Linewidth', 3);

xlabel('Time (s)') % x-axis label
ylabel('Probability of Tracks Ending') % y-axis label
ax = gca;
ax.FontSize = 10;