fps = 14;
allTracks = [];

%get first distribution
while true
    folder_name = uigetdir
    if folder_name == 0
        break
    else
        cd(folder_name) %open the directory of image sequence
        load('tracks.mat')
        allTracks = [allTracks, Tracks];
    end
end

total_frames = 0;
total_run_frames = 0;
total_pirouette_frames = 0;
total_pause_frames = 0;


for track_index = 1:length(allTracks)
    %get the total frames
    total_frames = total_frames + length(allTracks(track_index).Frames);
    
    if ~isempty(allTracks(track_index).Runs)
        total_run_frames = total_run_frames + sum(allTracks(track_index).Runs(:,2) - allTracks(track_index).Runs(:,1),1);
    end
    
    if ~isempty(allTracks(track_index).Pirouettes)
        total_pirouette_frames = total_pirouette_frames + sum(allTracks(track_index).Pirouettes(:,2) - allTracks(track_index).Pirouettes(:,1),1);
    end
    
    if ~isempty(allTracks(track_index).Pauses)
        total_pause_frames = total_pause_frames + sum(allTracks(track_index).Pauses(:,2) - allTracks(track_index).Pauses(:,1),1);
    end
end

total_transition_frames = total_frames - total_run_frames - total_pirouette_frames - total_pause_frames;

stacked_bars = [total_run_frames ,total_pirouette_frames, total_pause_frames, total_transition_frames];
stacked_bars_1 = stacked_bars ./ total_frames;


%get second distribution
while true
    folder_name = uigetdir
    if folder_name == 0
        break
    else
        cd(folder_name) %open the directory of image sequence
        load('tracks.mat')
        allTracks = [allTracks, Tracks];
    end
end

total_frames = 0;
total_run_frames = 0;
total_pirouette_frames = 0;
total_pause_frames = 0;


for track_index = 1:length(allTracks)
    %get the total frames
    total_frames = total_frames + length(allTracks(track_index).Frames);
    
    if ~isempty(allTracks(track_index).Runs)
        total_run_frames = total_run_frames + sum(allTracks(track_index).Runs(:,2) - allTracks(track_index).Runs(:,1),1);
    end
    
    if ~isempty(allTracks(track_index).Pirouettes)
        total_pirouette_frames = total_pirouette_frames + sum(allTracks(track_index).Pirouettes(:,2) - allTracks(track_index).Pirouettes(:,1),1);
    end
    
    if ~isempty(allTracks(track_index).Pauses)
        total_pause_frames = total_pause_frames + sum(allTracks(track_index).Pauses(:,2) - allTracks(track_index).Pauses(:,1),1);
    end
end

total_transition_frames = total_frames - total_run_frames - total_pirouette_frames - total_pause_frames;

stacked_bars = [total_run_frames ,total_pirouette_frames, total_pause_frames, total_transition_frames];
stacked_bars_2 = stacked_bars ./ total_frames;

bar([stacked_bars_1; stacked_bars_2], 0.4, 'stacked');
set(gca, 'XTick', 1:2, 'XTickLabel', {'GC6','N2'});
ylabel('Time Fraction')
legend('Runs', 'Pirouettes', 'Pauses', 'Transition')

% CompareTwoHistograms(distribution1, distribution2, 'GC6', 'N2')
% xlabel('Ran Duration (s)')
% ylabel('Count')