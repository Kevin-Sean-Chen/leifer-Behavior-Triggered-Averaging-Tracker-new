function [all_center_lines, CenterlineProperties] = initial_sweep(image_stack, Track)
    %%%%%%STEP 1: define parameters%%%%%%%
    nPoints = 20; % Numbers of points in the contour
    gamma = 15;    %Iteration time step
    ConCrit = .1; %Convergence criteria
    kappa = 2.5;     % Weight of the image force as a whole
    sigma = 1;   %Smoothing for the derivative calculations in the image, causes centerline to loose track
    alpha = 0; % Bending modulus
    beta = 2; %how local the deformation is
    nu = 10;  %spring force
    mu = 5; %repel force
    cd = 3; %cutoff distance for repel force
    xi = 2.5; %the attraction to the found tips;
    l0 = 40; %the expected length of the worm
    sample_size = 10;
       
    %%Internal Energy
    B = internal_energy(alpha, beta, gamma, nPoints);
    
    %%%debug%%%
    number_of_images = size(image_stack,3);
    image_size = [size(image_stack,1), size(image_stack,2)];
    
    %%%%%%STEP 2: get what a normal worm looks like by looking at the images with the highest eccentricities%%%%%%%
    worm_radii = [];
    lengths = [];
    % Sort the values in descending order
    [~,sortIndex] = sort(Track.Eccentricity,'descend');  
    maxIndecies = sortIndex(1:sample_size);
    good_frame_index = maxIndecies(1);    
    for max_index = 1:length(maxIndecies)
        index = maxIndecies(max_index);
        I = reshape(image_stack(:,:,index),image_size);

        %this is a pretty straight worm, sample it
        worm_radii = [worm_radii, find_worm_radius(I)];
        worm_radius = round(mean(worm_radii));
        
        kappa = 2.5/worm_radius; % the image force is scale dependent
        sigma = worm_radius/3; %the gaussian blurring is scale dependent
        cd = worm_radius; %repel distance is scale dependent
        [initial_contour, thin_image] = initialize_contour(I, worm_radius, nPoints);
        
        tips = [initial_contour(1,:); initial_contour(end,:)];
        Fline = external_energy(I, sigma); %External energy from the image
        center_line = relax2tip(initial_contour, tips, kappa, Fline, gamma, B, ConCrit, cd, 0, l0, 0, xi); %calculate the lengths without a length force
        lengths = [lengths, sum(sqrt(sum((center_line(2:end,:)-center_line(1:end-1,:)).^2,2)))];
    end
    l0 = mean(lengths)*0.95; %the length is generally smaller than when the worm is fully extended

    
    %%%%%%STEP 3: preallocate memory for speed%%%%%%%
    CenterlineProperties = {};
    CenterlineProperties(number_of_images).UncertainTips = [];
    all_center_lines = zeros(nPoints,2,number_of_images);
    CenterlineProperties(number_of_images).Score = [];
    CenterlineProperties(number_of_images).Length = [];
    
    step_number = 4;
    while 1
        switch step_number
        case 4
            %%%%%%STEP 4: get the centerline when the worm is kind of straight%%%%%%%
            %grab the image
            index = good_frame_index;
            I = reshape(image_stack(:,:,index),image_size);
            %%%%%%STEP 4A: find initial contour, thin image, and tips%%%%%%%
            [initial_contour, thin_image] = initialize_contour(I, worm_radius, nPoints);
            current_head = initial_contour(1,:);
            current_tail = initial_contour(end,:);
            [~, ~, ~, region_props] = tip_filter(I, 0);
        case {5, 6}
            %%%%%%STEP 5/6A: find initial contour%%%%%%%
            initial_contour = reshape(all_center_lines(:,:,index),nPoints,2);
            if step_number == 5
                %%%%%%STEP 5: go backwards until the first frame is reached%%%%%%%
                index = index - 1;
            else
                %%%%%%STEP 6: go forwards until the last frame is reached%%%%%%%
                index = index + 1;
            end
            I = reshape(image_stack(:,:,index),image_size);

            %%%%%%STEP 5/6A: find tips and thin image%%%%%%%
            [current_head, current_tail, ...
                CenterlineProperties(index).UncertainTips, region_props, thin_image] = ...
                find_tips_centerline_image(I, initial_contour(1,:), initial_contour(end,:), worm_radius);
        end
        
        %%%%%%STEP 4/5/6B: find the image gradient%%%%%%
        composite_image = I + imgaussfilt(double(thin_image)); 
        Fline = external_energy(composite_image, sigma); %External energy from the image
        
        %%%%%%STEP 4/5/6C: find centerline if the tips are certain%%%%%%
        if ~isempty(current_head) && ~isempty(current_tail)
            %both head and tail are certain
            tips = [current_head; current_tail];
            all_center_lines(:,:,index) = relax2tip(initial_contour, tips, kappa, Fline, gamma, B, ConCrit, cd, mu, l0, nu, xi);
            CenterlineProperties(index).Score = score_centerline_whole_image(all_center_lines(:,:,index), initial_contour, I, worm_radius, l0);
        else
            %at least one tip is uncertain
            %%%%%%STEP 5/6D: go through the uncertain tips for the one that
            %%%%%%matches the image%%%%%%
            if ~isempty(current_head)
                heads_to_try = current_head;
                tails_to_try = CenterlineProperties(index).UncertainTips;
            elseif ~isempty(current_tail)
                heads_to_try = CenterlineProperties(index).UncertainTips;
                tails_to_try = current_tail;
            else
                heads_to_try = CenterlineProperties(index).UncertainTips;
                tails_to_try = CenterlineProperties(index).UncertainTips;                    
            end

            %The two tips are the ones that give the best centerline
            %according to our metric
            tip_scores = zeros(size(heads_to_try,1), size(tails_to_try,1));
            tip_centerlines = zeros(size(heads_to_try,1), size(tails_to_try,1), nPoints, 2); %save the centerlines so we don't have to compute it again
            for head_index = 1:size(tip_scores,1)
                for tail_index = 1:size(tip_scores,2)
                    if ismember(heads_to_try(head_index,:), tails_to_try(tail_index,:), 'rows')
                        %the head and the tail are the same
                        tip_scores(head_index,tail_index) = -1;
                    else
                        %the score has not been computed, compute it
                        temp_tips = [heads_to_try(head_index,:); tails_to_try(tail_index,:)];
                        K = relax2tip(initial_contour, temp_tips, kappa, Fline, gamma, B, ConCrit, cd, mu, l0, nu, xi);
                        score = score_centerline_whole_image(K, initial_contour, I, worm_radius, l0); 
                        tip_scores(head_index,tail_index) = score;
                        tip_centerlines(head_index,tail_index, :, :) = K;
                    end
                end
            end

            [max_score,tips_index] = max(tip_scores(:));
            [head_index,tail_index] = ind2sub(size(tip_scores),tips_index);
            tips_found = [heads_to_try(head_index,:); tails_to_try(tail_index,:)];

            all_center_lines(:,:,index) = reshape(tip_centerlines(head_index,tail_index,:,:), nPoints, 2);
            CenterlineProperties(index).Score = max_score;
        end
        
        %%%%%%STEP 4/5/6D: Get the length%%%%%%
        CenterlineProperties(index).Length = sum(sqrt(sum((all_center_lines(2:end,index)-all_center_lines(1:end-1,index)).^2,2)));      
        
%         %%%%%%STEP DEBUG: plot as we go along%%%%%%
%         plot_worm_frame(composite_image, TipsAndCenterlines(index), region_props(1).Eccentricity, Track.Direction(index), thin_image);
%         pause(0.1);
%         index  

        %%%%%%STEP 4/5/6E: look for transition%%%%%%
        switch step_number
        case 4
            if index == 1
                step_number = 6;
            else
                step_number = 5;
            end
        case 5
            if index == 1
                index = good_frame_index;
                if good_frame_index == number_of_images
                    %skip step 6 (i.e. going forwads)
                    break
                else
                    step_number = 6;
                end
            end
        case 6
            if index == number_of_images
                break
            end
        end
    end
    
    %%%%%%STEP 7: get correct head/tail%%%%%%
    direction_vector =  [[Track.Speed].*-cosd([Track.Direction]); [Track.Speed].*sind([Track.Direction])];
    head_vector = reshape(all_center_lines(1,:,:),2,[]) - (image_size(1)/2);    
    tail_vector = reshape(all_center_lines(end,:,:),2,[]) - (image_size(1)/2);
    mean_head_dot_product = mean(dot(head_vector, direction_vector));
    mean_tail_dot_product = mean(dot(tail_vector, direction_vector));
    if mean_tail_dot_product > mean_head_dot_product
        all_center_lines = flip(all_center_lines,1);
    end
    
%     %%%%%%DEBUG: plot from beginning to finish%%%%%%
%     for index = 1:number_of_images
%         I = reshape(image_stack(:,:,index),image_size);
%         plot_worm_frame(I, reshape(all_center_lines(:,:,index),nPoints,2), CenterlineProperties(index), Track.Eccentricity(index), Track.Direction(index), Track.Speed(index), Track.Path(index, :));
%         pause(0.1);
%         index
%     end
%     
end