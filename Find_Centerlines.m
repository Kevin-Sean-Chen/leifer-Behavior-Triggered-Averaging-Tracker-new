function Tracks = Find_Centerlines(Tracks, curDir)
    if isempty(Tracks)
        return
    end
    track_count = length(Tracks);
    
    Tracks(track_count).Centerlines = [];
    Tracks(track_count).CenterlineProperties = [];
    Tracks(track_count).OmegaTurnAnnotation = [];
    Tracks(track_count).PossibleHeadSwitch = [];
    parfor_progress([], length(Tracks));
    %% Extract Centerlines
    parfor track_index = 1:track_count
        loaded_file = load([curDir, '\individual_worm_imgs\worm_', num2str(track_index), '.mat']);
        worm_images = loaded_file.worm_images;
        [Tracks(track_index).Centerlines, Tracks(track_index).CenterlineProperties, ...
            Tracks(track_index).OmegaTurnAnnotation, Tracks(track_index).PossibleHeadSwitch] ...
            = initial_sweep(worm_images, Tracks(track_index), track_index);
        parfor_progress([]);
    end
    parfor_progress([], 0);
end