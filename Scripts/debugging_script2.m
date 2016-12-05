allTracks(1).Velocity = [];
for track_index = 1:length(allTracks)
    Track = allTracks(track_index);

    direction_vector = [[Track.Speed].*-cosd([Track.Direction]); [Track.Speed].*sind([Track.Direction])];
    head_vector = reshape(Track.Centerlines(1,:,:),2,[]) - (image_size(1)/2);    
    %normalize into unit vector
    head_normalization = hypot(head_vector(1,:), head_vector(2,:));
    head_vector = head_vector ./ repmat(head_normalization, 2, 1);
    
    allTracks(track_index).Velocity = dot(head_vector, direction_vector);
end
