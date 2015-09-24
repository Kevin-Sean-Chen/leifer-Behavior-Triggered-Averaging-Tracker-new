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
for track_index = 1:175
    load(['worm_', num2str(track_index), '.mat']);
    Track = Tracks(track_index);
    Tracks(track_index) = initial_sweep(worm_images, Tracks(track_index), 1);
    %resolve_problems(Tracks(track_index), curDir)
    track_index
end