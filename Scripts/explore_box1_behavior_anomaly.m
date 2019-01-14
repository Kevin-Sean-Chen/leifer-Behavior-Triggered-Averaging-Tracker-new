fps = 14;
folders = getfoldersGUI;
relevant_fields = {'Frames','Path'};
Tracks = loadtracks(folders, relevant_fields);

%% plot tracks by relative track time
%select tracks by time 
start_frame = 25*60*fps+1;
end_frame = 30*60*fps;
filtered_tracks = FilterTracksByTime(Tracks,start_frame, end_frame, false);

%n_samples = 100;
n_samples = length(Tracks);
track_indecies = randperm(length(filtered_tracks));
% plot paths
figure
hold on
for sample_index = 1:min(n_samples,length(filtered_tracks))
    track_index = track_indecies(sample_index);
    %plot(Tracks(track_index).Path(:,1), Tracks(track_index).Path(:,2))
    surface([filtered_tracks(track_index).Path(:,1)';filtered_tracks(track_index).Path(:,1)'], ...
        [filtered_tracks(track_index).Path(:,2)';filtered_tracks(track_index).Path(:,2)'], ...
        zeros(2,size(filtered_tracks(track_index).Path,1)), ...
        [(1:length(filtered_tracks(track_index).Frames))./length(filtered_tracks(track_index).Frames);(1:length(filtered_tracks(track_index).Frames))./length(filtered_tracks(track_index).Frames)],...
            'facecol','no',...
            'edgecol','interp',...
            'linew',2);
end
axis equal
