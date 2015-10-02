function [] = plot_worm_frame(I, center_lines, UncertainTips, eccentricity, direction, speed, score, plotting_index, debugimage)
%     IWFig = findobj('Tag', ['IWFig', num2str(plotting_index)]);
%     if isempty(IWFig)
%         IWFig = figure('Tag', ['IWFig', num2str(plotting_index)]);
%     else
%         figure(IWFig);
%     end
    %used for debugging
    hold off;
    if nargin > 8
        %debugimage inputted
        imshow(I + debugimage, [], 'InitialMagnification', 300, 'Border','tight');
    else
        imshow(I, [], 'InitialMagnification', 300, 'Border','tight');
    end

    hold on
    plot(center_lines(:,2), center_lines(:,1), '-g')
    
    if ~isempty(UncertainTips.Tips)
        plot(UncertainTips.Tips(:,2), UncertainTips.Tips(:,1), 'oy')
    end
    %head
    plot(center_lines(1,2), center_lines(1,1), 'og')
    %tail
    plot(center_lines(end,2), center_lines(end,1), 'ob')

    
    %direction
    quiver(size(I,2)/2, size(I,1)/2, sind(direction)*speed*100, -cosd(direction)*speed*100, 'AutoScale','off');
    %title (['Eccentricity = ', num2str(eccentricity)]);    
%     title (['( ', num2str(centroid(1,1)),' , ', num2str(centroid(1,1)),' )']);
    %score
    text(10, 10, num2str(score), 'Color', 'y');
    %eccentricity
    text(10, 60, num2str(eccentricity), 'Color', 'y');
    hold off;
end