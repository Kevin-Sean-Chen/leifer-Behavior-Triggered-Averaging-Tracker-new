load('reference_embedding.mat')
load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\AML67\behavior_map_no_subsampling\Embedding_LNPFit\LNPfit_behaviors_reordered_20171030.mat')

number_of_behaviors = max(L(:))-1;

%get a labeled map of stds above or below average
L_flat = L(:);
stds_above_shuffle_mean = zeros(1,number_of_behaviors);
stds_above_shuffle_mean_behavioral_map = zeros(size(L_flat));
for behavior_index = 1:number_of_behaviors
    shuffle_mean = mean(LNPStats(behavior_index).shuffle_norms);
    shuffle_std = std(LNPStats(behavior_index).shuffle_norms);
    current_std_above_mean = (LNPStats(behavior_index).BTA_norm - shuffle_mean) / shuffle_std;
    stds_above_shuffle_mean(behavior_index) = current_std_above_mean
    stds_above_shuffle_mean_behavioral_map(L_flat == behavior_index) = current_std_above_mean;
end
stds_above_shuffle_mean_behavioral_map = reshape(stds_above_shuffle_mean_behavioral_map,size(L,1),size(L,2));

[ii,jj] = find(L==0);

watershed_centroids = regionprops(L, 'centroid');
watershed_centroids = vertcat(watershed_centroids.Centroid);
watershed_centroids = round(watershed_centroids);

%special case
watershed_centroids(2,2) = watershed_centroids(2,2) + 15;

%modify col0r map
%my_colormap = parula;
my_colormap = redblue;

%figure
hold on
imagesc(xx,xx,stds_above_shuffle_mean_behavioral_map)
plot(xx(jj),xx(ii),'k.')
axis equal tight off xy
max_color = max(abs(stds_above_shuffle_mean_behavioral_map(:)));
caxis([-max_color, max_color])
colormap(my_colormap)
for behavior_index = 1:size(watershed_centroids,1)-1
    text(xx(watershed_centroids(behavior_index,1)), ...
        xx(watershed_centroids(behavior_index,2)), ...
        behavior_names{behavior_index}, 'color', 'k', ...
        'fontsize', 5, 'horizontalalignment', 'center', ...
        'verticalalignment', 'middle');
end

%plot major watershed divisions
for behavior_index = 1:number_of_behaviors
    binary_L = L == 0;
    dilated_binary_L = imdilate(binary_L,ones(7));
    inner_border_L = and(ismember(L,behavior_index), dilated_binary_L);
    %inner_border_L = bwmorph(inner_border_L, 'thin', inf);
    [ii,jj] = find(inner_border_L==1);
    plot(xx(jj),xx(ii),'.','color',behavior_colors(behavior_index,:))
end

colorbar
title('StDev Above Average Shuffle Norm')