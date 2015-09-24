function [newTracks] = resolve_problems(curDir, WormTrackerPrefs)
% Plots a single worm over time along with its centerline
    min_track_length = WormTrackerPrefs.MinTrackLength;
    plotting_index = 1;
    load([curDir, '\', 'tracks.mat']);
    modifications_index = 1;
    Modifications = [];
    for track_index = 1:length(Tracks)
        Track = Tracks(track_index);
        potential_problems = Track.PotentialProblems;
        if sum(potential_problems) > 0
            loaded_file = load([curDir, '\individual_worm_imgs\worm_', num2str(track_index), '.mat']);
            worm_images = loaded_file.worm_images;

            frames_to_show = conv(single(potential_problems), ones(1, 28), 'same'); %show for 2 sec around the problem
            frames_to_show = frames_to_show > 0;
            worm_frame_start_index = 0;
            while worm_frame_start_index <= size(worm_images, 3)
                [worm_frame_start_index, worm_frame_end_index] = find_next_section(frames_to_show, worm_frame_start_index, 'f');
                if isempty(worm_frame_start_index)
                    break
                else
                    %call the gui for resolution
                    h = resolve_problems_gui(worm_images, Track, worm_frame_start_index, worm_frame_end_index, track_index);
                    movegui(h, 'center');
                    uiwait(h);
                    action = h.UserData{7};
                    current_frame = h.UserData{6};
                    close(h);
                    switch action
                        %depending on what the user selected, 
                        case 1
                            %no action: repress the error
                            Track.PotentialProblems(worm_frame_start_index:worm_frame_end_index) = -1;
                        case 2
                            %flip head/tail before
                            Track.Centerlines(:,:,1:current_frame) = flip(Track.Centerlines(:,:,1:current_frame),1);
                        case 3
                            %flip head/tail after
                            Track.Centerlines(:,:,current_frame:end) = flip(Track.Centerlines(:,:,current_frame:end),1);
                        case 4
                            %delete track
                            Modifications(modifications_index).TrackIndex = track_index;
                            Modifications(modifications_index).Action = 1; %delete
                            modifications_index = modifications_index + 1;
                            break
                        case 5
                            %advanced, let's implement later delete section and split track
                            Modifications(modifications_index).TrackIndex = track_index;
                            Modifications(modifications_index).Action = 2; %delete
                            Modifications(modifications_index).StartFrame = worm_frame_start_index;
                            Modifications(modifications_index).EndFrame = worm_frame_end_index;
                            modifications_index = modifications_index + 1;
                            break
                    end
                end
                worm_frame_start_index = worm_frame_end_index + 1;
            end
        end
    end
    
    
    newTracks = [];
    modification_track_indecies = [Modifications.Action];
    current_track_index = 1;
    current_end_index = length(Tracks);
    for track_index = 1:length(Tracks)
        Track = Tracks(track_index);
        %get if there are modifications
        if ismember(track_index, modification_track_indecies)
            %there are modifications, get all the modifications
            modifications_to_this_track = Modifications(modification_track_indecies == track_index);
            %see if there is a single delete command
            modifications_to_this_track_actions = [modifications_to_this_track.Action];
            if ismember(1, modifications_to_this_track_actions)
                %there is a delete command, delete the track
                if current_track_index == current_end_index
                    delete([curDir, '\individual_worm_imgs\worm_', num2str(current_track_index), '.mat'])
                else
                    rename_individual_worm_images(curDir,current_track_index+1,current_end_index,-1);
                end
                current_end_index = current_end_index - 1;
            else
                %there are one or many split commands
                split_tracks = [];
                split_modifications = modifications_to_this_track(modifications_to_this_track_actions == 2);
                track_frame_shift = 0;
                
                loaded_file = load([curDir, '\individual_worm_imgs\worm_', num2str(current_track_index), '.mat']);
                worm_images = loaded_file.worm_images;
                worm_images_struct(1).Images = [];
                
                for split_modification_index = 1:length(split_modifications)
                    current_split_modification_begin = split_modifications(split_modification_index).StartFrame;
                    current_split_modification_end = split_modifications(split_modification_index).EndFrame;
                    new_subtrack = FilterTracksByTime(Track, 1-track_frame_shift, current_split_modification_begin-track_frame_shift);
                    if length(new_subtrack.Frames) >= min_track_length
                        split_tracks = [split_tracks, new_subtrack];
                        worm_images_struct(length(split_tracks)).Images = worm_images(:,:,track_frame_shift+1:current_split_modification_begin);
                    end
                    Track = FilterTracksByTime(Track, current_split_modification_end-track_frame_shift, length(Track.Frames));
                    track_frame_shift = track_frame_shift + current_split_modification_end;
                end
                
                if length(Track.Frames) >= min_track_length
                    split_tracks = [split_tracks, Track];
                    worm_images_struct(length(split_tracks)).Images = worm_images(:,:,track_frame_shift+1:end);
                end                
                
                %shift up by the number of new tracks added
                current_end_index = current_end_index + length(split_tracks) - 1;
                rename_individual_worm_images(curDir, current_track_index+1, current_end_index);
                
                %split the worm frames exactly as before
                for saveindex = 1:length(split_tracks)
                    worm_images = worm_images_struct(saveindex).Images;
                    save([curDir, '\individual_worm_imgs\worm_', num2str(current_track_index+saveindex-1), '.mat'], 'worm_images');
                end
                
                newTracks = [newTracks, split_tracks];
                current_track_index = length(newTracks) + 1;
            end
        else
            %no modifications, add the old track
            newTracks = [newTracks, Track];
            current_track_index = length(newTracks) + 1;
        end
    end
    
end