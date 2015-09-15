function [] = individual_worm_videos(Tracks, curDir, fps, plotting_fps)
% Plots a single worm over time along with its centerline
    frames_per_plot_time = round(fps/plotting_fps);
    for track_index = 1:length(Tracks)
        plotting_index = 1;
        loaded_file = load([curDir, '\individual_worm_imgs\worm_', num2str(track_index), '.mat']);
        worm_images = loaded_file.worm_images;
        outputVideo = VideoWriter(fullfile([curDir, '\individual_worm_imgs\worm_', num2str(track_index)]),'MPEG-4');
        outputVideo.FrameRate = plotting_fps;
        open(outputVideo)

        for worm_frame_index = 1:frames_per_plot_time:size(worm_images,3)
            I = squeeze(worm_images(:,:,worm_frame_index));
            plot_worm_frame(I, squeeze(Tracks(track_index).Centerlines(:,:,worm_frame_index)), ...
                Tracks(track_index).CenterlineProperties(worm_frame_index), ...
                Tracks(track_index).Eccentricity(worm_frame_index), Tracks(track_index).Direction(worm_frame_index), ...
                Tracks(track_index).Speed(worm_frame_index), plotting_index);
            IWFig = findobj('Tag', ['IWFig', num2str(plotting_index)]);
            writeVideo(outputVideo, getframe(IWFig));
        end
        close(outputVideo) 
    end
end