function [] = plot_worm_frame(I, center_lines, CenterlineProperties, eccentricity, direction, speed, centroid, debugimage)
    %used for debugging
    hold off;
    if nargin > 7
        %debugimage inputted
        imshow(I + debugimage, []);
    else
        imshow(I, []);
    end

    hold on
    plot(center_lines(:,2), center_lines(:,1), '-g')
    
    if ~isempty(CenterlineProperties(1).UncertainTips)
        plot(CenterlineProperties(1).UncertainTips(:,2), CenterlineProperties(1).UncertainTips(:,1), 'oy')
    end
    %head
    plot(center_lines(1,2), center_lines(1,1), 'og')
    %tail
    plot(center_lines(end,2), center_lines(end,1), 'ob')

    %direction
    quiver(size(I,2)/2, size(I,1)/2, sind(direction)*speed*100, -cosd(direction)*speed*100, 'AutoScale','off');
    %title (['Eccentricity = ', num2str(eccentricity)]);    
    title (['( ', num2str(centroid(1,1)),' , ', num2str(centroid(1,1)),' )']);
    text(20, 20, num2str(CenterlineProperties(1).Score), 'Color', 'y');
    hold off;
end