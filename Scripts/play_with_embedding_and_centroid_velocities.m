%get all raw points of embeddings and velocities
all_embeddings = vertcat(allTracks_GWN_ret(:).Embeddings,allTracks_GWN_noret(:).Embeddings);
all_velocities = horzcat(allTracks_GWN_ret(:).Velocity,allTracks_GWN_noret(:).Velocity);
max_velocity = max(abs(all_velocities));

%plot all the points with velocity as the color
numpoints = 1000000;
selected_indecies = randperm(length(all_velocities));
selected_indecies = selected_indecies(1:numpoints);
figure
colormap(redblue)
whitebg([0 0 0])
scatter(all_embeddings(selected_indecies,1),all_embeddings(selected_indecies,2),10,all_velocities(selected_indecies),'filled'); 
axis equal xy
caxis([-max_velocity*0.5, max_velocity*0.5])
colorbar;

%% plot watershed regions with average velocity

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
[ii,jj] = find(L==0);
watershed_centroids = regionprops(L, 'centroid');
watershed_centroids = vertcat(watershed_centroids.Centroid);
watershed_centroids = round(watershed_centroids);

whitebg([1 1 1])
figure
hold on
imagesc(xx,xx,labeled_avg_velocities)
plot(xx(jj),xx(ii),'k.')
axis equal off xy
caxis([-max_avg_velocities  max_avg_velocities])
colormap(my_colormap)

for watershed_region = 1:size(watershed_centroids,1)-1
    text(xx(watershed_centroids(watershed_region,1)), ...
        xx(watershed_centroids(watershed_region,2)), ...
        num2str(round(watershed_avg_velocities(watershed_region),2)), 'color', 'k', ...
        'fontsize', 10, 'horizontalalignment', 'center', ...
        'verticalalignment', 'middle');
end
hold off
colorbar
