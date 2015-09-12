function Tracks = Find_Centerlines(Tracks, curDir)
    image_size = [60,60];

    Tracks(1).Centerlines = [];
    Tracks(1).CenterlineProperties = [];
    %% Extract Centerlines
    parfor track_index = 1:length(Tracks)
        loaded_file = load([curDir, '\individual_worm_imgs\worm_', num2str(track_index), '.mat']);
        worm_images = loaded_file.worm_images;
        [Tracks(track_index).Centerlines, Tracks(track_index).CenterlineProperties] = initial_sweep(worm_images, Tracks(track_index), track_index);
        track_index
    end
    
    %% DEBUG: plot from beginning to finish%%%%%%
    for track_index = 1:length(Tracks)
        loaded_file = load([curDir, '\individual_worm_imgs\worm_', num2str(track_index), '.mat']);
        worm_images = loaded_file.worm_images;
        outputVideo = VideoWriter(fullfile(['worm_', num2str(track_index)]),'MPEG-4');
        outputVideo.FrameRate = 14;
        open(outputVideo)

        for worm_frame_index = 1:size(worm_images,3)
            I = reshape(worm_images(:,:,worm_frame_index),image_size);
            plot_worm_frame(I, squeeze(Tracks(track_index).Centerlines(:,:,worm_frame_index)), ...
                Tracks(track_index).CenterlineProperties(worm_frame_index), ...
                Tracks(track_index).Eccentricity(worm_frame_index), Tracks(track_index).Direction(worm_frame_index), ...
                Tracks(track_index).Speed(worm_frame_index), Tracks(track_index).Path(worm_frame_index, :));
            writeVideo(outputVideo, getframe(gcf));
        end
        close(outputVideo) 
    end
end