function success = find_centerlines(folder_name)
    addpath(genpath(pwd))
    
    parameters = load_parameters(folder_name); %load experiment parameters
    relevant_track_fields = {'Eccentricity','Direction'};

    %% Load tracks
    Tracks = load_single_folder(folder_name, relevant_track_fields);
    if isempty(Tracks)
        success = false;
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
    Tracks(track_count).DilationSize = [];
    Tracks(track_count).AspectRatio = [];
    Tracks(track_count).MeanAspectRatio = [];
    Tracks(track_count).ThinningIteration = [];
    Tracks(track_count).MeanAngle = [];
    Tracks(track_count).Angles = [];
    Tracks(track_count).ProjectedEigenValues = [];
    
    try
        parpool(feature('numcores'))
    catch
        %sometimes matlab attempts to write to the same temp file. wait and
        %restart
        pause(20);
        parpool(feature('numcores'))
    end
    
    %% Extract Centerlines and eigenworms
    parfor track_index = 1:track_count
    %for track_index = 1:track_count
        loaded_file = load([folder_name, filesep, 'individual_worm_imgs', filesep, 'worm_', num2str(track_index), '.mat']);
        worm_images = loaded_file.worm_images;
        Tracks(track_index) = initial_sweep(worm_images, Tracks(track_index), parameters, track_index);
        
        %smoothing?
        
        [angles, Tracks(track_index).MeanAngle] = centerlines_to_angles(Tracks(track_index).Centerlines); %get the angles
        Tracks(track_index).Angles = angles - (diag(parameters.MeanAngles)*ones(size(angles))); %mean center
        Tracks(track_index).ProjectedEigenValues = parameters.EigenVectors\Tracks(track_index).Angles; %project into PCA space
    end
    
    %% save the results
    savetracks(Tracks, folder_name);
    success = true;
end