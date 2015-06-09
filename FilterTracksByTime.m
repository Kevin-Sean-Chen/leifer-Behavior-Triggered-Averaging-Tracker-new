function [ filteredTracks ] = FilterTracksByTime(Tracks, startFrame, endFrame)
%Takes a list of tracks and filters them based on start and end frames.
%   Detailed explanation goes here
    %fps = 14;
    filteredTracks = [];
    for track_index = 1:length(Tracks)
        currentTrack = Tracks(track_index);
        filteredIndecies = find(currentTrack.Frames >= startFrame & currentTrack.Frames <= endFrame);
        if ~isempty(filteredIndecies)
            LengthToReplace = length(currentTrack.Frames);
            trackFieldNames = fieldnames(currentTrack);
            for field_index = 1:length(trackFieldNames)
                currentField = getfield(currentTrack,trackFieldNames{field_index});
                currentFieldSizes = size(currentField);
                %check if the first 2 dimensions of currentFieldSizes are the
                %same as the length(Frames). If so, cut it to match the
                %startFrame and endFrame
                if currentFieldSizes(1) == LengthToReplace
                    currentField = currentField(filteredIndecies(1):filteredIndecies(end),:);
                end
                if currentFieldSizes(2) == LengthToReplace
                    currentField = currentField(:,filteredIndecies(1):filteredIndecies(end));
                end
                currentTrack = setfield(currentTrack,trackFieldNames{field_index},currentField);
            end
            filteredTracks = [filteredTracks currentTrack];
        end
    end
end
