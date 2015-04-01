fps = 14;

allTracks = struct([]);
speed_sum = [];

while true
    folder_name = uigetdir
    if folder_name == 0
        break
    else
        cd(folder_name) %open the directory of image sequence
        allFiles = dir(); %get all the tif files
        load('tracks.mat')
        load('parameters.txt')
        if isempty(speed_sum)
            %divide bins by minute
            speed_sum = zeros(1, ceil(parameters(length(parameters)) / fps / 60));
            frame_count = zeros(1, ceil(parameters(length(parameters)) / fps / 60));
            tracksCentered = [];
            pirouetteCount = 0;
        end
        allTracks = Tracks;
        for track = 1:length(allTracks)
            speeds = transpose(allTracks(track).Speed);
            frames = transpose(allTracks(track).Frames);
            for speed_index = 1:length(speeds)
                speed_sum(ceil(frames(speed_index) / fps / 60)) = speed_sum(ceil(frames(speed_index) / fps / 60)) + speeds(speed_index);
            end
            for frame_index = 1:length(frames)
                frame_count(ceil(frames(frame_index) / fps / 60)) = frame_count(ceil(frames(frame_index) / fps / 60)) + 1;
            end
        end
    end
end

plot(speed_sum./frame_count, 'bo-')
%legend(num2str(tracksByVoltage(voltage_index).voltage));
xlabel(['minutes (average speed = ', num2str(sum(speed_sum)/sum(frame_count)),')']) % x-axis label
ylabel('speed (mm/s)') % y-axis label
axis([1 30 0 0.3])
