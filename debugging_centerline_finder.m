for track_index = 25:25
    load(['worm_', num2str(track_index), '.mat']);
    Track = Tracks(track_index);
    [Tracks(track_index).Centerlines, Tracks(track_index).CenterlineProperties, ...
                Tracks(track_index).OmegaTurnAnnotation, Tracks(track_index).PossibleHeadSwitch] ...
                = initial_sweep(worm_images, Tracks(track_index), track_index);
    track_index
end