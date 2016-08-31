%taken from returnTemplates.m
embeddingValues = vertcat(Embeddings{:});

maxVal = max(max(abs(embeddingValues)));
maxVal = round(maxVal * 1.1);

% sigma = maxVal / 40; %change smoothing factor if necessary
sigma = 4; %change smoothing factor if necessary
numPoints = 501;
rangeVals = [-maxVal maxVal];

[xx,density] = findPointDensity(embeddingValues,sigma,501,[-maxVal maxVal]);
density(density < 10e-6) =5;
L = watershed(-density,8);
[ii,jj] = find(L==0);

L(L==1) = max(L(:))+1;
L = L - 1;

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
for region_index = 1:size(watershed_centroids,1)-1
    text(xx(watershed_centroids(region_index,1)), ...
        xx(watershed_centroids(region_index,2)), ...
        num2str(region_index), 'color', 'k', ...
        'fontsize', 12, 'horizontalalignment', 'center', ...
        'verticalalignment', 'middle');
end
hold off