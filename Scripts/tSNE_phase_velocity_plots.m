%not used in paper

observations = cell(size(L));

for track_index = 1:length(allTracks)
    Track = allTracks(track_index);
    watershed_xy_indecies = SpaceMapping(Embeddings{track_index},xx);
    for frame_index = 1:length(Track.Frames)
        observations{watershed_xy_indecies(frame_index,1),watershed_xy_indecies(frame_index,2)} ...
            = [observations{watershed_xy_indecies(frame_index,1),watershed_xy_indecies(frame_index,2)}, ...
            Spectra{track_index}(frame_index,end)];
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