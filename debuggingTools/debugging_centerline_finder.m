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
Tracks(track_count).DilationSize = [];
Tracks(track_count).AspectRatio = [];
Tracks(track_count).MeanAspectRatio = [];
Tracks(track_count).ThinningIteration = [];
Tracks(track_count).MeanAngle = [];
Tracks(track_count).Angles = [];
Tracks(track_count).ProjectedEigenValues = [];

for track_index = 1:1
    load(['worm_', num2str(track_index), '.mat']);
    Track = Tracks(track_index);
    Tracks(track_index) = initial_sweep(worm_images, Tracks(track_index), Prefs, track_index);
    %resolve_problems(Tracks(track_index), curDir)
    track_index
end
