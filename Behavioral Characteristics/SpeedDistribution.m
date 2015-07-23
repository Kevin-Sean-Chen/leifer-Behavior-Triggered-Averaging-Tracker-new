function [ all_binned_speed ] = SpeedDistribution(Tracks, bin_size)
%Takes in Tracks and provides a histogram of speeds in Tracks*bin_size

%   Detailed explanation goes here
    fps = 14;
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
        for folder_index = 1:length(folders)
            folder_name = folders{folder_index};
            cd(folder_name) %open the directory of image sequence
            load('tracks.mat')
            allTracks = [allTracks, Tracks];
            try
                load('parameters.txt')
                frames = parameters(length(parameters));
            catch
                parameters = readtable('parameters.txt', 'Delimiter', '\t');
                frames = parameters{1,{'FrameCount'}};
            end
        end
    else
        allTracks = Tracks;
    end
    
    if nargin < 2 %no bin number specified
        bin_size = fps; %default bin size is one bin per second
    end
    
    all_binned_speed = [];
    %filteredTracks = [];
    for track_index = 1:length(allTracks)
        % cut the tracks so that it is divisible by the bin_size
        currentTrack = Tracks(track_index);
        TrackLength = size(currentTrack.Frames,2);
        if TrackLength > bin_size
            minFrame = currentTrack.Frames(1);
            maxFrame = currentTrack.Frames(end);
            newCurrentTrack = FilterTracksByTime(currentTrack, minFrame, maxFrame - mod(TrackLength, bin_size));
            %filteredTracks = [filteredTracks, newCurrentTrack];
%            binned_average_speed = newCurrentTrack.SmoothSpeed; %binned by frame
%             binned_average_speed = mean(reshape(newCurrentTrack.Speed,bin_size,[]),1);
             binned_average_speed = mean(newCurrentTrack.Speed); %binned by track
%             all_binned_speed(track_index).Values = binned_average_speed; %[all_binned_speed, binned_average_speed];
            all_binned_speed = [all_binned_speed, binned_average_speed]; %[all_binned_speed, binned_average_speed];
        end
    end
    
end

