function Tracks = Find_Centerlines(Tracks, curDir)
    parpool(7)

    Tracks(1).Centerlines = [];
    Tracks(1).CenterlineProperties = [];
    parfor_progress(length(Tracks));
    %% Extract Centerlines
    parfor track_index = 1:length(Tracks)
        loaded_file = load([curDir, '\individual_worm_imgs\worm_', num2str(track_index), '.mat']);
        worm_images = loaded_file.worm_images;
        [Tracks(track_index).Centerlines, Tracks(track_index).CenterlineProperties] = initial_sweep(worm_images, Tracks(track_index), track_index);
        parfor_progress;
    end
    parfor_progress(0);
end