%% STEP 4a: get example points based on closeness to the selected point
[~,training_indecies_ordered_by_distance] = pdist2(trainingEmbedding,selected_point,'euclidean','Smallest',size(trainingEmbedding,1));
possible_tracks = trainingSetTracks(training_indecies_ordered_by_distance);
possible_frames = trainingSetFrames(training_indecies_ordered_by_distance);

% %% STEP 4b: get example points based on watershed region
% watershed_x = SpaceMapping(selected_point(1),xx);
% watershed_y = SpaceMapping(selected_point(2),xx);
% watershed_region = L(watershed_y, watershed_x); %get the watershed region index
% 
% %find all training points in the region
% [watershed_ii,watershed_jj] = find(L==watershed_region);
% watershed_space_embedding = SpaceMapping(trainingEmbedding,xx);
% training_indecies_in_watershed = find(ismember(watershed_space_embedding,[watershed_jj,watershed_ii],'rows'));
% training_indecies_in_watershed = training_indecies_in_watershed(randperm(length(training_indecies_in_watershed))); %randomize order
% possible_tracks = trainingSetTracks(training_indecies_in_watershed);
% possible_frames = trainingSetFrames(training_indecies_in_watershed);


%% STEP 5: get N points that fits the criteria
selected_training_indecies = [];
selected_tracks = [];
selected_frames = [];
current_index = 1;
while length(selected_training_indecies) < N
    current_track_number = possible_tracks(current_index);
    current_track_length = length(allTracks(current_track_number).Frames);
    current_frame_number = possible_frames(current_index);
    if current_frame_number - frames_before < 1 || current_frame_number + frames_after > current_track_length
        %this point will be cut out at some point, throw it out
    else
        data_point_accepted = false;
        if ismember(current_track_number, selected_tracks)
            previously_found_indecies = find(selected_tracks==current_track_number);
            previously_found_frames = selected_frames(previously_found_indecies);
            covered_frames = current_frame_number-frames_before:current_frame_number+frames_after;
            if ~sum(ismember(previously_found_frames,covered_frames))               
                %this track has been represented, but this behavior is out
                %of range
                data_point_accepted = true;
            end
        else
            %this track has not been represented
            data_point_accepted = true;
        end
        if data_point_accepted
            selected_training_indecies = [selected_training_indecies, training_indecies_in_watershed(current_index)];
            selected_tracks = [selected_tracks, current_track_number];
            selected_frames = [selected_frames, current_frame_number];  
        end
    end
    current_index = current_index + 1;
end

selected_embedded_points = trainingEmbedding(selected_training_indecies, :);
selected_feature_vectors = trainingSetData(selected_training_indecies,:);

%% STEP 6: plot the training points selected
sample_figure = figure('Position', [0, 0, size(xx,2), size(xx,2)])
hold on
imagesc(xx,xx,density)
for i = 1:N
    text(selected_embedded_points(i,1), selected_embedded_points(i,2),num2str(i),'VerticalAlignment','middle','HorizontalAlignment','center','Color','m')
    %plot(selected_embedded_points(:,1), selected_embedded_points(:,2), '*m', 'MarkerSize', 10)
end
%plot(selected_embedded_points(:,1), selected_embedded_points(:,2), '*m', 'MarkerSize', 10)
%plot(selected_point(:,1), selected_point(:,2), 'om', 'MarkerSize', 30, 'LineWidth', 3)
plot(xx(jj),xx(ii),'k.')
axis equal tight off xy
caxis([0 maxDensity * .8])
colormap(jet)
hold off
set(gca,'position',[0 0 1 1],'units','normalized')

saveas(sample_figure,fullfile(pathname,[filename(1:end-4), '.png']),'png');

%% STEP 7: plot the behaviors

%load the worm images
required_worm_images(N).worm_images = [];
for worm_images_index = 1:N
    track_index = selected_tracks(worm_images_index);
    image_file = fullfile([folders{folder_indecies(track_index)}, '\individual_worm_imgs\worm_', num2str(track_indecies(track_index)), '.mat']);
    required_worm_images(worm_images_index) = load(image_file);
end


behavior_figure = figure('Position', [0, 0, 400, 400]);
outputVideo = VideoWriter(saveFileName,'MPEG-4');
outputVideo.FrameRate = 14;
open(outputVideo)

for relative_frame_index = -frames_before:frames_after
    for subplot_index = 1:N
        worm_frame_index = selected_frames(subplot_index) + relative_frame_index;
        track_index = selected_tracks(subplot_index);
        if worm_frame_index < 1 || worm_frame_index > size(required_worm_images(subplot_index).worm_images,3)
            %the video does not exist, skip
            continue
        else
            subplot_tight(N_rows,N_columns,subplot_index,0);
            plot_worm_frame(required_worm_images(subplot_index).worm_images(:,:,worm_frame_index), squeeze(allTracks(track_index).Centerlines(:,:,worm_frame_index)), ...
            allTracks(track_index).UncertainTips(worm_frame_index), ...
            allTracks(track_index).Eccentricity(worm_frame_index), allTracks(track_index).Direction(worm_frame_index), ...
            allTracks(track_index).Speed(worm_frame_index),  allTracks(track_index).TotalScore(worm_frame_index), 0);
        end
    end
    
    ga = axes('Position',[0,0,1,1],'Xlim',[0,400],'Ylim',[0,400],'tag','ga');
    % set print margins
    topm = 400; botm = 0;
    rgtm = 400; lftm = 0;
    ctrm = (rgtm-lftm)/2;

    time_text = datestr(abs(relative_frame_index)/24/3600/fps,'SS.FFF');
    if relative_frame_index < 0
        time_text = ['-', time_text];
    end
    text(ctrm,botm+35,time_text,'color','red','fontsize',20,'VerticalAlignment','top','HorizontalAlignment','center')

    % make sure the plot is visible
    set(ga,'vis','off');

    %pause
    writeVideo(outputVideo, getframe(gcf));
    clf
end
close(outputVideo)
close(behavior_figure)

%% STEP 8: plot feature vectors
feature_vector_figure = figure('Position', [0, 0, 800, 800]);
imagesc(selected_feature_vectors);
colorbar
saveas(feature_vector_figure,fullfile(pathname,[filename(1:end-4), '_featurevector.png']),'png');
