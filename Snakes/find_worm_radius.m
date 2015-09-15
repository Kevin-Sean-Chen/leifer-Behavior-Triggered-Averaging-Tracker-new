function iteration = find_worm_radius(Image, best_threshold)
    % get the worm radius by looking at how many iterations it takes for
    % thinning to converge
    BW = im2bw(Image, best_threshold);
    BW = bwmorph(BW, 'fill');
    
    last_thinned_image = false(size(Image));
    iteration = 1;
    
    while 1
        thinned_image = bwmorph(BW, 'thin', iteration);
        if isequal(last_thinned_image,thinned_image)
            break
        else
            last_thinned_image = thinned_image;
            iteration = iteration + 1;
        end
    end
    
    iteration = iteration - 2; %thinning correction
%     imshow(thinned_image, [])
%     pause();
    %iteration = iteration;
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