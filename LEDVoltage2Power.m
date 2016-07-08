function Tracks = LEDVoltage2Power( Tracks, power500 )
% 
%   Detailed explanation goes here
    linearpower500 = power500(:);
    for track_index = 1:length(Tracks)
       path = round(Tracks(track_index).Path);
       power_index = sub2ind(size(power500),path(:,2)',path(:,1)');
       Tracks(track_index).LEDPower = linearpower500(power_index)' .* Tracks(track_index).LEDVoltages ./ 5;
    end

end

