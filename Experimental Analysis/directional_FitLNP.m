function [LNPStats, meanLEDPower, stdLEDPower] = directional_FitLNP(Tracks,folder_indecies,folders)
%directional_FitLNP takes in tracks and outputs the parameters of the LNP
%based on which behaviors transition into which other one
    
    %get the number of behaviors
    all_transitions = vertcat(Tracks.BehavioralTransition);
    number_of_behaviors = max(all_transitions(:,1));
    clear all_transitions
    
    %get transition graph
    transition_graph = BehavioralTransitionGraph(Tracks, number_of_behaviors);
    
    %get a list of behavioral triggers
    edges = table2array(transition_graph.Edges);
    edges = edges(:,1:2);
    Tracks(1).Behaviors = [];
    number_of_edges = size(edges,1);
    
    for track_index = 1:length(Tracks)
        triggers = false(number_of_edges, length(Tracks(track_index).Frames)); %a binary array of when behaviors occur
        for edge_index = 1:number_of_edges
            current_behavioral_transition = Tracks(track_index).BehavioralTransition(:,1)';
            transition_indecies = strfind(current_behavioral_transition,edges(edge_index,:))+1;
            %transition into
            transition_start_frames = Tracks(track_index).BehavioralTransition(transition_indecies,2);
            triggers(edge_index,transition_start_frames) = true;
        end
        Tracks(track_index).Behaviors = triggers(:,1:length(Tracks(track_index).Frames));
    end
    
    % fit the LNP models
    [LNPStats, meanLEDPower, stdLEDPower] = FitLNP(Tracks,folder_indecies,folders);

    % update which edges are involved
    LNPStats(1).Edges = [];
    for edge_index = 1:number_of_edges
        LNPStats(edge_index) = edges(edge_index,:);
    end
    
end

