function [transition_graph,normalized_adj_matrix] = BehavioralTransitionGraph(Tracks, number_of_behaviors, plotting, ratio_included)
    % Generates a normalized adjacency matrix from tracks
% Tracks = load_single_folder('F:\Mochi\Data\20161028\Data20161028_130913', {'BehavioralTransition'});
    if nargin < 2
        number_of_behaviors = 12;
    end
    if nargin < 3
        plotting = false;
    end
    if nargin < 4
        ratio_included = 0.5;
    end
    

    %construct the adjacency matrix
    adj_matrix = zeros(number_of_behaviors);
    for track_index = 1:length(Tracks)
        if size(Tracks(track_index).BehavioralTransition,1) > 1
         from_indecies = Tracks(track_index).BehavioralTransition(1:end-1,1);
         to_indecies = Tracks(track_index).BehavioralTransition(2:end,1);
            for transition_index = 1:length(from_indecies)
                %skip the behavior 0
                if from_indecies(transition_index) > 0 && to_indecies(transition_index) > 0
                     adj_matrix(from_indecies(transition_index),to_indecies(transition_index)) = ...
                         adj_matrix(from_indecies(transition_index),to_indecies(transition_index)) + 1;
                end
            end
        end
    end

    %% find the normalized adjacency matrix and turn it into a graph
    
    %normalize by the total number of events going into a behavior
    normalized_adj_matrix = adj_matrix ./ repmat(sum(adj_matrix,1),number_of_behaviors,1);
    for behavior_index = 1:number_of_behaviors
        %go through each into behavior and remove insignificant ones
        behaviors_going_into = normalized_adj_matrix(:,behavior_index);
        behaviors_going_into_sorted = sort(behaviors_going_into, 'descend');
        behaviors_going_into_cumsum = cumsum(behaviors_going_into_sorted);
        cut_off_ratio = behaviors_going_into_sorted(find(behaviors_going_into_cumsum>ratio_included,1,'first'));
        if isempty(cut_off_ratio)
            %all the behaviors are included
            cut_off_ratio = 0;
        end
        behaviors_going_into(behaviors_going_into<cut_off_ratio) = 0;
        normalized_adj_matrix(:,behavior_index) = behaviors_going_into;
    end

%     %normalize by all transitions
%     normalized_adj_matrix = adj_matrix ./ sum(adj_matrix(:));
%     behaviors_sorted = sort(normalized_adj_matrix(:), 'descend');
%     behaviors_sorted_cumsum = cumsum(behaviors_sorted);
%     cut_off_ratio = behaviors_sorted(find(behaviors_sorted_cumsum>ratio_included,1,'first'));
%     if isempty(cut_off_ratio)
%         %all the behaviors are included
%         cut_off_ratio = 0;
%     end    
%     normalized_adj_matrix(normalized_adj_matrix<cut_off_ratio) = 0;

    %%
    transition_graph = digraph(normalized_adj_matrix);

    %% plot the density diagram
    if plotting
        LWidths = 10*transition_graph.Edges.Weight/max(transition_graph.Edges.Weight);

        load('reference_embedding.mat')

        maxDensity = max(density(:));
        [ii,jj] = find(L==0);

        watershed_centroids = regionprops(L, 'centroid');
        watershed_centroids = vertcat(watershed_centroids.Centroid);
        watershed_centroids = round(watershed_centroids);
        watershed_centroids = watershed_centroids(1:end-1,:);

        %modify jet map
        my_colormap = jet;
        my_colormap(1,:) = [1 1 1];

        figure
        hold on
        imagesc(xx,xx,density)
        plot(xx(jj),xx(ii),'k.')
        axis equal tight off xy
        caxis([0 maxDensity * .8])
        colormap(my_colormap)

        plot(transition_graph,'EdgeLabel',transition_graph.Edges.Weight,'LineWidth',LWidths, ...
            'ArrowSize', 25, 'EdgeColor', 'm', ...
            'XData',xx(watershed_centroids(:,1))','YData',xx(watershed_centroids(:,2))');

        hold off
    end
end