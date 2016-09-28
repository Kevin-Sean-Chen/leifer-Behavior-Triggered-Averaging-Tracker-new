function [filteredTracks, track_indecies_preserved] = FilterTracksByTime(Tracks, startFrame, endFrame)
%Takes a list of tracks and filters them based on start and end frames.
%   Detailed explanation goes here
    %fps = 14;
    filteredTracks = [];
    track_indecies_preserved = false(1,length(Tracks));
    for track_index = 1:length(Tracks)
        current_filtered_track = CutTrackByFrame(Tracks(track_index), startFrame, endFrame);
        if ~isempty(current_filtered_track)
            filteredTracks = [filteredTracks, current_filtered_track];
            track_indecies_preserved(track_index) = true;
        end
    end
    track_indecies_preserved = find(track_indecies_preserved);
end
