% load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\AML67\behavior_map_no_subsampling\Embedding_LNPFit\LNPfit_behaviors_reordered_20171030.mat')
% LNPStats = LNPStats_nondirectional_ret;

load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\AML67\behavior_map_no_subsampling\Embedding_LNPFit\LNPfit_noret_20180316.mat')
LNPStats = LNPStats_nondirectional;
meanLEDPower = stdLEDPower_nondirectional;
stdLEDPower=stdLEDPower_nondirectional;
load('reference_embedding.mat')
number_of_behaviors = max(L(:))-1;


%% hiearchical clustering of kernels
%calculate distance information for kernels
% kernels = vertcat(LNPStats.linear_kernel);
% %normalize each stimulus so that we get good coverage
insignificant_indecies = [];
significant_linear_kernels = [];
for behavior_index = 1:number_of_behaviors
%     BTAs(behavior_index,:) = BTAs(behavior_index,:) - mean(BTAs(behavior_index,:));
    if all(LNPStats(behavior_index).linear_kernel == 0)
        %all zero kernel, ignore
        insignificant_indecies = [insignificant_indecies, behavior_index];
    else
        kernel_max = max(abs(LNPStats(behavior_index).linear_kernel));
        scale = avg_power ./ kernel_max;
        significant_linear_kernels = [significant_linear_kernels; scale.*LNPStats(behavior_index).linear_kernel];
    end
end
behavior_names(insignificant_indecies) = [];
behavior_colors(insignificant_indecies) = [];


watershed_centroids = regionprops(L, 'centroid');
watershed_centroids = vertcat(watershed_centroids.Centroid);
watershed_centroids = round(watershed_centroids);
watershed_centroids(insignificant_indecies,:) = [];
watershed_centroids(end,:) = [];

figure

subplot(1,2,1)
kernel_distances = squareform(pdist(significant_linear_kernels));
kernel_linkage_tree = linkage(kernel_distances);
dendrogram(kernel_linkage_tree,'Labels',behavior_names,'Orientation','left','Reorder',[1,2,3,4,5,6]);
xlabel('Kernel Distance (a.u.)')
title('Scaled Kernel L2 Norm as Distance')
%
subplot(1,2,2)
embedding_distances = squareform(pdist(watershed_centroids));
embedding_linkage_tree = linkage(embedding_distances);
dendrogram(embedding_linkage_tree,'Labels',behavior_names,'Orientation','right','Reorder',[1,2,3,4,5,6]);
xlabel('Behavioral Map Distance (a.u.)')
title('Behavioral Map Euclidean Distance for Watershed Centroids')
set(gca,'YTickLabel',[]);

%% supplement with all non-directional kernels and nonlinearities
PlotBehavioralMappingExperimentGroup(LNPStats,meanLEDPower,stdLEDPower_nondirectional, L, density, xx)

%% 