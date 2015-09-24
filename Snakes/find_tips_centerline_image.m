 function [certain_head, certain_tail, uncertain_tips, has_ring, thin_image, BW]  = find_tips_centerline_image(I, prev_head, prev_tail, worm_radius, best_threshold)
    %loop through threholds to see if there is a hole in the image, if so,
    %get the branching tips when the hole is the biggest
    
    max_tip_displacement_per_frame = 10; %pixels the tips are allowed to move
    prev_tips = [prev_head; prev_tail];

    %% STEP 1: use mexican hat filter to find tips %%
    [mex_tips, labeled_filtered_image, BW] = tip_filter(I, best_threshold);
    labeled_filtered_image = imdilate(labeled_filtered_image, ones(3)); %dilate the tips
    
    %% STEP 2: thin for end points%%%
    thin_image = find_possible_centerline_image(BW, worm_radius); %update 3 to variable
    endpoint_image = bwmorph(thin_image,'endpoint');
    [endpoints_x, endpoints_y] = ind2sub(size(endpoint_image),find(endpoint_image));
    endpoints = [endpoints_x, endpoints_y];

    %% STEP 3: get head and tail if possible%%%   
    potentially_certain_tips = []; %we will check for tip displacement later
    endpoints_accounted_for = [];
    mex_tips_accounted_for = [];
    for endpoint_index = 1:size(endpoints,1)
        mex_tip_index = labeled_filtered_image(endpoints(endpoint_index, 1), endpoints(endpoint_index, 2));
        if mex_tip_index > 0
            %the tip is picked up by both algorithms
            potentially_certain_tips = [potentially_certain_tips; endpoints(endpoint_index, :)];
            mex_tips_accounted_for = [mex_tips_accounted_for, mex_tip_index];
            endpoints_accounted_for = [endpoints_accounted_for, endpoint_index];
        end
    end
    % only add the unaccounted for mexican hat filter tips to the list
    % of uncertain tips
    mex_tips(mex_tips_accounted_for,:) = [];
    %ensures that the two tips are never assigned to the same previous
    %tip
    [matched_tips, leftover_endpoints] = assign_tips(prev_tips, potentially_certain_tips, max_tip_displacement_per_frame);
    certain_head = [];
    certain_tail = [];
    if matched_tips(1,1) > 0;
        %head is found
        certain_head = matched_tips(1,:);
    end
    if matched_tips(2,1) > 0;
        %tail is found
        certain_tail = matched_tips(2,:);
    end
    endpoints(endpoints_accounted_for, :) = []; %remove all the endpoints that were pulled
    endpoints = [endpoints; leftover_endpoints]; %put them back sans the certain tip

    %% STEP 4: find branch points if there is a ring%%%   
    possible_ring_image = bwmorph(bwmorph(thin_image,'shrink',Inf), 'clean');
    if sum(possible_ring_image(:)) > 0
        %there is a hole detected, get the branchpoints
        thin_branchpoint_image = bwmorph(thin_image,'branchpoints');
        possible_branchpoint_image = thin_branchpoint_image .* bwmorph(possible_ring_image, 'dilate');
        [possible_branchpoint_x, possible_branchpoint_y] = ind2sub(size(possible_branchpoint_image),find(possible_branchpoint_image));
        branching_points = [possible_branchpoint_x, possible_branchpoint_y];
        has_ring = true;
    else
        branching_points = [];
        has_ring = false;
    end
        
    %% STEP 5: return the uncertain tips%%%
    uncertain_tips = [endpoints; branching_points; mex_tips];
    if size(certain_head,1) + size(certain_tail,1) + size(uncertain_tips,1) < 2
        uncertain_tips = [uncertain_tips; prev_head; prev_tail];
    end
end