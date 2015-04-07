
function [Speed, speed_sum, frame_count] = SpeedHistogram(folders)
    fps = 14;
    speed_sum = [];

    if nargin < 1 %no folders are given, ask user to select
        folders = {};
        while true
            folder_name = uigetdir
            if folder_name == 0
                break
            else
                folders{length(folders)+1} = folder_name;
            end
        end
    end
    
    for folder_index = 1:length(folders)
        folder_name = folders{folder_index};
        cd(folder_name) %open the directory of image sequence
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
    
    Speed = speed_sum./frame_count;
    
%    if nargin < 1
        figure
        plot(Speed, 'bo-')
        %legend(num2str(tracksByVoltage(voltage_index).voltage));
        xlabel(['minutes (average speed = ', num2str(sum(speed_sum)/sum(frame_count)),')']) % x-axis label
        ylabel('speed (mm/s)') % y-axis label
        axis([1 30 0 0.3])
%    end
end
