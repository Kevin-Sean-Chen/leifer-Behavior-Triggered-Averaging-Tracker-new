%% make all 9 movies into the same video. Requires user to select where the 9 movies are coming from

fps = 14;
folder_name = uigetdir();
load('reference_embedding.mat');
number_of_behaviors = 9;
video_readers = cell(1, number_of_behaviors);

outputVideo = VideoWriter(fullfile([folder_name, filesep, 'brady']),'Motion JPEG AVI');
outputVideo.FrameRate = fps;
open(outputVideo)

for reader_index = 1:number_of_behaviors
    video_readers{reader_index} = VideoReader(fullfile([folder_name, filesep, num2str(reader_index), '.mp4']));
end

figure('pos',[10 10 900 900]);

while hasFrame(video_readers{1})
    
    for behavior_index = 1:number_of_behaviors
        subplot(3,3,behavior_index);
        image = readFrame(video_readers{behavior_index});
        imshow(image,'InitialMagnification', 300, 'Border','tight');
        text(size(image,1)/2,size(image,2)/2, behavior_names{behavior_index}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'color', behavior_colors(behavior_index,:));
    end
    %pause
    writeVideo(outputVideo, getframe(gcf));
end

close(outputVideo) 
%% make a side by side plot of a worm freely behaving, and its corresponding 

load('reference_embedding.mat')

relevant_track_fields = {'Centerlines','Frames','Embeddings'};
folders = getfolders();

%reload the tracks
[allTracks, folder_indecies, track_indecies] = loadtracks(folders);

maxDensity = max(density(:));
density(density < 10e-6) = 0;

L = encapsulate_watershed_matrix(L);
number_of_behaviors = max(L(:))-1;
[ii,jj] = find(L==0);

watershed_centroids = regionprops(L, 'centroid');
watershed_centroids = vertcat(watershed_centroids.Centroid);
watershed_centroids = round(watershed_centroids);

%special case
watershed_centroids(2,2) = watershed_centroids(2,2) + 15;

%modify color map
%my_colormap = parula;
my_colormap = [1 1 1; behavior_colors; 1 1 1];

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
        [],  [], 0);

        freezeColors

        subplot_tight(1,2,1,0);
        hold on
        imagesc(xx,xx,L)
        plot(xx(jj),xx(ii),'k.')
        axis equal tight off xy
        caxis([0 max(L(:))])
        colormap(my_colormap)
        for behavior_index = 1:size(watershed_centroids,1)-1
            text(xx(watershed_centroids(behavior_index,1)), ...
                xx(watershed_centroids(behavior_index,2)), ...
                behavior_names{behavior_index}, 'color', 'k', ...
                'fontsize', 5, 'horizontalalignment', 'center', ...
                'verticalalignment', 'middle');
        end
        plot(plot_embedding(worm_frame_index,1), plot_embedding(worm_frame_index,2), 'oy', 'MarkerSize', 15, 'LineWidth', 3)

        hold off

        writeVideo(outputVideo, getframe(gcf));
        clf
        %colorbar
    end
    close(outputVideo)
    close(behavior_figure)
end