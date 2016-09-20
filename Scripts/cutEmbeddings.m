%% STEP 9: cut the embeddings
Embeddings = cell(length(allTracks),1);

start_index = 1;
for track_index = 1:length(allTracks)
    end_index = start_index + length(allTracks(track_index).Frames) - 1;
    Embeddings{track_index} = embeddingValues(start_index:end_index, :);
    start_index = end_index + 1;
end
