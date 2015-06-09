
function [Speed, speed_sum, frame_count] = SpeedHistogram(folders, bin_size, Tracks, frames)
    fps = 14;
    speed_sum = [];
    allTracks = [];
    
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
    
    if nargin < 2 %no bin number specified
        bin_size = fps * 60; %default bin size is one bin per min
    end
    
    if nargin < 3 %Folders are given but no Tracks are given
        frames = 0;    
        for folder_index = 1:length(folders)
            folder_name = folders{folder_index};
            cd(folder_name) %open the directory of image sequence
            load('tracks.mat')
            allTracks = [allTracks, Tracks];
            try
                load('parameters.txt')
                frames = max(parameters(length(parameters)),frames);
            catch
                parameters = readtable('parameters.txt', 'Delimiter', '\t');
                frames = max(parameters{1,{'FrameCount'}},frames);
            end
        end
    else
        allTracks = Tracks;
    end
    
    %divide bins by minute
    speed_sum = zeros(1, ceil(frames) / bin_size);
    frame_count = zeros(1, ceil(frames) / bin_size);
    tracksCentered = [];
    pirouetteCount = 0;

    for track = 1:length(allTracks)
        speeds = transpose(allTracks(track).Speed);
        frames = transpose(allTracks(track).Frames);
        for speed_index = 1:length(speeds)
            speed_sum(ceil(frames(speed_index) / bin_size)) = speed_sum(ceil(frames(speed_index) / bin_size)) + speeds(speed_index);
        end
        for frame_index = 1:length(frames)
            frame_count(ceil(frames(frame_index) / bin_size)) = frame_count(ceil(frames(frame_index) / bin_size)) + 1;
        end
    end


    Speed = speed_sum./frame_count;
    
    if nargin < 1
        figure
        plot(Speed, 'bo-')
        %legend(num2str(tracksByVoltage(voltage_index).voltage));
        xlabel(['minutes (average speed = ', num2str(sum(speed_sum)/sum(frame_count)),')']) % x-axis label
        ylabel('speed (mm/s)') % y-axis label
        axis([1 frames/bin_size 0 0.3])
    end
end
