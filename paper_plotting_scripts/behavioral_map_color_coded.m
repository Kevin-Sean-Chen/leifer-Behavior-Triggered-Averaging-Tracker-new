load('reference_embedding.mat')

maxDensity = max(density(:));
density(density < 10e-6) = 0;

L = encapsulate_watershed_matrix(L);
number_of_behaviors = max(L(:))-1;
[ii,jj] = find(L==0);

watershed_centroids = regionprops(L, 'centroid');
watershed_centroids = vertcat(watershed_centroids.Centroid);
watershed_centroids = round(watershed_centroids);

%special case
watershed_centroids(2,2) = watershed_centroids(2,2) + 15;
watershed_centroids(2,1) = watershed_centroids(2,1) - 10;
watershed_centroids(7,1) = watershed_centroids(7,1) + 5;

%modify color map
%my_colormap = parula;
my_colormap = [1 1 1; behavior_colors; 1 1 1];

text_colors = [1 1 1; 0 0 0; 0 0 0; 1 1 1; 1 1 1; 1 1 1; 0 0 0; 1 1 1; 1 1 1];
behavior_names{7} = ['Slow' char(10) 'Reverse'];
behavior_names{8} = ['Fast' char(10) 'Reverse'];

figure
hold on
imagesc(xx,xx,L)
plot(xx(jj),xx(ii),'k.')
axis equal tight off xy
caxis([0 max(L(:))])
colormap(my_colormap)
for behavior_index = 1:size(watershed_centroids,1)-1
    text(xx(watershed_centroids(behavior_index,1)), ...
        xx(watershed_centroids(behavior_index,2)), ...
        behavior_names{behavior_index}, 'color', text_colors(behavior_index,:) , ...
        'fontsize', 10, 'horizontalalignment', 'center', ...
        'verticalalignment', 'middle');
end

% %plot major watershed divisions
%     for behavior_index = 1:number_of_behaviors
%         binary_L = L == 0;
%         dilated_binary_L = imdilate(binary_L,ones(7));
%         inner_border_L = and(ismember(L,behavior_index), dilated_binary_L);
%         %inner_border_L = bwmorph(inner_border_L, 'thin', inf);
%         [ii,jj] = find(inner_border_L==1);
%         plot(xx(jj),xx(ii),'.','color',behavior_colors(behavior_index,:))
%     end

