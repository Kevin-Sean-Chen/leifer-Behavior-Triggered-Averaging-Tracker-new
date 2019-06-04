
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
[~, tap_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);

%generate a series of control taps
control_frame_shift = round((tap_frames(2)-tap_frames(1))/2); %the control taps are exactly in between taps
control_LEDVoltages = circshift(LEDVoltages,[0,control_frame_shift]);
xcorr_ledvoltages_stimulus = padded_conv(control_LEDVoltages, normalized_stimuli);
[~, control_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);

%% 1 plot tap 2d velocity histogram
conditions = {'tap', 'control'};

for condition_index = 1:length(conditions)
    if strcmp(conditions{condition_index},'tap')
        critical_frames = tap_frames;
    elseif strcmp(conditions{condition_index},'control')
        critical_frames = control_frames;
    end

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
    hold on
    histogram2(velocities_after,velocities_before,edges,edges,'DisplayStyle','tile','ShowEmptyBins','off', 'Normalization', 'probability')
    yL = get(gca,'YLim');
    xL = get(gca,'XLim');
    line(xL,[0 0],'Color','r','linewidth',2);
    line([0 0],yL,'Color','r','linewidth',2);
    line([0 xL(2)],[0, yL(2)],'Color','r','linewidth',2);

    axis square;
    colorbar
    xlabel('Velocity After Tap (mm/s)')
    ylabel('Velocity Before Tap (mm/s)')
    title(conditions{condition_index})
end

