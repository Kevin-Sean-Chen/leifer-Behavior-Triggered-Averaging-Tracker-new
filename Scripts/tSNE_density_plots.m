%not used in paper

observations = zeros(size(data,1),1);
image_size = [70, 70];
data_index = 1;
observation_index = 1;

for track_index = 1:length(allTracks)
    track_embedding = Embeddings{track_index};
    Track = allTracks(track_index);
    direction_vector = [[Track.Speed].*-cosd([Track.Direction]); [Track.Speed].*sind([Track.Direction])];
    
    head_vector = reshape(Track.Centerlines(1,:,:),2,[]) - (image_size(1)/2);    
   
    %normalize into unit vector
    head_normalization = hypot(head_vector(1,:), head_vector(2,:));
    head_vector = head_vector ./ repmat(head_normalization, 2, 1);
    side_vector = [-head_vector(2,:);head_vector(1,:)];
    
    direction_dot_product = smoothts(dot(side_vector, direction_vector), 'b', 28);
    
    %side direction vector

    for frame_index = 1:length(allTracks(track_index).Frames)
         if direction_dot_product(frame_index) > 0.05
            observations(observation_index) = data_index;
            observation_index = observation_index + 1;
         end
        data_index = data_index + 1;
    end
end

observations = observations(observations>0);
selectedEmbeddings = embeddingValues(observations,:);

maxVal = max(max(abs(embeddingValues)));
maxVal = round(maxVal * 1.1);

sigma = maxVal / 40;
numPoints = 501;
rangeVals = [-maxVal maxVal];

[xx,density2] = findPointDensity(selectedEmbeddings,sigma,numPoints,rangeVals);
maxDensity = max(abs(density1(:)-density2(:)));

figure
hold on
imagesc(xx,xx,density1-density2)
axis equal tight off xy
caxis([-maxDensity * .8, maxDensity * .8])
colormap(jet)
hold off
colorbar