function thinned_image_outline = find_possible_centerline_image(BW, best_thinning_iteration)
    %find the centerline image by removing best_thinning_iteration pixels 
    %from the outside of the BW image and finding the outline
    BW = bwmorph(BW, 'fill');
    first_thinned_image = bwmorph(BW, 'thin', best_thinning_iteration);
    first_thinned_image_outline = bwmorph(first_thinned_image, 'remove');
    bridged_thinned_image = bwmorph(first_thinned_image_outline, 'close');
    thinned_image_outline = bwmorph(bridged_thinned_image, 'thin', Inf);
    
    %debug
    %imshow(Image + thinned_image_outline,[])

%     pause(0.1);
end