function generated_image = generate_binary_image_from_centerline(K, image_size, worm_radius)
    % given the centerline and the image size, this function creates a
    % image that looks like the original worm
    
    generated_image_linear = zeros(image_size(1)*image_size(2),1);
    
    for i = 1:size(K,1)-1
        pixel_positions = bresenham(K(i,1), K(i,2), K(i+1,1), K(i+1,2));
        %all_pixel_positions = [all_pixel_positions; pixel_positions(2:end,:)];
        try
            linearSub = sub2ind(image_size, pixel_positions(:,1), pixel_positions(:,2));
            generated_image_linear(linearSub) = 1;
        catch
            %when the centerline is out of frame, an error occurs
        end
    end
    
    generated_image = reshape(generated_image_linear,image_size(1),image_size(2));
    generated_image = imdilate(generated_image, ones(worm_radius));
    
    %imshow(generated_image, []);
    %score = sum(Image(linearSub));
end