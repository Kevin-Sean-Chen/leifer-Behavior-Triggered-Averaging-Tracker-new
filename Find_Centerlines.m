function Tracks = Find_Centerlines(Tracks, curDir)
    if isempty(Tracks)
        return
    end
    
    %% Preallocate memory
    track_count = length(Tracks);
    Tracks(track_count).Centerlines = [];
    Tracks(track_count).UncertainTips = [];
    Tracks(track_count).OmegaTurnAnnotation = [];
    Tracks(track_count).PossibleHeadSwitch = [];
    Tracks(track_count).Length = [];
    Tracks(track_count).TotalScore = [];
    Tracks(track_count).ImageScore = [];
    Tracks(track_count).DisplacementScore = [];
    Tracks(track_count).PixelsOutOfBody = [];
    Tracks(track_count).PotentialProblems = [];
    
    parfor_progress([], length(Tracks));
    %% Extract Centerlines
    parfor track_index = 1:track_count
    %for track_index = 1:track_count
        loaded_file = load([curDir, '\individual_worm_imgs\worm_', num2str(track_index), '.mat']);
        worm_images = loaded_file.worm_images;
        Tracks(track_index) = initial_sweep(worm_images, Tracks(track_index), track_index);
        parfor_progress([]);
    end
    parfor_progress([], 0);
end