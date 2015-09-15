function [center_line_interp, thin_image_returned] = initialize_contour(Image, worm_radius, nPoints, best_threshold)
    %Initializes the contour given a threshold value

    BW = im2bw(Image,best_threshold);
    thin_image_returned = find_possible_centerline_image(BW, worm_radius);
    thin_image = thin_image_returned;
    endpoints = bwmorph(bwmorph(thin_image,'endpoints'),'shrink',Inf);
    
    %grab any endpoint to start the algorithm
    [endpoint_x, endpoint_y] = ind2sub(size(Image),find(endpoints,1,'first'));
    endpoint = [endpoint_x, endpoint_y];
    thin_image(endpoint_x, endpoint_y) = 0;
    
    center_line = endpoint;
    while sum(thin_image(:)) > 0
        %the next point along the centerline is the closest pixel to the
        %current end of the centerline
        [pixels_left_x, pixels_left_y] = ind2sub(size(Image),find(thin_image));
        pixels_left = [pixels_left_x, pixels_left_y];
        [distance, next_index] = pdist2(pixels_left, center_line(end,:),'euclidean', 'Smallest', 1);
        if distance > size(Image,1)*0.2
            %the closest pixel cannot jump that much (to get rid of spurs
            break
        end
        center_line = [center_line; pixels_left(next_index,:)];
        thin_image(pixels_left(next_index,1), pixels_left(next_index,2)) = 0;
    end

    dis=[0;cumsum(sqrt(sum((center_line(2:end,:)-center_line(1:end-1,:)).^2,2)))];

    % Resample to make uniform points
    center_line_interp(:,1) = interp1(dis,center_line(:,1),linspace(0,dis(end),nPoints));
    center_line_interp(:,2) = interp1(dis,center_line(:,2),linspace(0,dis(end),nPoints));
end