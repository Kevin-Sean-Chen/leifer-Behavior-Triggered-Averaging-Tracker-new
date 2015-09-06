function score = score_centerline_whole_image(K, Old_K, Image, worm_radius, l0)
    % the score is the dot product of the image and a generaged image from
    % the centerline minus the displacement score

    %%%find the image score, which the fraction of intensities covered by
    %%%the centerline
    generated_image_binary = generate_binary_image_from_centerline(K, size(Image), worm_radius);
%     Image = Image .* double(im2bw(Image,best_threshold/255));
    linearized_image = Image(:);
    intensity_sum = sum(linearized_image);
    image_score = dot(generated_image_binary(:), linearized_image)/intensity_sum;

    if ~isempty(Old_K)
        %%%find the displacement score which is the average displacement
        %%%per point over the body length of the worm capped at 1
        Kdis = (Old_K - K).^2;
        displacement_score = 1 - ((sum(sqrt(Kdis(1:end,1)+Kdis(1:end,2))))/size(K,1)/l0);
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