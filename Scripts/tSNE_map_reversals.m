%not used in paper
frames_to_trace = 0;
folders = getfolders();
allTracks = loadtracks(folders);

watershed_centroids = regionprops(L, 'centroid');
watershed_centroids = vertcat(watershed_centroids.Centroid);
watershed_centroids = round(watershed_centroids);

figure
hold on
imagesc(xx,xx,density)
plot(xx(jj),xx(ii),'k.')
axis equal tight off xy
caxis([0 maxDensity * .8])
colormap(jet)

my_point_colors = gray(frames_to_trace+1);

% 
for track_index = 1:length(allTracks)
    Track = allTracks(track_index);
    %get the behavior annotations
    %triggers = false(1, length(Track.LEDVoltages)); %a binary array of when behaviors occur
    pirouettes = Track.Pirouettes;
    for pirouette_index = 1:size(pirouettes,1)
        pirouetteStart = pirouettes(pirouette_index,1);
        if pirouetteStart + frames_to_trace <= length(Track.LEDVoltages)
            x = Track.Embeddings(pirouetteStart:pirouetteStart+frames_to_trace,1)';
            y = Track.Embeddings(pirouetteStart:pirouetteStart+frames_to_trace,2)';
            scatter(x, y, 5, my_point_colors, 'filled')
            %triggers(1, pirouetteStart) = true;
        end
    end
    %Track.Behaviors = triggers;

    %plot(Track.Embeddings(triggers,1), Track.Embeddings(triggers,2), 'm.')

end

for region_index = 1:size(watershed_centroids,1)
    text(xx(watershed_centroids(region_index,1)), ...
        xx(watershed_centroids(region_index,2)), ...
        num2str(region_index), 'color', 'k', ...
        'fontsize', 12, 'horizontalalignment', 'center', ...
        'verticalalignment', 'middle');
end
hold off