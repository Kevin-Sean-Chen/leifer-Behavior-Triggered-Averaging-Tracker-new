function [tip_centroids, L, BW, region_props]  = tip_filter(I, thresh)
    %Use a Mexican hat-esque filter to find tips. parameters are hardcoded

    Ibin = im2bw(I,thresh);
    cc = bwconncomp(Ibin);
    stats = regionprops(cc, 'Area');
    idx = find([stats.Area]>20);
    BW = ismember(labelmatrix(cc), idx);

    %Create Mexican hat-esque filter, apply to image to get tips
    [X,Y] = meshgrid(-5:5, -5:5);
    circle = double((X.^2 + Y.^2)<4) - .15; %Create circular filter
    Icirc = imfilter(BW,circle);
    L = bwlabel(Icirc);
    all_stats = regionprops(L, 'Centroid');
    region_props = regionprops(BW, 'Centroid', 'Area', 'Eccentricity'); %return the original region_property 
    tip_centroids = reshape([all_stats.Centroid], 2, [])';
    tip_centroids = fliplr(tip_centroids);
%     imshow(Icirc, []);
%     hold on
%     plot(round(tip_centroids(:,1)), round(tip_centroids(:,2)), 'go')
%     hold off

end