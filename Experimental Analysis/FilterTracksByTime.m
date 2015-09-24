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
                %check if the first 3 dimensions of currentFieldSizes are the
                %same as the length(Frames). If so, cut it to match the
                %startFrame and endFrame
                if currentFieldSizes(1) == LengthToReplace
                    currentField = currentField(filteredIndecies(1):filteredIndecies(end),:);
                elseif currentFieldSizes(2) == 2 && ~strcmp(trackFieldNames{field_index}, 'LastCoordinates')
                    %for reversals and omega turns, delete all the entries
                    %that does not start in the time window and change the
                    %end time to the new end of the track
                    newCurrentField = [];
                    for duration_index = 1:currentFieldSizes(1)
                        if currentField(duration_index, 1) >= filteredIndecies(1) && currentField(duration_index, 1) <= filteredIndecies(end)
                            if currentField(duration_index, 2) > filteredIndecies(end)
                                newCurrentField = cat(1, newCurrentField, [currentField(duration_index,1)-filteredIndecies(1)+1, filteredIndecies(end)-filteredIndecies(1)+1]);
                            else
                                newCurrentField = cat(1, newCurrentField, [currentField(duration_index,1)-filteredIndecies(1)+1, currentField(duration_index, 2)-filteredIndecies(1)+1]);
                            end
                        end
                    end
                    currentField = newCurrentField;
                end
                if currentFieldSizes(2) == LengthToReplace
                    currentField = currentField(:,filteredIndecies(1):filteredIndecies(end));
                end
                if currentFieldSizes(3) == LengthToReplace
                    currentField = currentField(:,:,filteredIndecies(1):filteredIndecies(end));
                end
                currentTrack = setfield(currentTrack,trackFieldNames{field_index},currentField);
            end
            filteredTracks = [filteredTracks currentTrack];
        end
    end
end
