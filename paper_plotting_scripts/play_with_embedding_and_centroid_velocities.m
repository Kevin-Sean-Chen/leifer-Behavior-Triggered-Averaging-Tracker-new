%get all raw points of embeddings and velocities
% all_embeddings = vertcat(allTracks_GWN_ret(:).Embeddings,allTracks_GWN_noret(:).Embeddings);
% all_velocities = horzcat(allTracks_GWN_ret(:).Velocity,allTracks_GWN_noret(:).Velocity);
all_embeddings = vertcat(allTracks(:).Embeddings);
all_velocities = horzcat(allTracks(:).Velocity);
max_velocity = max(abs(all_velocities));

% %plot all the points with velocity as the color
% numpoints = 1000000;
% selected_indecies = randperm(length(all_velocities));
% selected_indecies = selected_indecies(1:numpoints);
% figure
% colormap(redblue)
% whitebg([0 0 0])
% scatter(all_embeddings(selected_indecies,1),all_embeddings(selected_indecies,2),10,all_velocities(selected_indecies),'filled'); 
% axis equal xy
% caxis([-max_velocity*0.5, max_velocity*0.5])
% colorbar;

%% plot watershed regions with average velocity, while grouping behaviors
behavior_group{1} = [1,2,3,4,5,6];
behavior_group{2} = [7];
behavior_group{3} = [8,9];


%L = encapsulate_watershed_matrix(L);


all_behavior_annotations = behavioral_space_to_behavior(all_embeddings, L, xx);
watershed_avg_velocities = zeros(1,max(L(:)-1));

for watershed_region = 1:max(L(:)-1)
    watershed_avg_velocities(watershed_region) = mean(all_velocities(all_behavior_annotations == watershed_region));
end

max_avg_velocity = max(abs(watershed_avg_velocities));
L_flat = L(:);
labeled_avg_velocities = zeros(size(L_flat));
max_avg_velocities = max(abs(watershed_avg_velocities));

for watershed_region = 1:max(L(:)-1)
    labeled_avg_velocities(L_flat == watershed_region) = watershed_avg_velocities(watershed_region);
end
labeled_avg_velocities = reshape(labeled_avg_velocities,size(L,1),size(L,2));

%modify color map
my_colormap = redblue;

watershed_centroids = regionprops(L, 'centroid');
watershed_centroids = vertcat(watershed_centroids.Centroid);
watershed_centroids = round(watershed_centroids);

figure
whitebg([1 1 1])
hold on
imagesc(xx,xx,labeled_avg_velocities)
axis equal off xy
caxis([-max_avg_velocities  max_avg_velocities])
colormap(my_colormap)

larger_region_colors = [1,0,0;0.5,0,0.5;0,0,1];

[ii,jj] = find(L==0);
plot(xx(jj),xx(ii),'k.')

%plot major watershed divisions
for behavior_group_index = 1:length(behavior_group)
    combined_L = combine_watersheds(L, behavior_group{behavior_group_index});
    combined_binary_L = combined_L == 0;
    dilated_combined_binary_L = imdilate(combined_binary_L,ones(7));
    inner_border_L = and(ismember(L,behavior_group{behavior_group_index}), dilated_combined_binary_L);
    inner_border_L = bwmorph(inner_border_L, 'thin', inf);
    [ii,jj] = find(inner_border_L==1);
    plot(xx(jj),xx(ii),'.','color',larger_region_colors(behavior_group_index,:))
end

for watershed_region = 1:size(watershed_centroids,1)-1
    text(xx(watershed_centroids(watershed_region,1)), ...
        xx(watershed_centroids(watershed_region,2)), ...
        num2str(round(watershed_avg_velocities(watershed_region),2)), 'color', 'k', ...
        'fontsize', 10, 'horizontalalignment', 'center', ...
        'verticalalignment', 'middle');
end
hold off
colorbar

