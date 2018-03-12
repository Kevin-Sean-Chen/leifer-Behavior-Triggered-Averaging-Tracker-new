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

sum(track_counts(:))./14./3600 %this is the amount of data we have in frames
mean(track_counts(:))
std(track_counts(:))
hist(track_counts(:))
xlabel('Active Tracks at a Given Time')
ylabel('Count')

%% how to explore individual sets
%load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\track_counts\all_track_counts_20180119.mat')

selected_folders = [];
while true
    current_selected_folders = getfoldersGUI();
    if isempty(current_selected_folders)
        break
    else
        selected_folders = [selected_folders, current_selected_folders];
    end
end
selected_indecies = zeros(1,length(selected_folders));
for folder_index = 1:length(selected_folders)
    [~, data_folder_name, ~] = fileparts(selected_folders{folder_index});
    selected_indecies(folder_index) = find(cellfun(@(s) ~isempty(strfind(s,data_folder_name)), folders));
end

selected_track_counts = track_counts(selected_indecies,:);
sum(selected_track_counts(:))./14./3600 %this is the amount of data we have in hours
mean(selected_track_counts(:))
std(selected_track_counts(:))


