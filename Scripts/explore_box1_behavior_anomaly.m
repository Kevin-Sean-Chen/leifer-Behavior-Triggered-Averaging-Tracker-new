fps = 14;
folders = getfolders;
relevant_fields = {'Frames','Path'};
Tracks = loadtracks(folders, relevant_fields);

%% plot tracks by relative track time
n_samples = 100;
track_indecies = randperm(length(Tracks));
% plot paths
figure
hold on
for sample_index = 1:n_samples
    track_index = track_indecies(sample_index);
    %plot(Tracks(track_index).Path(:,1), Tracks(track_index).Path(:,2))
    surface([Tracks(track_index).Path(:,1)';Tracks(track_index).Path(:,1)'], ...
        [Tracks(track_index).Path(:,2)';Tracks(track_index).Path(:,2)'], ...
        zeros(2,size(Tracks(track_index).Path,1)), ...
        [(1:length(Tracks(track_index).Frames))./length(Tracks(track_index).Frames);(1:length(Tracks(track_index).Frames))./length(Tracks(track_index).Frames)],...
            'facecol','no',...
            'edgecol','interp',...
            'linew',2);
end
axis equal
