function [flip_needed, flip_possible]  = determine_if_head_tail_flip(head_direction_dot_product, tail_direction_dot_product, Prefs)
    %determines if a head/tail flip is needed
    %global Prefs
    
    time_threshold = Prefs.MaxBackwardsFrames; %number of frames to make a call
    
%     if isfield(Prefs, 'MaxBackwardsFrames')
%         time_threshold = Prefs.MaxBackwardsFrames;
%     else
        

    flip_needed = false;
    flip_possible = mean(tail_direction_dot_product) > mean(head_direction_dot_product);
    
    if length(head_direction_dot_product) < time_threshold
        return
    else
        upper_quantile_head_direction_dot_product = quantile(head_direction_dot_product, 0.75);
        lower_quantile_tail_direction_dot_product = quantile(tail_direction_dot_product, 0.25);
        if lower_quantile_tail_direction_dot_product > upper_quantile_head_direction_dot_product
            flip_needed = true;               
        end
    end
end