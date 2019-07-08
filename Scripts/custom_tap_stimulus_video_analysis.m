
%load tracks
relevant_track_fields = {'Path','Frames','Velocity'};

%select folders
folders_platetap = getfoldersGUI();

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

output_number_of_tracks = 100; % this is the number of tracks we are looking for

%% behavioral rate compare

%for the first experiment, search for the occurance of each stimulus after
%normalizing to 1
LEDVoltages = load([folders_platetap{1}, filesep, 'LEDVoltages.txt']);
%LEDVoltages = LEDVoltages(randperm(length(LEDVoltages))); %optional, randomly permuate the taps
LEDVoltages(LEDVoltages>0) = 1; %optional, make the stimulus on/off binary

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


%% calculate the threshold velocity
allTracks = [];
for folder_index = 1:length(folders_platetap)
    %load the tracks for this folder
    [current_tracks, folder_indecies_revstim_ret, track_indecies_revstim_ret] = loadtracks(folders_platetap{folder_index},{'Velocity'});
    allTracks = [allTracks, current_tracks];
end

boxcar_window = ones(1,time_window_before+time_window_after+1) ./ (time_window_before+time_window_after+1);
% calculate all possible velocities to get the threshold
all_delta_velocities = [];
for track_index = 1:length(allTracks)
    boxcar_velocity = padded_conv(allTracks(track_index).Velocity, boxcar_window);
    delta_veolocities = boxcar_velocity((time_window_before+time_window_after+1):end) - boxcar_velocity(1:end-(time_window_before+time_window_after));
    all_delta_velocities = [all_delta_velocities, delta_veolocities];
end
thresh_velocity = prctile(all_delta_velocities, top_percentile_cutoff);

%% allow for random sampling of tap events
current_index = 1;
possible_taps_to_sample = [];
for folder_index = 1:length(folders_platetap)
    for tap_frame_index = 1:length(tap_frames)
        possible_taps_to_sample(current_index).folder = folders_platetap{folder_index};
        possible_taps_to_sample(current_index).tap_frame = tap_frames(tap_frame_index);
        current_index = current_index + 1;
    end
end

%% draw it out
% Setup figure for plotting tracker results
% -----------------------------------------
WTFigH = findobj('Tag', 'WTFIG');
if isempty(WTFigH)
    WTFigH = figure('Name', 'Tracking Results', ...
        'NumberTitle', 'off', ...
        'Tag', 'WTFIG','units','normalized','outerposition',[0 0 2 2]);
else
    figure(WTFigH);
end

% outputVideo = VideoWriter(fullfile([folder_name, filesep, 'processed']),'MPEG-4');
% outputVideo.FrameRate = fps;
% open(outputVideo)


current_index = 1;
transition_classification = {};
while current_index < output_number_of_tracks
    %keep sampling until we are done
    sample_index = unidrnd(length(possible_taps_to_sample));
    sampled_folder_name = possible_taps_to_sample(sample_index).folder;
    sampled_tap_frame = possible_taps_to_sample(sample_index).tap_frame;
    possible_taps_to_sample(sample_index) = []; % sample without replacement
    
    % load the tracks from that folder again, this time, with more fields
    [Tracks, ~, ~] = loadtracks(sampled_folder_name,relevant_track_fields);
    
    % Get all the tif file names (probably jpgs)
    image_files=dir([sampled_folder_name, filesep, '*.jpg']); %get all the jpg files (maybe named tif)
    if isempty(image_files)
        image_files = dir([sampled_folder_name, filesep, '*.tif']); 
    end
    
    %calculate before and after velocities 
    velocities_before = [];
    velocities_after = [];
    Tracks = FilterTracksByTime(Tracks, sampled_tap_frame-time_window_before-1, sampled_tap_frame+time_window_after, true);
    if isempty(Tracks)
       continue 
    end
    for track_index = 1:length(Tracks)
        mean_velocity_before = mean(Tracks(track_index).Velocity(1:time_window_before));
        mean_velocity_after = mean(Tracks(track_index).Velocity(time_window_before+2:end));
        velocities_before = [velocities_before, mean_velocity_before];
        velocities_after = [velocities_after, mean_velocity_after];
    end
    
    %classify each track
    for track_index = 1:length(Tracks)
       delta_velocity = velocities_after(track_index) - velocities_before(track_index);
       if velocities_before(track_index) < 0
           if velocities_after(track_index) > 0
               transition_classification{current_index} = 'Rev to Fwd';
           elseif delta_velocity < -thresh_velocity
               transition_classification{current_index} = 'Rev to Faster Rev';
           elseif delta_velocity > thresh_velocity
               transition_classification{current_index} = 'Rev to Slowed Rev';
           else
               transition_classification{current_index} = 'Rev - Same';
           end
       else
           if velocities_after(track_index) < 0
               transition_classification{current_index} = 'Fwd to Rev';
           elseif delta_velocity < -thresh_velocity
               transition_classification{current_index} = 'Fwd to Slowed Fwd';
           elseif delta_velocity > thresh_velocity
               transition_classification{current_index} = 'Fwd to Faster Fwd';
           else
               transition_classification{current_index} = 'Fwd - Same';
           end
       end
       Tracks(track_index).videoindex = current_index; % save this for later
       current_index = current_index + 1;
    end

    % lets plot a video with this window!
    for frame_index = sampled_tap_frame-time_window_before-1:sampled_tap_frame+time_window_after
        % Get Frame
        curImage = imread([folder_name, filesep, image_files(frame_index).name]);
        imshow(curImage,'InitialMagnification',100, 'Border','tight');
        hold on;
        if ~isempty(Tracks)
            track_indecies_in_frame = find([Tracks.Frames] == frame_index);
            frameSum = 0;
            currentActiveTrack = 1; %keeps the index of the track_indecies_in_frame
            myColors = winter(length(track_indecies_in_frame));
            for track_index = 1:length(Tracks)
                if currentActiveTrack > length(track_indecies_in_frame)
                    %all active tracks found
                    break;
                end
                if track_indecies_in_frame(currentActiveTrack) - frameSum <= length(Tracks(track_index).Frames) 
                    %active track found
                    in_track_index = track_indecies_in_frame(currentActiveTrack) - frameSum;
                    plot(Tracks(track_index).Path(1:in_track_index,1), Tracks(track_index).Path(1:in_track_index,2), 'Color', myColors(currentActiveTrack,:));
                    plot(Tracks(track_index).Path(in_track_index,1), Tracks(track_index).Path(in_track_index,2),'s','MarkerSize',30, 'Color', myColors(currentActiveTrack,:));
                    text(Tracks(track_index).Path(in_track_index,1)+20, Tracks(track_index).Path(in_track_index,2)+20, num2str(Tracks(track_index).videoindex), 'Color', myColors(currentActiveTrack,:));
                    currentActiveTrack = currentActiveTrack + 1;
                end
                frameSum = frameSum + length(Tracks(track_index).Frames);
            end
        end
        
        axis tight
        hold off;    % So not to see movie replay
        FigureName = ['Tracking Results for Frame ', num2str(frame_index)];
        set(WTFigH, 'Name', FigureName);
        pause
%         writeVideo(outputVideo, getframe(WTFigH));
        
    end
%     close(outputVideo) 
%     close(WTFigH)
    
end
