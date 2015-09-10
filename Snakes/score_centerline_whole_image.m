function score = score_centerline_whole_image(K, Old_K, I, worm_radius, l0)
    % the score is the dot product of the image and a generaged image from
    % the centerline minus the displacement score

    %%%find the image score, which the fraction of intensities covered by
    %%%the centerline
    binary_image = im2bw(I,0);
    generated_binary_image = generate_binary_image_from_centerline(K, size(binary_image), worm_radius);
%     Image = Image .* double(im2bw(Image,best_threshold/255));
    linearized_image = binary_image(:);
    linearized_generated_binary_image = generated_binary_image(:);
%     intensity_sum = sum(linearized_image);
%     image_score = dot(linearized_generated_binary_image, linearized_image)/intensity_sum;
    union_total = sum(or(linearized_image, linearized_generated_binary_image));
    intersection_total = sum(and(linearized_image, linearized_generated_binary_image));
    image_score = intersection_total / union_total;
    
    if ~isempty(Old_K)
        %%%find the displacement score which is the average displacement
        %%%per point over the body length of the worm capped at 1
        displacement_score = 1 - (find_displacement_between_two_centerlines(K, Old_K)/size(K,1)/l0);
        displacement_score = min(displacement_score, 1);
        score = image_score + displacement_score;
    else
        score = image_score + 1;
    end
    
%     %debug
%     subplot(1,2,1), imshow(Image,[])
%     hold on
%     plot(K(:,2), K(:,1), 'g-');
%     hold off
%     
%     subplot(1,2,2), imshow(generated_image_binary,[])
%     hold on
%     plot(K(:,2), K(:,1), 'g-');
%     hold off
%     
%     score
%     pause(0.1);
end