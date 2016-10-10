function [ Behaviors ] = circshift_triggers(Behaviors, BTA_seconds_before_and_after, randomize)
% Shifts the triggers for each track randomly and removes any behavior
% transistions that are too close to the edge
    fps = 14;
    distance_to_edge = fps*BTA_seconds_before_and_after;
    if randomize
        parfor track_index = 1:length(Behaviors)
            shift = unidrnd(size(Behaviors{track_index},2));
            Behaviors{track_index} = circshift(Behaviors{track_index},shift,2);
            Behaviors{track_index}(:,1:distance_to_edge) = false;
            Behaviors{track_index}(:,end-distance_to_edge:end) = false;
        end
    else
        parfor track_index = 1:length(Behaviors)
            Behaviors{track_index}(:,1:distance_to_edge) = false;
            Behaviors{track_index}(:,end-distance_to_edge:end) = false;
        end
    end
end

