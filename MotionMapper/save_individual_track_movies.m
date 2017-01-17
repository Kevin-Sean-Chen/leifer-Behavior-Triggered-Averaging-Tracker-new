%% STEP 11: Make density plots
% maxVal = max(max(abs(embeddingValues)));
% maxVal = round(maxVal * 1.1);
% 
% sigma = maxVal / 40;
% numPoints = 501;
% rangeVals = [-maxVal maxVal];
% 
% [xx,density] = findPointDensity(embeddingValues,sigma,numPoints,rangeVals);
maxDensity = max(density(:));
[ii,jj] = find(L==0);

relevant_track_fields = {'BehavioralTransition','Path','Frames','LEDPower','LEDVoltages','Embeddings','Velocity','Centerlines'};

%reload the tracks
[allTracks, folder_indecies, track_indecies] = loadtracks(folders,relevant_track_fields);

for track_index = 1:length(allTracks);
    plot_embedding = allTracks(track_index).Embeddings;
    image_file = fullfile([folders{folder_indecies(track_index)},filesep,'individual_worm_imgs',filesep,'worm_',num2str(track_indecies(track_index)),'.mat']);
    save_file = fullfile([folders{folder_indecies(track_index)},filesep,'individual_worm_imgs',filesep,'behaviormap_', num2str(track_indecies(track_index))]);
    load(image_file);

    behavior_figure = figure('Position', [500, 500, 500, 250]);
    outputVideo = VideoWriter(save_file,'MPEG-4');
    outputVideo.FrameRate = 14;
    open(outputVideo)
    for worm_frame_index = 1:size(plot_embedding, 1)
        subplot_tight(1,2,2,0);

        plot_worm_frame(worm_images(:,:,worm_frame_index), squeeze(allTracks(track_index).Centerlines(:,:,worm_frame_index)), ...
        [], ...
        [], [], ...
        [], [], 0);

        freezeColors

        subplot_tight(1,2,1,0);
        hold on
        imagesc(xx,xx,density)
        axis equal tight off xy
        caxis([0 maxDensity * .8])
        colormap(jet)
        plot(xx(jj),xx(ii),'k.') %watershed borders
        plot(plot_embedding(worm_frame_index,1), plot_embedding(worm_frame_index,2), 'om', 'MarkerSize', 15, 'LineWidth', 3)
        hold off

        writeVideo(outputVideo, getframe(gcf));
        clf
        %colorbar
    end
    close(outputVideo)
    close(behavior_figure)
end
