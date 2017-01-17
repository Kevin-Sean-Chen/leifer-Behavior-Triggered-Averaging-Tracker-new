function [] = PlotWatershed(embeddingValues)
%Plots the density map along with the watershed
    maxVal = max(max(abs(embeddingValues)));
    maxVal = round(maxVal * 1.1);
    load('reference_embedding.mat')

    sigma = 4; %change smoothing factor if necessary

    [xx,density] = findPointDensity(embeddingValues,sigma,501,[-maxVal maxVal]);
    maxDensity = max(density(:));
    density(density < 10e-6) = 0;
%     L = watershed(-density,8);
% 
%     L(L==1) = max(L(:))+1;
%     L = L - 1;
    [ii,jj] = find(L==0);

    watershed_centroids = regionprops(L, 'centroid');
    watershed_centroids = vertcat(watershed_centroids.Centroid);
    watershed_centroids = round(watershed_centroids);

    %modify col0r map
    my_colormap = othercolor('OrRd9');
    my_colormap(1,:) = [1 1 1];

    %figure
    hold on
    imagesc(xx,xx,density)
%     plot(xx(jj),xx(ii),'k.')
    axis equal tight off xy
    caxis([0 maxDensity])
    colormap(my_colormap)
%     for region_index = 1:size(watershed_centroids,1)-1
%         text(xx(watershed_centroids(region_index,1)), ...
%             xx(watershed_centroids(region_index,2)), ...
%             num2str(region_index), 'color', 'k', ...
%             'fontsize', 12, 'horizontalalignment', 'center', ...
%             'verticalalignment', 'middle');
%     end
    hold off

end

