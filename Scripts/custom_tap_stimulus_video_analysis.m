
%load tracks
relevant_track_fields = {'Path','Frames','Velocity'};

%select folders
folders_platetap = getfoldersGUI();
video_folder_name = uigetdir([],'Video Output Folder');

%load stimuli.txt from the first experiment
num_stimuli = 1;
fps = 14;
normalized_stimuli = 1; %delta function
window_size = 2*fps;
time_window_before = window_size;
time_window_after = window_size;

video_window_size = 10*fps;
video_time_window_before = video_window_size;
video_time_window_after = video_window_size;


n_bins = 20;
edges = linspace(-0.3,0.3,n_bins);

%condition = 'Tap';
condition = 'Control';
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

if strcmp(condition,'Tap')
    critical_frames = tap_frames;
elseif strcmp(condition,'Control')
    critical_frames = control_frames;
end    


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

%% allow for random sampling of tap events or control events
current_index = 1;
possible_taps_to_sample = [];
for folder_index = 1:length(folders_platetap)
    for tap_frame_index = 1:length(critical_frames)
        possible_taps_to_sample(current_index).folder = folders_platetap{folder_index};
        possible_taps_to_sample(current_index).tap_frame = critical_frames(tap_frame_index);
        current_index = current_index + 1;
    end
end

%% draw it out
% Setup figure for plotting tracker results
% -----------------------------------------
current_index = 1;
transition_classification = {};
avg_velocity_before = [];
avg_velocity_after = [];
while ~isempty(possible_taps_to_sample) && current_index < output_number_of_tracks
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
    [filtered_tracks, track_indecies_preserved] = FilterTracksByTime(Tracks, sampled_tap_frame-time_window_before-1, sampled_tap_frame+time_window_after, true);
    if isempty(filtered_tracks)
       %skip if there's no actual tracks here
       continue 
    end
    Tracks = Tracks(track_indecies_preserved);
    for track_index = 1:length(filtered_tracks)
        mean_velocity_before = mean(filtered_tracks(track_index).Velocity(1:time_window_before));
        mean_velocity_after = mean(filtered_tracks(track_index).Velocity(time_window_before+2:end));
        velocities_before = [velocities_before, mean_velocity_before];
        velocities_after = [velocities_after, mean_velocity_after];
    end
    
    %start the video
    WTFigH = findobj('Tag', 'WTFIG');
    if isempty(WTFigH)
        WTFigH = figure('Name', 'Tracking Results', ...
            'NumberTitle', 'off', ...
            'Tag', 'WTFIG','units','normalized','outerposition',[0 0 2 2]);
    else
        figure(WTFigH);
    end
    outputVideo = VideoWriter(fullfile([video_folder_name, filesep, 'worms', num2str(current_index), '-', num2str(current_index+length(Tracks)-1)]),'Motion JPEG AVI');
    outputVideo.FrameRate = fps;
    outputVideo.Quality = 100;
    open(outputVideo)   
    
    %classify each track
    for track_index = 1:length(filtered_tracks)
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
       avg_velocity_before(current_index) = velocities_before(track_index);
       avg_velocity_after(current_index) = velocities_after(track_index);
       current_index = current_index + 1;
    end
    
    % lets plot a video with this window!
    for frame_index = sampled_tap_frame-video_time_window_before-1:sampled_tap_frame+video_time_window_after
        % Get Frame
        curImage = imread([sampled_folder_name, filesep, image_files(frame_index).name]);
        imshow(curImage,'InitialMagnification',100, 'Border','tight');
        hold on;
        % add text
        relative_frame_index = frame_index - sampled_tap_frame;
        tap_time_text = datestr(abs(relative_frame_index)/24/3600/fps,'SS.FFF');
        if relative_frame_index < 0
            tap_time_text = ['-', tap_time_text];
        else
            tap_time_text = [' ', tap_time_text];
        end
        video_time_text = datestr(abs(frame_index)/24/3600/fps,'MM:SS.FFF');
        text(50, 50, ['Folder: ', sampled_folder_name, ', Video Time: ', video_time_text, ', Stimulus Time: ', tap_time_text], 'Color', [1 1 1], 'FontSize', 15, 'VerticalAlignment','top','HorizontalAlignment','left');
        
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
%                 plot(Tracks(track_index).Path(1:in_track_index,1), Tracks(track_index).Path(1:in_track_index,2), 'Color', myColors(currentActiveTrack,:));
                plot(Tracks(track_index).Path(in_track_index,1), Tracks(track_index).Path(in_track_index,2),'s','MarkerSize',50, 'Color', myColors(currentActiveTrack,:));
                text(Tracks(track_index).Path(in_track_index,1)+60, Tracks(track_index).Path(in_track_index,2)-60, num2str(Tracks(track_index).videoindex), 'Color', myColors(currentActiveTrack,:), 'FontSize', 20);
                currentActiveTrack = currentActiveTrack + 1;
            end
            frameSum = frameSum + length(Tracks(track_index).Frames);
        end
        axis tight
        hold off;    % So not to see movie replay
        FigureName = ['Tracking Results for Frame ', num2str(frame_index)];
        set(WTFigH, 'Name', FigureName);
        writeVideo(outputVideo, getframe(WTFigH));
    end
    close(outputVideo) 
    close(WTFigH)
end

%save behavioral calls after making the table
WormIndex = 1:length(transition_classification);
T = table(WormIndex',transition_classification',avg_velocity_before',avg_velocity_after','VariableNames',{'WormIndecies', 'BehavioralClassifcation', 'VelocityBefore', 'VelocityAfter'});
writetable(T,[video_folder_name, filesep, 'behavioralkey.csv'])

