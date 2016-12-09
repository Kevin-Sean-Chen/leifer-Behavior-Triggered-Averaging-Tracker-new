function [] = PlotWatershedDifference(embeddingValues1,embeddingValues2)
%Plots the density map along with the watershed
    maxVal = max(max(abs([embeddingValues1;embeddingValues2])));
    maxVal = round(maxVal * 1.1);
    load('reference_embedding.mat')

    sigma = 4; %change smoothing factor if necessary

    [xx,density1] = findPointDensity(embeddingValues1,sigma,501,[-maxVal maxVal]);
    [~,density2] = findPointDensity(embeddingValues2,sigma,501,[-maxVal maxVal]);
    
    density_diff = density1-density2;
    
    maxDensity = max(abs(density_diff(:)));
%     L = watershed(-density,8);
% 
%     L(L==1) = max(L(:))+1;
%     L = L - 1;
    [ii,jj] = find(L==0);

    watershed_centroids = regionprops(L, 'centroid');
    watershed_centroids = vertcat(watershed_centroids.Centroid);
    watershed_centroids = round(watershed_centroids);

    %modify jet map
    my_colormap = jet;

    %figure
    hold on
    imagesc(xx,xx,density_diff)
    plot(xx(jj),xx(ii),'k.')
    axis equal tight off xy
    caxis([-maxDensity maxDensity])
    colormap(my_colormap)
    for region_index = 1:size(watershed_centroids,1)-1
        text(xx(watershed_centroids(region_index,1)), ...
            xx(watershed_centroids(region_index,2)), ...
            num2str(region_index), 'color', 'k', ...
            'fontsize', 12, 'horizontalalignment', 'center', ...
            'verticalalignment', 'middle');
    end
    hold off
    colorbar
end

