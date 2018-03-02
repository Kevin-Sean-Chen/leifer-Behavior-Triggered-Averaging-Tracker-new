%not used in paper

%taken from returnTemplates.m
%embeddingValues = vertcat(Embeddings{:});
embeddingValues = vertcat(allTracks.Embeddings);

maxVal = max(max(abs(embeddingValues)));
maxVal = round(maxVal * 1.1);

% sigma = maxVal / 40; %change smoothing factor if necessary
sigma = 4.3; %change smoothing factor if necessary
numPoints = 501;
rangeVals = [-maxVal maxVal];

[xx,density] = findPointDensity(embeddingValues,sigma,501,[-maxVal maxVal]);
maxDensity = max(density(:));
density(density < 10e-6) = 5;
L = watershed(-density,8);
[ii,jj] = find(L==0);

L(L==1) = max(L(:))+1;
L = L - 1;

watershed_centroids = regionprops(L, 'centroid');
watershed_centroids = vertcat(watershed_centroids.Centroid);
watershed_centroids = round(watershed_centroids);


density(density == 5) = 0;
%modify jet map
my_colormap = othercolor('OrRd9');
my_colormap(1,:) = [1 1 1];

figure
hold on
imagesc(xx,xx,density)
caxis([0 maxDensity])
colormap(my_colormap)
plot(xx(jj),xx(ii),'k.')
for region_index = 1:size(watershed_centroids,1)-1
    text(xx(watershed_centroids(region_index,1)), ...
        xx(watershed_centroids(region_index,2)), ...
        num2str(region_index), 'color', 'k', ...
        'fontsize', 12, 'horizontalalignment', 'center', ...
        'verticalalignment', 'middle');
end
axis equal tight xy
hold off
colorbar
xlimits=round(get(gca,'xlim'));
set(gca,'xtick',xlimits);
ylimits=round(get(gca,'ylim'));
set(gca,'ytick',ylimits);
