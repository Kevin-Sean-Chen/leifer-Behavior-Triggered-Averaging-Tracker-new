
%load tracks
relevant_track_fields = {'Frames', 'Velocity'};

%select folders
folders_platetap = getfoldersGUI();

%load stimuli.txt from the first experiment
num_stimuli = 1;
fps = 14;
normalized_stimuli = 1; %delta function
time_window_before = 2*fps;
time_window_after = 2*fps;

n_bins = 20;
edges = linspace(-0.3,0.3,n_bins);

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
track_count_that_end_on_frame = zeros(1,time_window_before+time_window_after+1);
velocities_before = [];
velocities_after = [];

for critical_frame_index = 1:length(critical_frames)
    %for every time a stimulus is delivered, look through tracks with the
    %relevant window
    Tracks = FilterTracksByTime(allTracks, critical_frames(critical_frame_index)-time_window_before-1, critical_frames(critical_frame_index)+time_window_after, true);
    for track_index = 1:length(Tracks)
        mean_velocity_before = mean(Tracks(track_index).Velocity(1:time_window_before));
        mean_velocity_after = mean(Tracks(track_index).Velocity(time_window_before+2:end));
        velocities_before = [velocities_before, mean_velocity_before];
        velocities_after = [velocities_after, mean_velocity_after];
    end
    
end


figure
%scatter(velocities_after,velocities_before)
histogram2(velocities_after,velocities_before,edges,edges,'DisplayStyle','tile','ShowEmptyBins','off')
colorbar
xlabel('Velocity After Tap (mm/s)')
ylabel('Velocity Before Tap (mm/s)')