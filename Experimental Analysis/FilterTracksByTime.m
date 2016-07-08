function [ filteredTracks ] = FilterTracksByTime(Tracks, startFrame, endFrame)
%Takes a list of tracks and filters them based on start and end frames.
%   Detailed explanation goes here
    %fps = 14;
    filteredTracks = [];
    for track_index = 1:length(Tracks)
        filteredTracks = [filteredTracks CutTrackByFrame(Tracks(track_index), startFrame, endFrame)];
    end
end
