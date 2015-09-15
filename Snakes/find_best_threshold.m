function threshold = find_best_threshold(Image)
    % get best binary threshold for the worm

    threshold = 0;
    %imshow(Image, []);
    while threshold < 30
        BW = im2bw(Image, threshold/255);
        BW = bwmorph(BW, 'fill');
        STATS = regionprops(BW,'Eccentricity');
%         imshow(BW, []);
%         STATS
%         threshold
%         pause
        if STATS(1).Eccentricity > 0.97
            threshold = threshold / 255;
            return
        else
            threshold = threshold + 1;
        end
    end
    threshold = -1;
end