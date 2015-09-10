function [flip_needed]  = determine_if_head_tail_flip(head_direction_dot_product, tail_direction_dot_product)
    %determines if a head/tail flip is needed
    time_threshold = 14*10; %number of frames to make a call, hard coded for now, use global var later
    flip_needed = false;
            
    if length(head_direction_dot_product) < time_threshold
        return
    else
        mean_head_direction_dot_product = mean(head_direction_dot_product);
        mean_tail_direction_dot_product = mean(tail_direction_dot_product);
        if mean_tail_direction_dot_product > mean_head_direction_dot_product
            flip_needed = true;
        end
    end
    
end