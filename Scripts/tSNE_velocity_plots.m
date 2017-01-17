observations = cell(size(L));
image_size = [70, 70];

for track_index = 1:length(allTracks)
    Track = allTracks(track_index);
    watershed_xy_indecies = SpaceMapping(Track.Embeddings,xx);

    head_direction_dot_product = Track.Velocity;

    for frame_index = 1:length(allTracks(track_index).Frames)
%       if head_direction_dot_product(frame_index) < 0
	        observations{watershed_xy_indecies(frame_index,1),watershed_xy_indecies(frame_index,2)} ...
	            = [observations{watershed_xy_indecies(frame_index,1),watershed_xy_indecies(frame_index,2)}, ...
	            head_direction_dot_product(frame_index)];
%       end
    end
end

mean_observations = zeros(size(observations));
for row_index = 1:size(observations,1)
    for column_index = 1:size(observations,2)
        mean_observations(row_index, column_index) = mean(observations{row_index, column_index});
    end
end

pcolor(mean_observations')
axis equal tight off xy
shading flat
shading interp
colorbar