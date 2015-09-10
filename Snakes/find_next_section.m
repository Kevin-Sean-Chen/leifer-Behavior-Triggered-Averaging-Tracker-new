function [start_index, end_index, min_dist_index]  = find_next_section(annotation, current_index, backwards_or_forwards, all_center_line_tips)
    %finds the next section bounded by 1s going either forwards or backwards in time
    if strcmp(backwards_or_forwards, 'b')
        %going backwards
        %find where the next omega turn starts
        temp_annotation = annotation(1:current_index);
        start_index = strfind(temp_annotation, [true, false]);
        if ~isempty(start_index)
            start_index = start_index(end);
        else
            end_index = [];
            min_dist_index = [];
            return
        end
        %find where the next omega turn ends
        temp_annotation = annotation(1:start_index);
        end_index = strfind(temp_annotation, [false, true]);
        if ~isempty(end_index)
            end_index = end_index(end) + 1;
        else
            end_index = 1;
        end
        if nargin > 3
            %find where are the two tips closest together, and thus have the most
            %likely chance of flipping
            all_tips = all_center_line_tips(:, :, end_index:start_index);
            all_tip_distances = squeeze(sqrt((all_tips(end,1,:)-all_tips(1,1,:)).^2 + (all_tips(end,2,:)-all_tips(1,2,:)).^2));
            [~, min_index] = min(all_tip_distances);
            min_dist_index = end_index + min_index - 1;
        else
            min_dist_index = round(mean([start_index, end_index]));
        end
    else
        %going forwards
        %find where the next omega turn starts
        temp_annotation = annotation(current_index:end);
        start_index = strfind(temp_annotation, [false, true]);
        if ~isempty(start_index)
            start_index = start_index(1) + current_index;
        else
            end_index = [];
            min_dist_index = [];
            return
        end
        %find where the next omega turn ends
        temp_annotation = annotation(start_index:end);
        end_index = strfind(temp_annotation, [true, false]);
        if ~isempty(end_index)
            end_index = end_index(1) + start_index - 1;
        else
            end_index = length(annotation);
        end
        if nargin > 3
            %find where are the two tips closest together, and thus have the most
            %likely chance of flipping
            all_tips = all_center_line_tips(:, :, start_index:end_index);
            all_tip_distances = squeeze(sqrt((all_tips(end,1,:)-all_tips(1,1,:)).^2 + (all_tips(end,2,:)-all_tips(1,2,:)).^2));
            [~, min_index] = min(all_tip_distances);
            min_dist_index = start_index + min_index - 1;
        else
            min_dist_index = round(mean([start_index, end_index]));
        end
    end  
end