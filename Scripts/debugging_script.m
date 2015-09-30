    %% STEP 6: Post-Track Filtering to get rid of invalid tracks %%
    DeleteTracks = [];
    first_frames = zeros(1,length(Tracks));
    last_frames = zeros(1,length(Tracks));
    for i = 1:length(Tracks)
        first_frames(i) = Tracks(i).Frames(1);
        last_frames(i) = Tracks(i).Frames(end);
    end
    for i = 1:length(Tracks)
        if length(Tracks(i).Frames) < WormTrackerPrefs.MinTrackLength
            %get rid of tracks that are too short
            DeleteTracks = [DeleteTracks, i];
        else
            %find the maximum displacement from the first time point.
            %correct for dirts that don't move
            position_relative_to_start = transpose(Tracks(i).Path - repmat(Tracks(i).Path(1,:),size(Tracks(i).Path,1),1));
            euclideian_distances_relative_to_start = sqrt(sum(position_relative_to_start.^2,1)); %# The two-norm of each column
            if max(euclideian_distances_relative_to_start) < Prefs.MinDisplacement
                DeleteTracks = [DeleteTracks, i];
            end
        end
        if Tracks(i).Active == -1
            %the track ended because of a + change in area
            if ~isempty(Tracks(i).MergedBlobIndex)
                %find the tracks that starts right after the last frame
                tracks_that_started_immediately_after = find(first_frames == last_frames(i)+1);
                if ~isempty(tracks_that_started_immediately_after)
                    for tracks_that_started_immediately_after_index = 1:length(tracks_that_started_immediately_after)
                        current_track_index = tracks_that_started_immediately_after(tracks_that_started_immediately_after_index);
                        if Tracks(current_track_index).WormIndex(1) == Tracks(i).MergedBlobIndex
                            %this track is a result of increased blob size
                            DeleteTracks = [DeleteTracks, current_track_index];
                            break
                        end
                    end
                end
            end
        elseif Tracks(i).Active == -2
            %the track ended because of a - change in area
            tracks_that_started_immediately_after = find(first_frames == last_frames(i)+1);
            if length(tracks_that_started_immediately_after) >= 2
                %there are 2 or more tracks that started in this frame, get
                %their centroids
                ending_position = Tracks(i).Path(end,:);
                starting_positions = [];
                resulting_worm_count = 0;
                for tracks_that_started_immediately_after_index = 1:length(tracks_that_started_immediately_after)
                    current_track_index = tracks_that_started_immediately_after(tracks_that_started_immediately_after_index);
                    starting_positions = [starting_positions; Tracks(current_track_index).Path(1,:)];
                end
                %get the top 2 tracks that are the closest to the ending
                %centroid, average them and see the displacement
                distances = pdist2(ending_position, starting_positions);
                [~, sorted_distance_indecies] = sort(distances, 'descend');
                closest_track_index_1 = sorted_distance_indecies(1);
                closest_track_index_2 = sorted_distance_indecies(2);
                averaged_centroid = (starting_positions(closest_track_index_1,:) + starting_positions(closest_track_index_2,:)) ./ 2;
                if pdist2(ending_position, averaged_centroid) < WormTrackerPrefs.MaxDistance
                    DeleteTracks = [DeleteTracks, i];
                end
            end
        end
    end