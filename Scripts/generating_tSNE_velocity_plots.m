maxVal = max(max(abs(combineCells(Embeddings))));
maxVal = round(maxVal * 1.1);
observations = cell(2*maxVal+1, 2*maxVal+1);
image_size = [70, 70];

for track_index = 1:length(allTracks)
    track_embedding = Embeddings{track_index};
    Track = allTracks(track_index);
    direction_vector = [[Track.Speed].*-cosd([Track.Direction]); [Track.Speed].*sind([Track.Direction])];
    
    head_vector = reshape(Track.Centerlines(1,:,:),2,[]) - (image_size(1)/2);    
   
    %normalize into unit vector
    head_normalization = hypot(head_vector(1,:), head_vector(2,:));
    head_vector = head_vector ./ repmat(head_normalization, 2, 1);
    
    head_direction_dot_product = dot(head_vector, direction_vector);

    for frame_index = 1:length(allTracks(track_index).Frames)
        embedding_x = round(track_embedding(frame_index,1))+maxVal+1;
        embedding_y = round(track_embedding(frame_index,2))+maxVal+1;
%         if head_direction_dot_product(frame_index) < 0
            observations{embedding_x,embedding_y} = [observations{embedding_x,embedding_y}, head_direction_dot_product(frame_index)];
%         end
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