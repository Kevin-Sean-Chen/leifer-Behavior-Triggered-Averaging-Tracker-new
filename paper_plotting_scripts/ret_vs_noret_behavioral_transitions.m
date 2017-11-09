
%% play with transition plots
cut_off_ratio = 0.8;
fold_cut_off = 0.7;
%top_behavior_transitions_to_display = 0.25;
% %get transition graph
ret_transition_graph = BehavioralTransitionGraph(allTracks_GWN_ret, number_of_behaviors, true, cut_off_ratio);
noret_transition_graph = BehavioralTransitionGraph(allTracks_GWN_noret, number_of_behaviors, true, cut_off_ratio);

[~, ret_normalized_adj_matrix, ~, ~, ret_behavioral_ratios] = BehavioralTransitionGraph(allTracks_GWN_ret, number_of_behaviors, true, 1);
[~, noret_normalized_adj_matrix, ~, ~, noret_behavioral_ratios] = BehavioralTransitionGraph(allTracks_GWN_noret, number_of_behaviors, true, 1);
diag_removed_noret_normalized_adj_matrix = noret_normalized_adj_matrix + eye(length(noret_normalized_adj_matrix));
%compare the two graphs for changes in transition rates
ret_to_noret_transition_ratio = ret_normalized_adj_matrix  ./ diag_removed_noret_normalized_adj_matrix;
ret_to_noret_transition_percent_change = (ret_normalized_adj_matrix - noret_normalized_adj_matrix) ./ diag_removed_noret_normalized_adj_matrix .* 100;

nozero_ret_to_noret_change = ret_to_noret_transition_ratio+eye(length(noret_normalized_adj_matrix));
abs_ret_to_noret_fold_change = abs(log2(nozero_ret_to_noret_change));

%rank the largest changes, and only use the top hits
ret_to_noret_transition_percent_change(abs_ret_to_noret_fold_change<fold_cut_off) = 0;
ret_to_noret_transition_positive_change = ret_to_noret_transition_percent_change;
ret_to_noret_transition_positive_change(ret_to_noret_transition_positive_change<0) = 0;
positive_transition_graph = digraph(ret_to_noret_transition_positive_change);
ret_to_noret_transition_negative_change = ret_to_noret_transition_percent_change;
ret_to_noret_transition_negative_change(ret_to_noret_transition_negative_change>0) = 0;
negative_transition_graph = digraph(abs(ret_to_noret_transition_negative_change));

%compare the two graphs for changes in behavioral ratios 
ret_to_noret_behavioral_percent_change = (ret_behavioral_ratios - noret_behavioral_ratios) ./ ret_behavioral_ratios .* 100;


%plot it
load('reference_embedding.mat')
maxDensity = max(density(:));
[ii,jj] = find(L==0);
watershed_centroids = regionprops(L, 'centroid');
watershed_centroids = vertcat(watershed_centroids.Centroid);
watershed_centroids = round(watershed_centroids);
watershed_centroids = watershed_centroids(1:end-1,:);

%special case
watershed_centroids(2,2) = watershed_centroids(2,2) + 15;

%modify jet map
my_colormap = othercolor('OrRd9');
my_colormap(1,:) = [1 1 1];

figure
hold on

plot_triangle(xx(watershed_centroids(:,1)),xx(watershed_centroids(:,2)), ...
round(abs(ret_to_noret_behavioral_percent_change)*4), behavior_colors,(ret_to_noret_behavioral_percent_change < 0));

for region_index = 1:size(watershed_centroids,1)
text(xx(watershed_centroids(region_index,1)), ...
    xx(watershed_centroids(region_index,2)), ...
    [behavior_names{region_index}, newline, num2str(round(ret_to_noret_behavioral_percent_change(region_index))), '%'], 'color', 'k', ...
    'fontsize', 16, 'horizontalalignment', 'center', ...
    'verticalalignment', 'middle');
end
plot(xx(jj),xx(ii),'k.')
axis equal tight off xy

LWidths = 10*positive_transition_graph.Edges.Weight/max(abs(ret_to_noret_transition_percent_change(:)));
edge_weights = positive_transition_graph.Edges.Weight;
graph_edge_label = cell(1,length(edge_weights));
for edge_index = 1:length(edge_weights)
    graph_edge_label{edge_index} = [num2str(round(edge_weights(edge_index))), '%'];
end
plot(positive_transition_graph,'EdgeLabel',graph_edge_label,'LineWidth',LWidths, ...
'ArrowSize', 25, 'EdgeColor', 'g', 'EdgeAlpha', 0.5, 'NodeColor', 'none', ...
'NodeLabel', {}, ...
'XData',xx(watershed_centroids(:,1))','YData',xx(watershed_centroids(:,2))');


LWidths = 10*negative_transition_graph.Edges.Weight/max(abs(ret_to_noret_transition_percent_change(:)));
edge_weights = negative_transition_graph.Edges.Weight;
graph_edge_label = cell(1,length(edge_weights));
for edge_index = 1:length(edge_weights)
    graph_edge_label{edge_index} = ['-',num2str(round(edge_weights(edge_index))), '%'];
end
plot(negative_transition_graph,'EdgeLabel',graph_edge_label,'LineWidth',LWidths, ...
'ArrowSize', 25, 'EdgeColor', 'r', 'EdgeAlpha', 0.5, 'NodeColor', 'none', ...
'NodeLabel', {}, ...
'XData',xx(watershed_centroids(:,1))','YData',xx(watershed_centroids(:,2))');

