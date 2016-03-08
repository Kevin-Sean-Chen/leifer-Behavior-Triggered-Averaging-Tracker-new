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
for region_index = 1:size(watershed_centroids,1)
    text(xx(watershed_centroids(region_index,1)), ...
        xx(watershed_centroids(region_index,2)), ...
        num2str(region_index), 'color', 'k', ...
        'fontsize', 12, 'horizontalalignment', 'center', ...
        'verticalalignment', 'middle');
end
hold off