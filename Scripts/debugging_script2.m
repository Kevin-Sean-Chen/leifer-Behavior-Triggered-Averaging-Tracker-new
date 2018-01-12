% this script gets the distribution of the active tracks for a group of
% experiments

relevant_track_fields = {'Frames'};

%select folders
folders = getfoldersGUI();
max_index = 25200;
track_counts = zeros(length(folders), max_index);
for folder_index = 1:length(folders)
    tracks = load_single_folder(folders{folder_index}, relevant_track_fields);
    all_frames = [tracks.Frames];
    folder_track_counts = zeros(1,max_index);
    for frame_index = 1:max_index;
        folder_track_counts(frame_index) = sum(all_frames == frame_index);
    end
    track_counts(folder_index,:) = folder_track_counts;
end

mean(track_counts(:))
std(track_counts(:))
hist(track_counts(:))
xlabel('Active Tracks at a Given Time')
ylabel('Count')
