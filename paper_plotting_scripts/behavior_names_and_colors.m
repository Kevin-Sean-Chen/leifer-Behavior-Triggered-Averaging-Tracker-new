behavior_names = {'Forward 1', 'Forward 2', 'Forward 3', 'Forward 4', 'Forward 5', 'Forward 6', ...
    'Slow Reverse', 'Fast Reverse', 'Turns'};

%behavior_colors = [[255,238,238]; [255,189,189]; [255,123,123]; [255,74,74]; [255,16,16]; [255,0,0]; [230,230,255]; [65,65,255]; [255,0,255]]; %based on centroid velocity
behavior_colors = [[0,100,0]; [0,255,0]; [150,141,0]; [255,143,0]; [255,119,119]; [255,0,0]; [100,255,255]; [50,50,255]; [218,1,235]]; %based on centroid velocity
behavior_colors = behavior_colors ./ 255;
% 
% jet_colors = jet(64);
% behavior_colors(9,:) = [0.75 0.5 0.75]; %turns
% behavior_colors(8,:) = jet_colors(1,:); %fast reverse
% behavior_colors(7,:) = jet_colors(25,:); %slow reverse
% 
% 
% for behavior_index = 1:6
%     behavior_colors(behavior_index,:) = jet_colors((behavior_index-1)*5+34,:);
% end
